.model small
.stack 256
.data
	message_divident db "Enter a dividend: ", 10, '$'
	message_divider db "Enter a divider: ", 10, '$'
	message_output db "You have entered: ", 10, '$'
	message_divbyzero db "Error. Division by zero", 10, '$'
	message_answer db "Answer: ", 10, '$'
	number dw ?
	ten dw 10
.code
	OUTPUT proc
		push bx
		push cx
		push dx
		xor cx, cx
		mov bx, ax
		
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
		
		pop dx
		pop cx
		mov ax, bx
		pop bx
		ret
	OUTPUT endp
	
	INPUT proc
		push bx
		push cx
		push dx
		xor ax, ax
		xor cx, cx
		mov number, 0
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
			cmp al, 58 ;58 = '9' + 1
			jnc deletesymbol
			xor bx, bx
			mov bl, al
			sub bl, '0'
			mov ax, number
			mul ten
			jc deletesymbol
			add ax, bx
			jc deletesymbol
			mov number, ax
			inc cx
			jmp inp	
			
		finish_label:
			jmp finish
			
		backspace:
			cmp cx, 0
			jz inp
			mov ax, number
			xor dx, dx
			div ten
			mov number, ax
			dec cx
			mov dl, ' '
			call WRITE
			mov dl, 8
			call WRITE
			jmp inp
					
		deletesymbol:
			mov dl, 8
			call WRITE
			mov dl, ' '
			call WRITE
			mov dl, 8
			call WRITE
			
			jmp inp		
			
		escape:
			mov dl, 13
			call WRITE
			cmp cx, 0
			jz end_escape
			mov ax, number
			mov number, 0
			deletingloop:
				mov dl, ' '
				call WRITE
				xor dx, dx
				div ten
				loop deletingloop
			end_escape:
			mov dl, ' '
			call WRITE
			mov dl, 13
			call WRITE
			jmp inp
				
			
		
		finish:
		mov ax, number
		pop dx
		pop cx
		pop bx
		mov number, 0
		
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
	lea dx, message_answer
	call WRITE_STRING
	call OUTPUT
	jmp exit
	
	divbyzero:
		lea dx, message_divbyzero
		call WRITE_STRING
	
	exit:
    mov ax, 4c00h
    int 21h
end main