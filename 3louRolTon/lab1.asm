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

	mov ebx, eax
	
	mov ax, c
	mov cx, b
	mul cx
	
	cmp ebx, eax
	je result1
	
	jmp result3

result1:

	mov ax, d
	mov cx, b
	div cx

	cmp ebx, eax
	je result2
	mov bx, c
	jmp finish

result2:
	mov ax, a
	mov cx, b
	or ax, cx
	mov bx, c
	jmp finish

result3:
	mov ax, c
	mul a
	sub ax, b
	mov ebx, eax
	jmp finish
	
finish:
    mov ax, 4c00h
    int 21h
end main
