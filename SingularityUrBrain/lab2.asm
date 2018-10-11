.model small
.stack 256
.data
	coeff dw 10
	
	input_divnd_mess db 'Input the dividend: $'
	input_divr_mess db 'Input the divider: $'
	output_divnd_mess db 'dividend=$'
	output_divr_mess db 'divider=$'
	result_mess db 'result(dividend/divider)=$'
	residue_mess db 'residue=$'
	div_by_z_mess db 'Division by zero!!!', 13, 10, '$'
	out_of_range db 13,10,'Out of range exception!!!', 13, 10, '$'
.code
main:
	mov ax, @data
	mov ds, ax
	
	mov ah, 09h
	mov dx, offset input_divnd_mess
	int 21h
	
	call Input
	mov bx, ax
	
	mov ah, 09h
	mov dx, offset output_divnd_mess
	int 21h
	
	mov ax, bx
	call Output
	
	mov cx, ax	    
	
	mov ah, 09h
	mov dx, offset input_divr_mess
	int 21h
	
	call Input
	
	or ax, ax	    ;check div by 0
	jz dbz_error
	
	mov bx, ax
	
	mov ah, 09h
	mov dx, offset output_divr_mess
	int 21h
	
	mov ax, bx
	call Output
	
	mov bx, ax		
	mov ax, cx		
	
	xor dx, dx
	div bx			
	
	mov cx, dx
	mov bx, ax
	
	mov ah, 09h
	mov dx, offset result_mess
	int 21h
	
	mov ax, bx
	call Output
	
	mov ah, 09h
	mov dx, offset residue_mess
	int 21h 
	
	mov ax, cx
	call Output
	
	jmp _Exit
	
	dbz_error:
		stc
		mov ah, 09h
		mov dx, offset div_by_z_mess
		int 21h
	
	_Exit:
		mov ax, 4c00h
		int 21h
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Input PROC
		push bx
		push cx
		push dx
		
		xor bx, bx
		xor cx, cx
		xor dx, dx
		
		cycle:
			mov ah, 01h
			int 21h
			cmp al, 0dh    ;enter
			jz exit
			cmp al, 08h
			jz backspace
			cmp al, 1Bh
			jz escape
			cmp al, '0'
			jb dels
			cmp al, '9'
			ja dels
			sub al, '0'
			xchg ax, bx
			xor dx, dx
			mul [coeff]
			jc _error
			xchg ax, bx
			xor ah, ah
			add bx, ax
			jc _error
			inc cx         ;need for backspace
		jmp cycle
		

	dels:			   ;delete a symbol in cmd
		mov ah, 02h
		mov dl, 08h
		int 21h
		mov dl, 0h
		int 21h
		mov dl, 08h
		int 21h
		jmp cycle
				
	backspace:				
		mov ah, 02h		
		mov dl, 0h
		int 21h
		
		or cx, cx
		jz cycle
		
		mov dl, 08h
		int 21h
		
		mov ax, bx
		xor dx, dx
		div [coeff]	  
		mov bx, ax
		
		dec cx
		jmp cycle
		
	escape:
		xor bx, bx		    ;in progr
		inc cx
		del_lopp:			;in cmd
			mov ah, 02h
			mov dl, 08h
			int 21h
			mov dl, 0h
			int 21h
			mov dl, 08h
			int 21h
		loop del_lopp 
		jmp cycle
			
	_error:
		mov ah, 09h
		mov dx, offset out_of_range
		int 21h
		stc
		jmp _Exit
	exit:
		mov ax, bx
		pop dx
		pop cx
		pop bx
		ret
	Input endp	
	
	
	Output PROC
		push ax	         
		push cx
		push dx
		
		xor cx, cx      
		
	division:
		xor dx, dx
		div [coeff]
		push dx
		inc cx
		or ax, ax    
	    jnz division
		
		mov ah, 02h
	outc:
		pop dx
		add dl, '0'
		int 21h
	loop outc
		mov dl, 0Ah	
		int 21h
	
		pop dx
		pop cx
		pop ax
		ret
	Output endp
	

end main 
