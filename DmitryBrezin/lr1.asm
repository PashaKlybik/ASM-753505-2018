.model small
.stack 256
.data
    a dw 3
    b dw 1
    c dw 2
    d dw 9
.code
main:
    	
    mov ax,a
    mov bx,a
    dec bx
    and ax,bx 
    cmp ax,b
    jbe lol
    jmp notlol

    lol:
	mov cx,c
	mov dx,d
	add cx,b
	cmp dx,cx
	jnle lol1
	jmp notlol1
		lol1:
			mov dx,0
			mov ax,0
			mov bx,0
			mov ax,d
			mov bx,c
			div bx
			add ax,dx
			jmp exi
		notlol1:
			mov cx,c
			mov dx,d
			xor cx,dx
			mov ax,cx
			jmp exi	
	
    notlol:
		mov ax, b
		mov bx, b
		inc bx
		or ax, bx
		jmp exi

	exi:
    	mov ax, 4c00h
    	int 21h
end main