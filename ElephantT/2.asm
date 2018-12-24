.model small
.stack 100h

.data
	base dw 10
	next_lineine db 13,10,'$'
	firstmes db 'Dividend:$'
	secondmes db 'Divider:$'
	zeromes db 'Divider != 0$'
	overflowmes db 'Input again. Incorrect number (too big)$'
	resultmes db 'result:$'
	remaindermes db 'remainder:$'

.code

cout_Number proc                     
    push ax
    push cx                     
    push dx
    xor cx,cx

	stack_with_digits:         ; занести цифры в стек           
    	xor dx,dx	
    	div base			
    	add dx,30h              ; 30h - в стэк ложит цифру, код символа ноль  31h - символ 1  
    	push dx			
    	inc cx
    	cmp ax,0
    jne stack_with_digits

    mov ah,02h

	showNumbers:              
    	pop dx
    	int 21h                   ; вывод символа
    loop showNumbers 

    call next_line

    pop dx
    pop cx                      
    pop ax
    ret
cout_Number endp



cout_Str proc
    push ax
    mov ah,09h
    int 21h 
    pop ax
    ret
cout_Str endp



cin proc
	push bx
	push dx
	xor bx,bx

	cinChar:
		mov ah,01h		; 01h - ввести символ
		int 21h			; вызывается консоль и код символа записывается в al
		xor ah,ah

		cmp al,13		;check symbol
		je endcin
		cmp al,8		
		je pressed_reverse_delete
		cmp al,30h		
		jb cinError		; если символ меньше нуля то гг
		cmp al,39h
		ja cinError

		sub al,30h	;30h = '0'
		xchg ax,bx
		mul base
		jc overflow	; чекаем переполнение и переходим туда если true
		add ax,bx
		xchg ax,bx	
	jmp cinChar
	
	pressed_reverse_delete:
		call reverse_delete
		xchg ax,bx
		xor dx,dx
		div base
		xchg ax,bx		
	jmp cinChar
	
	cinError:	; затирает символ, если он кривой
		mov ah,02h
		mov dl,8
		int 21h
		call reverse_delete
	jmp cinChar	
		
	overflow:
		call next_line	
		lea dx,overflowmes
		call cout_Str
		call next_line
		xor bx,bx
	jmp cinChar

	endcin:			
	mov ax,bx
	pop dx
	pop bx
	ret	
cin endp



reverse_delete proc
	push ax
	push dx
	mov ah,02h	;02h - вывести символ
	mov dl,32	; 32 - пробел
	int 21h		; прерывание
	mov dl,8	; 8-бэкспейс
	int 21h
	pop dx
	pop ax
	ret 
reverse_delete endp



next_line proc
    push dx
    lea dx,next_lineine
    call cout_Str
    pop dx
    ret
next_line endp



start:
	mov ax,@data
	mov ds,ax

	lea dx, firstmes
	call cout_Str
	call next_line
	call cin
	call cout_Number

	mov bx,ax
	jmp getDivisor

	errorDivisor:
	lea dx,zeromes
	call cout_Str
	call next_line

	getDivisor:
	lea dx, secondmes
	call cout_Str
	call next_line
	call cin
	cmp ax,0
	je errorDivisor
	call cout_Number
	
	xchg ax,bx
	xor dx,dx
	div bx
	mov bx,dx

	lea dx,resultmes
	call cout_Str
	call next_line

	call cout_Number

	lea dx,remaindermes
	call cout_Str
	call next_line

	mov ax,bx
	call cout_Number

	mov ax,4c00h
	int 21h
end start