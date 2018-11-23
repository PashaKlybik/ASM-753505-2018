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
jne if_not_equal

mov  ax, c
add  ax, b

cmp  d, ax
jng if_no_great
	mov ax, c
	xor dx, dx
	div d
	add ax, dx
	jmp  end_if
if_no_great:
	mov  ax, c
	xor  ax, d
	jmp end_if
if_not_equal:
	mov ax, b
	mov dx, b
	inc dx
	or ax, dx
end_if:
mov ax, 4c00h
int 21h
end
