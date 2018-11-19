.model small
.stack 256
.data
    ten dw 10
    dividendMess db "Dividend: ", 10, 13, '$'
    divisorMess db 10, 13, "Divisor: ", 10, 13, '$'
    errorMess db 10, 13, "Error", 10, 13, '$'
    resultMess db 10, 13, "Result: $"
    remainderMess db 10, 13, "Remainder: $" 
    endline db 13,10,'$'
.code
main:
    mov ax, @data
    mov ds, ax

    lea dx, dividendMess
    mov ah, 09h
    int 21h
    call input
    call output
    push ax

    lea dx, divisorMess
    mov ah, 09h
    int 21h
    call input
    call output
    cmp ax, 0
    jz divisorZero        ; ïðîâåðÿåì ÷òîáû äåëèòåëü íå áûë 0

    mov cx, ax
    pop ax
    xor dx, dx
    div cx
    push dx
    push ax
    lea dx, resultMess
    mov ah, 09h
    int 21h
    pop ax
    call output
    lea dx, remainderMess
    mov ah, 09h
    int 21h
    pop ax
    call output
    lea dx, endline
    mov ah, 09h
    int 21h
    jmp exit

divisorZero:                
    lea dx, errorMess
    mov ah, 09h
    int 21h

exit:    
    mov ax, 4c00h
    int 21h

output proc      ; ïðîöåäóðà âûâîäà íà êîíñîëü
	push ax
	push bx
	push cx
	push dx
	xor cx, cx
	mov bx, 10

inStack:          ;çàêèäûâàåì â ñòåê îñò îò äåëåíèÿ íà 10
	xor dx, dx
	div bx
	push dx
	inc cx
	cmp ax, 0
	jnz inStack

outStack:         ;äîñòàåì èç ñòåêà
	pop dx
	add dl, '0'
	mov ah, 02h
	int 21h
	loop outStack
	pop dx
	pop cx
	pop bx
	pop ax
	ret
output endp	

input proc          ; ââîä è ïðåîáðàçîâàíèå ñèìâîëà â ÷èñëî 
	push bx
	push cx
	push dx
	push si
	xor bx, bx
	xor si, si
button:             ;ââîä(enter), óäàëåíèå ÷åðåç backspase è esc
	mov ah, 01h
	int 21h
	cmp al, 13
	jz finish
	cmp al, 8
	jz backspace
	cmp al, 1Bh
	jz escape
	
	sub al, '0'
	cmp al, 10
	jnc errorm
	xor ch, ch
	mov cl, al
	mov ax, bx
	mul ten
	cmp dx, 0
	jnz errorm
	add ax, cx
	jc errorm
	mov bx, ax
	inc si
	jmp button
backspace:                 ;îáðàáîòêà backspase 
	call delete
	mov ax, bx
	xor dx, dx
	div ten
	mov bx, ax
	jmp button
escape:                    ;îáðàáîòêà esc
	mov cx, si
	xor si, si
	xor bx, bx
	inc cx
escapeLoop:
	mov dl, 8
	mov ah, 02h
	int 21h
	call delete
	loop escapeLoop
	jmp button
errorm:
	lea dx, errorMess
	mov ah, 09h
	int 21h
finish:
	mov ax, bx
	pop si
	pop dx
	pop cx
	pop bx
	ret
input endp

delete proc
	push ax
	push dx
	mov dl, ' '
	mov ah, 02h
	int 21h
	mov dl, 8
	mov ah, 02h
	int 21h
	pop dx
	pop ax
	ret
delete endp


end main
