.model small
.stack 256
.data
	message_divident db "Enter a dividend: ", 10, '$'
	message_divider db "Enter a divider: ", 10, '$'
	message_remainder db "Remainder: ", 10, '$'
	message_output db "You have entered: ", 10, '$'
	message_divbyzero db "Error. Division by zero", 10, '$'
	message_answer db "Answer: ", 10, '$'
	minus dw ?
	number dw ? ; push pop slower
	maxpositiveplusone dw 32768
	maxnegativeplusone dw 32769
	ten dw 10
.code

	INPUT proc
		push bx
		push cx
		push dx
		
		xor cx, cx ; cx == counter
		xor ax, ax
		mov number, 0
		mov minus, 0
		
		inp:
			mov ah, 01h
			int 21h
			
			cmp al, 13
			jz finish_label
			cmp al, 8
			jz backspace_label
			cmp al, 27;escape
			jz escape_label
			cmp al, '-'
			jnz positive_number
			cmp cx, 0
			jnz deletesymbol
			mov minus, '-'
			inc cx
			jnp inp
			
		positive_number:
			cmp al, '0'
			jc deletesymbol
			cmp al, 58 ;58='9' + 1
			jnc deletesymbol
			
			xor bx, bx
			mov bl, al
			sub bl, '0'
			mov ax, number
			mul ten
			jc deletesymbol
			add ax, bx
			mov bx, minus			
			;labels
			jmp BNTU_rubbish
			finish_label:
			jmp finish
			backspace_label:
			jmp backspace
			escape_label:
			jmp escape
			inp_label:
			jmp inp
			BNTU_rubbish:
			
			cmp minus, '-'
			jnz positive
				cmp ax, maxnegativeplusone
				jmp next_step
			positive:
				cmp ax, maxpositiveplusone
			next_step:
				jnc deletesymbol
				mov number, ax
				inc cx
				jmp inp
				
		deletesymbol:
			mov dl, 8
			call WRITE
			mov dl, ' '
			call WRITE
			mov dl, 8
			call WRITE			
			jmp inp_label
			
		backspace:
			cmp cx, 0
			jz inp_label
			cmp cx, 1
			jnz not_minus
			cmp minus, '-'
			jnz not_minus
			mov minus, 0
			jmp deleting
			
			not_minus:
				xor dx, dx
				mov ax, number
				div ten
				mov number, ax
			
			deleting:
				mov dl, ' '
				call WRITE
				mov dl, 8
				call WRITE
			dec cx
			jmp inp_label
			
		escape:
			mov dl, 13
			call WRITE
			cmp  cx, 0
			jz end_escape
			xor ax, ax
			mov number, ax
			mov minus, 0
			deleteall:
				mov dl,' '
				call WRITE
				loop deleteall
			end_escape:
			mov dl, ' '
			call WRITE
			mov dl, 13
			call WRITE

			jmp inp_label
			
		finish:
		mov ax, number
		cmp minus, '-'
		jnz to_exit
		not ax
		inc ax
		to_exit:
		mov minus, 0
		pop dx
		pop cx
		pop bx
		ret		
	INPUT endp

	OUTPUT proc
		push bx
		push cx
		push dx
		xor cx, cx
		mov number, ax
		mov minus, 0
		
		cmp ax, maxpositiveplusone
		jc NumberInStack
		mov minus, '-'
		not ax ; == sub bx, ax (bx = 0) mov ax, bx
		inc ax
		mov dl, '-'
		call WRITE
		
		NumberInStack:
			xor dx, dx
			div ten
			push dx
			inc cx
			cmp ax,0
			jnz NumberInStack
			
		mov ah, 02h
		Print:
			pop dx
			add dx, '0'
			int 21h
			loop Print
		
		mov dl, 10
		call WRITE
		pop dx
		pop cx
		pop bx
		mov ax, number
		ret
	OUTPUT endp
	
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
	
	mov bx, ax
	
	lea dx, message_divider
	call WRITE_STRING
	call INPUT
	lea dx, message_output
	call WRITE_STRING
	call OUTPUT
	
	cmp ax, 0
	jz divbyzero
	mov cx, ax
	mov ax, bx
	;cmp cx, 0FFFFh
	cmp cx, -1
	jz div_minus_one
	cmp cx, 1
	jz answer_output
	cwd	
not_negative:
	idiv cx ;cx = divider
	mov bx, dx
answer_output:
	lea dx, message_answer
	call WRITE_STRING
	call OUTPUT
	lea dx, message_remainder
	call WRITE_STRING
	mov ax, bx
	cmp ax, maxpositiveplusone
	jc it_is_remainder
	cmp cx, maxpositiveplusone
	jc add_divider
	sub ax, cx
	jmp it_is_remainder
add_divider:
	add ax, cx
it_is_remainder:
	call OUTPUT
	jmp exit
	
	div_minus_one:
		neg ax
		jmp answer_output
		
	divbyzero:
		lea dx, message_divbyzero
		call WRITE_STRING
	
	exit:
    mov ax, 4c00h
    int 21h
end main	
			
			
			