.model small
.stack 256
.data
    a dw 14
    b dw 58
	c dw 24
	d dw 18
.code
main:
    mov ax, @data
    mov ds, ax
    
	mov AX,a
	mov BX,b

	mov DI, AX
	add DI, 1
	or AX, DI
	cmp AX, BX

	JNZ flag1

	mov AX, a
	mul BX
	mul BX
	mov CX, d
	div CX
	mov AX, DX
	jmp exit

	flag1:
	
	mov AX, a
	and AX, b
	mov CX, c
	or CX, d
	cmp AX,CX

	JNZ flag2

	mov DI, b
	sub DI, 1
	and BX, DI
	mov AX, BX
	jmp exit

	flag2:

	mov AX, c
	mov DX, 0
	div d


	mov CX,DX
	mov AX, a
	mul BX
	add AX,CX

	exit:
    mov ax, 4c00h
    int 21h
end main