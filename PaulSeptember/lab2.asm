.model small
.stack 100h

.data
	string db 15 dup('?')
	ten dw 10
	endline db 13,10,'$'
	dividendMessage db 'Please input dividend:$'
	dividerMessage db 'Please input divider:$'
	zeroErrorMessage db 'Divider cannot be equal to 0!$'
	overflowMessage db 'Number is too large. Please input again.$'
	resultMessage db 'Result:$'
	remainderMessage db 'Remainder:$'

.code

printString proc
    push ax
    mov ah,09h
    int 21h 
    pop ax
    ret
printString endp


endl proc
    push dx
    lea dx,endline
    call printString
    pop dx
    ret
endl endp


backspace proc
	push ax
	push dx
	mov ah,02h
	mov dl,32
	int 21h
	mov dl,8
	int 21h
	pop dx
	pop ax
	ret 
backspace endp


output proc                     
    push ax
    push cx                     
    push dx
    xor cx,cx

	getNumbers:                      
    	xor dx,dx	
    	div ten
    	add dx,30h                  
    	push dx
    	inc cx
    	cmp ax,0
    jne getNumbers 

    mov ah,02h

	printNumbers:              
    	pop dx
    	int 21h                   
    loop printNumbers 

    call endl

    pop dx
    pop cx                      
    pop ax
    ret
output endp


input proc
	push bx
	push dx
	xor bx,bx

	inputChar:
		mov ah,01h
		int 21h
		xor ah,ah

		cmp al,13		;check symbol
		je endInput
		cmp al,8
		je pressedBackspace
		cmp al,30h
		jb inputError
		cmp al,39h
		ja inputError

		sub al,30h	;30h = '0'
		xchg ax,bx
		mul ten
		jc overflow
		add ax,bx
		xchg ax,bx
	jmp inputChar
	
	pressedBackspace:
		call backspace
		xchg ax,bx
		xor dx,dx
		div ten
		xchg ax,bx		
	jmp inputChar
	
	inputError:
		mov ah,02h
		mov dl,8
		int 21h
		call backspace
	jmp inputChar	
		
	overflow:
		call endl	
		lea dx,overflowMessage
		call printString
		call endl
		xor bx,bx
	jmp inputChar

	endInput:			
	mov ax,bx
	pop dx
	pop bx
	ret	
input endp



start:
	mov ax,@data
	mov ds,ax

	lea dx, dividendMessage
	call printString
	call endl
	call input
	call output

	mov bx,ax
	jmp getDivisor

	errorDivisor:
	lea dx,zeroErrorMessage
	call printString
	call endl

	getDivisor:
	lea dx, dividerMessage
	call printString
	call endl
	call input
	cmp ax,0
	je errorDivisor
	call output
	
	xchg ax,bx
	xor dx,dx
	div bx
	mov bx,dx

	lea dx,resultMessage
	call printString
	call endl

	call output

	lea dx,remainderMessage
	call printString
	call endl

	mov ax,bx
	call output

	mov ax,4c00h
	int 21h
end start