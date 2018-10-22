.model small
.stack 256
.data
	message_divident db "Enter a dividend: ", 10, '$'
	message_divider db "Enter a divider: ", 10, '$'
	message_remainder db "Remaider: ", 10, '$'
	message_output db "You have entered: ", 10, '$'
	message_divbyzero db "Error. Division by zero", 10, '$'
	message_answer db "Answer: ", 10, '$'
	ten dw 10
.code

	OUTPUT proc
		push cx
		push dx
		push ax
		xor cx, cx
		
		NumberInStack:
			xor dx, dx
			div ten
			push dx
			inc cx
			cmp ax,0
			jnz NumberInStack
			
		Print:
			pop dx
			add dx, '0'
			mov ah, 02h
			int 21h
			loop Print
		
		mov dl, 10
		call WRITE
		
		pop ax
		pop dx
		pop cx
		ret
	OUTPUT endp
	
	INPUT proc
		push bx
		push cx
		push dx
		xor ax, ax
		xor cx, cx
		inp:
			mov ah, 01h
			int 21h
			
			cmp al, 13
			jz finish_label
			cmp al, 8
			jz backspace
			cmp al, 27
			jz escape
			cmp al, '0'
			jc deletesymbol
			cmp al, '9'		
			ja deletesymbol
			xor bx, bx
			mov bl, al
			sub bl, '0'
			mov ax, cx
			mul ten
			jc deletesymbol
			add ax, bx
			jc deletesymbol
			mov cx, ax
			jmp inp	
			
		finish_label:
			jmp finish
			
		backspace:
			mov ax, cx
			xor dx, dx
			div ten
			mov cx, ax
			mov ah, 02h
			mov dl, ' '
			int 21h
			mov dl, 8
			int 21h
			jmp inp
					
		deletesymbol:
			mov ah, 02h
			mov dl, 8
			int 21h
			mov dl, ' '
			int 21h
			mov dl, 8
			int 21h
			jmp inp		
			
		escape:
			mov ah, 02h
			mov dl, 13
			int 21h
			mov dl, ' '
			mov cx, 6
			deletingloop:
				int 21h
				loop deletingloop
			mov dl, 13
			int 21h
			xor cx, cx
			jmp inp	
		
	finish:
		mov ax, cx
		pop dx
		pop cx
		pop bx
		ret
	INPUT endp
	
	WRITE proc
		push ax
		mov ah, 02h
		int 21h
		pop ax
		ret
	WRITE endp
	
	WRITE_STRING proc
		push ax
		mov ah, 09h
		int 21h
		pop ax
		ret
	WRITE_STRING endp
		
main:
    mov ax, @data
    mov ds, ax	
	
	lea dx, message_divident
	call WRITE_STRING
	call INPUT
	lea dx, message_output
	call WRITE_STRING
	call OUTPUT
	
	mov cx, ax
	
	lea dx, message_divider
	call WRITE_STRING
	call INPUT
	lea dx, message_output
	call WRITE_STRING
	call OUTPUT
	
	cmp ax, 0
	jz divbyzero
	mov bx, ax
	mov ax, cx
	xor dx, dx
	div bx
	mov bx, dx
	lea dx, message_answer
	call WRITE_STRING
	call OUTPUT
	lea dx, message_remainder
	call WRITE_STRING
	mov ax, bx
	call OUTPUT
	jmp exit
	
	divbyzero:
        lea dx, message_divbyzero
        call WRITE_STRING
	
exit:
    mov ax, 4c00h
    int 21h
end main