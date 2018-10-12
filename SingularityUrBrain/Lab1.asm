.model small
.stack 256
.data
    a dw 5
    b dw 5
    c dw 0
    d dw 7
.code
main:
	mov ax, @data
	mov ds, ax
    	
	mov ax, [a]
	imul [c]		
	mov bx, ax 	
	mov ax, [b]
	imul [d]		
	add bx, ax 
	
	mov ax, [a]	
	imul [d]		
	mov cx, ax	
	mov ax, [b]
	imul [c]		
	add cx, ax	
	
	cmp bx, cx
	jnz unequal
	mov ax, [a]
	imul ax
	jmp end_if
unequal:
	mov bx, [a]
	cmp bx, [c]
	jng less_or_eq
	mov ax, [c]
	and ax, [b]
	jmp end_if
less_or_eq:
	mov bx, [b]	 
	or bx, [c]
	mov ax, [a]
	sub ax, bx
	
end_if:
	mov ax, 4c00h
	int 21h
	
end main 
