.model small
.stack 256
.data
    ten dw 10
    dividendMess db "Dividend: $"
    divisorMess db 10, 13, "Divisor: $"
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
    call outputSign
    push ax

    lea dx, divisorMess
    mov ah, 09h
    int 21h
    call input
    call outputSign
    cmp ax, 0
    jz divisorZero        ; проверяем чтобы делитель не был 0 

    cmp ax, -1
    jnz division
    pop bx
    cmp bx, 8000h
    push bx
    jnz division
    lea dx, errorMess
    mov ah, 09h
    int 21h
    jmp exit

division:         ;делим и проверяем какой получился остаток
	mov cx, ax
	pop ax
	cwd
	idiv cx
	test dx, 1000000000000000b
	jz positivRemainder
	test cx, 1000000000000000b
	jz positivDivisor
	inc ax
	sub dx, cx
	jmp positivRemainder
positivDivisor:
	dec ax
	add dx, cx

positivRemainder:
	push dx
	push ax
	lea dx, resultMess
	mov ah, 09h
	int 21h
	pop ax
	call outputSign
	lea dx, remainderMess
	mov ah, 09h
	int 21h
	pop ax
	call outputSign
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

output proc      ; процедура вывода на консоль
	push ax
	push bx
	push cx
	push dx
	xor cx, cx
	mov bx, 10

inStack:          ;закидываем в стек ост от деления на 10
	xor dx, dx
	div bx
	push dx
	inc cx
	cmp ax, 0
	jnz inStack

outStack:         ;достаем из стека
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

outputSign proc    ; процедура вывода если есть -
	push ax
	push dx
	
	test ax, 1000000000000000b
	jz print
	push ax
	mov dl, '-'
	mov ah, 02h
	int 21h
	pop ax
	neg ax
print:
	call output
	pop dx
	pop ax
	ret
outputSign endp	

input proc        ; ввод и преобразование символа в число
	push bx
	push cx
	push dx
	push si
	push di
startInput:       ; смотрим цифра или - первое
	xor di, di
	xor bx, bx
	xor si, si
	mov ah, 01h
	int 21h
	cmp al, '-'
	jnz button
	mov si, 1
	inc di

cycl:
	mov ah, 01h
	int 21h
button:             ;ввод(), удаление через backspase и esc
	inc di
	cmp al, 13
	jz enter
	cmp al, 8
	jz backspace
	cmp al, 1Bh
	jz escape
	
	sub al, '0'
	cmp al, 10
	jnc errorm
	xor cx, cx
	mov cl, al
	mov ax, bx
	mul ten
	cmp dx, 0
	jnz errorm
	add ax, cx
	jc errorm
	mov dx, 32767
	cmp si, 1
	jnz cyclFinish
	inc dx
cyclFinish:
	cmp dx, ax
	jc errorm
	mov bx, ax
	jmp cycl

backspace:               ;обработка backspase 
	call delete
	dec di
	mov ax, bx
	xor dx, dx
	div ten
	mov bx, ax
	cmp bx, 0
	jnz cycl

	mov ah, 03h
	int 10h
	cmp dl, 0
	jz startInput
	jmp cycl
escape:                   ;обработка esc
	xor bx, bx
	xor si, si
	mov cx, di
	xor di, di
	inc cx
escapeLoop:
	mov dl, 8
	mov ah, 02h
	int 21h
	call delete
	loop escapeLoop
	jmp startInput
errorm:
	lea dx, errorMess
	mov ah, 09h
	int 21h
enter:
	mov ax, bx
	cmp si, 1
	jnz finish
	neg ax
finish:
	pop di
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
