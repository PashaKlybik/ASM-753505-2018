.model small
.stack 256
.data
	coeff dw 10
	
	input_divnd_mess db 'Input the dividend: $'
	input_divr_mess db 'Input the divider: $'
	OutputNumber_divnd_mess db 'dividend=$'
	OutputNumber_divr_mess db 'divider=$'
	result_mess db 'result(dividend/divider)=$'
	residue_mess db 'residue=$'
	div_by_z_mess db 'Division by zero!!!', 13, 10, '$'
	out_of_range db 13,10,'Out of range exception!!!', 13, 10, '$'
.code																				
	Input PROC
		push bx
		push cx
		push dx
		
		xor bx, bx
		xor cx, cx
	input_cycle:
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
		xor ah, ah
		xchg ax, bx
		xor dx, dx
		mul [coeff]
		jc _error
		xchg ax, bx
		add bx, ax
		jc _error
		inc cx         ;need for backspace
	jmp input_cycle
		
	
	dels:			   ;delete a symbol in cmd
		mov ah, 02h
		mov dl, 08h
		int 21h
		mov dl, 0h
		int 21h
		mov dl, 08h
		int 21h
		jmp input_cycle
				
	backspace:				
		mov ah, 02h		
		mov dl, 0h
		int 21h
		or cx, cx		;check presence symbols
		jz input_cycle
		mov dl, 08h
		int 21h
		
		mov ax, bx
		xor dx, dx
		div [coeff]	  
		mov bx, ax
		
		dec cx
		jmp input_cycle
		
	escape:
		xor bx, bx		    ;in progr
		inc cx
		mov ah, 02h
		del_lopp:			;in cmd
			mov dl, 08h
			int 21h
			mov dl, 0h
			int 21h
			mov dl, 08h
			int 21h
		loop del_lopp 
		jmp input_cycle
			
	_error:
		mov dx, offset out_of_range
		call WriteMess
		stc
		jmp main_exit
	exit:
		mov ax, bx
		pop dx
		pop cx
		pop bx
		ret
	Input endp	
	
	
	OutputNumber PROC
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
	OutputNumber endp
	
	WriteMess PROC
		push ax
		mov ah, 09h
		int 21h
		pop ax
		ret
	WriteMess endp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:
	mov ax, @data
    mov ds, ax
	
	mov dx, offset input_divnd_mess
	call WriteMess
	call Input
	mov bx, ax
	mov dx, offset OutputNumber_divnd_mess
	call WriteMess
	call OutputNumber
	
	mov dx, offset input_divr_mess
	call WriteMess	
	call Input
	or ax, ax	    ;check div by 0
	jz dbz_error
	mov dx, offset OutputNumber_divr_mess
	call WriteMess
	call OutputNumber

	xor dx, dx
	xchg ax, bx
	div bx
	mov bx, dx
	
	mov dx, offset result_mess
	call WriteMess
	call OutputNumber
	mov dx, offset residue_mess
	call WriteMess
	mov ax, bx
	call OutputNumber
	
	jmp main_exit
	
	dbz_error:
		mov dx, offset div_by_z_mess
		call WriteMess
		stc
	main_exit:
		mov ax, 4c00h
		int 21h

end main      
