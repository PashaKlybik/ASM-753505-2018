.model small
.stack 256
.data
	a dw 39
	b dw 25
	c dw 67
	d dw 18
.386
.code
main:
	mov ax, @data
	mov ds, ax
	
	mov ax, b
	mov cx, a
	
	mul cx
	mov ebx, eax
	
	mov ax, c
	mov cx, b
	
	mul cx
	
	cmp ebx, eax
	jg ebxgeax1
	mov ebx, eax

ebxgeax1:
	mov ax, d
	mov cx, c
	mul cx
	cmp ebx, eax
	jg ebxgeax2
	mov ebx, eax

ebxgeax2:
	mov ax, a
	mov cx, d
	mul cx
	cmp ebx, eax
	jg ebxgeax3
	mov ebx, eax

ebxgeax3:
	mov eax, ebx
	
    mov ax, 4c00h
    int 21h
end main

	