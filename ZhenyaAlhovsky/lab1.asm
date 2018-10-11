.model small
.stack 256
.data
    a dw 1
    b dw 5
    c dw 3
	d dw 7
.code
main:
    mov ax, @data
    mov ds, ax
	
    ;a*c save in B
	
	mov ax, a
	mul c
	mov bx, ax
	
	;b*d save in AX
	; a*c + b*d save in BX
	
	mov ax, b
	mul d
	add bx, ax
	
	mov ax, a
	mul d
	mov cx, ax
	
	mov ax, b
	mul c
	add cx, ax
	
	cmp bx, cx
	jnz SecondCondition
	
	;FirstCondition
	
	mov ax, a
	mul a
	jmp exit
	
	SecondCondition:
	
	mov ax, c
	cmp ax, a
	jnc ThirdCondition
	
	and ax, b
	jmp exit
	
	ThirdCondition:
	mov ax, a
	mov bx, b
	or bx, c
	sub ax, bx
	
	exit:
    
    mov ax, 4c00h
    int 21h
end main