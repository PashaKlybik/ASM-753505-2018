.model small
.stack 256
.data
    a dw 10
    b dw 2
	c dw 1
	d dw 34
    message db 'Hello world!', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax
    
    mov ax, a
    mov bx, c
	mul bx
	mov cx, ax
	mov ax, b
	mov bx, d
	mul bx
	add cx, ax
	push cx
	
	mov ax, a
	mul bx
	mov cx, ax
	mov ax, b
	mov bx, c
	mul bx
	add cx, ax ; cx = a * d + b * c
	pop bx ; bx = a * c + b * d
	
	cmp bx, cx
	je equals
	mov ax, a
	mov bx, c
	cmp ax, bx
	jg AGreaterThanC
	mov bx, b
	mov cx, c
	or bx, cx
	mov ax, a
	sub ax, bx
	jmp exit
	
  AGreaterThanC:
	mov ax, c
	mov bx, b
	and ax, bx
	jmp exit
	
  equals:
	mov ax, a
	mul ax
    
  exit:
    mov ax, 4c00h
    int 21h
end main