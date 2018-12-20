model small
stack 200h
.data
a dw 12
b dw 16
c dw 8
d dw 2

.code
start: 
	mov ax,@data
	mov ds,ax
	
	mov ax,a
	mov bx,b
	mov cx,c
	mov dx,d

	cmp ax,bx
	ja trybx
	cmp ax,cx
	ja trycx
	cmp ax,dx
	ja trydx
	jmp exit

	trybx:
		cmp bx,cx
		ja trycx
		cmp bx,dx
		ja trydx
		mov ax,bx
		jmp exit;

	trycx:
		cmp cx,bx
		ja trybx
		cmp cx,dx
		ja trydx
		mov ax,cx
		jmp exit;	

	trydx:
		cmp dx,bx
		ja trybx
		cmp dx,cx
		ja trycx
		mov ax,dx
		jmp exit;	

exit:
        mov ax, 4c00h 
        int 21h
end start