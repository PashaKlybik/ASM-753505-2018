.model small
.stack 256
.data
    a dw 5
    b dw 15
	c dw 7
	d dw 10
	inpbuf db 7, 0, 7 dup(0)
	CR_LF db 0Dh, 0Ah, '$'
.code
main:
	mov ax, a
	mov bx, b
	cmp ax, bx
	jnc okb
	mov ax, b
okb:
    mov bx, c
	cmp ax, bx
	jnc okc
	mov ax, c
okc:
	mov bx, d
	cmp ax, bx
	jnc okd
	mov ax, d
okd:
	mov ax, 4c00h
	int 21h
	
end main