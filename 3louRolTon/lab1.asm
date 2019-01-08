.model small
.stack 256
.data
	a dw 2
	b dw 4
	c dw 1
	d dw 9
.386
.code
main:
	mov ax, @data
	mov ds, ax

start:
	mov ax, a
	mul ax

	mov bx, ax
	
	mov ax, c
	mov cx, b
	mul cx
	
	cmp bx, ax
	je result1
	
	jmp result3

result1:

	mov ax, d
	mov cx, b
	div cx

	cmp bx, ax
	je result2
	mov ax, c
	jmp finish

result2:
	mov ax, a
	mov cx, b
	or ax, cx
	jmp finish

result3:
	mov ax, c
	mul a
	sub ax, b
	jmp finish
	
finish:
    mov ax, 4c00h
    int 21h
end main
