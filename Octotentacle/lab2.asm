.model small
.stack 256
.data
 a dw ?
 b dw ?
	c dw ?
	d dw ?
	tn dw ?
	checker dw 0
	inpbuf db 7, 0, 7 dup(0)
	CR_LF db 0Dh, 0Ah, '$'
.code
main:
 mov ax, @data
 mov ds, ax
	call IntInput
	mov ax, tn
	mov a, ax
	call IntInput
	mov ax, tn
	mov b, ax
	mov ax, a
	mov bx, b
	xor dx, dx
	div bx
	call IntOut
	mov ax, 4c00h
	int 21h
	ret
	
IntOut proc
	push ax
	push bx
	push cx
	push dx
	xor cx, cx
	mov bx, 10 
splitToNums:
	xor dx,dx
	div bx
	push dx
	inc cx
	test ax, ax
	jnz splitToNums
	mov ah, 02h
outNums:
	pop dx
	add dl, '0'
	int 21h
	loop outNums
	lea dx, CR_LF
	mov ah, 09h
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
IntOut endp
	
IntInput proc
	push ax
	push dx
	mov ah, 0Ah
	mov dx, offset inpbuf
	int 21h
	lea dx, CR_LF
 mov ah, 09h
 int 21h
	lea si, inpbuf+1
	lea di, tn
	call StrToNum
	pop dx
	pop ax
	ret
IntInput endp
	
StrToNum proc
	push ax
	push bx
	push cx
	push dx
	push ds
	push es
	push ds
	pop es
	mov cl, ds:[si]
	xor ch, ch
	inc si
	mov bx, 10
	xor ax, ax
cycle1:
	mul bx 
	mov [di], ax 
	cmp dx, 0 
	jnz errr
	mov al, [si] 
	cmp al, '0'
	jb errr
	cmp al, '9'
	ja errr
	sub al, '0'
	xor ah, ah
	add ax, [di]
	jc errr 
	inc si
	loop cycle1
	mov [di], ax
	clc 
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
	ret
errr:
	xor ax, ax
	mov [di], ax
	stc 
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
	ret
StrToNum endp

end main