.8086
.model small
.stack 10
.data
	a dw 1
	b dw 2
	c dw 7
	d dw 6
	
.code
mov ax,@data
mov ds,ax
mov ax, a
mov dx, a
dec dx
and ax, dx
cmp ax, b
jne loop1

mov  ax, c
add  ax, b

cmp  d, ax
jna loop2
	mov ax, c
	mov dx, 0
	div d
	add ax, dx
	jmp short end_if
loop2:
	mov  ax, c
	xor  ax, d
	jmp short end_if
loop1:
	mov ax, b
	mov dx, b
	inc dx
	or ax, dx
end_if:
mov ax, 4c00h
int 21h
end
