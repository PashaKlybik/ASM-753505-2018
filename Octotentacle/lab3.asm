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
	call IntInput
	mov bx, tn
	cwd
	idiv bx
	xor dx, dx
	call SIntOut
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
	call SStrToNum
	pop dx
	pop ax
	ret
IntInput endp

SIntOut proc
	push bx
	push cx
	push dx
	push ax
	mov bx, 10
	xor cx, cx
	test ax, ax
	jns cycl
	mov ah, 02h
	mov dx, '-'
	int 21h
	pop ax
	push ax
	neg ax
cycl:
	call IntOut
	pop ax
	pop dx
	pop cx
	pop bx
	ret
SIntOut endp

SStrToNum proc
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
    mov bl, [si]
    cmp bl, '-'
    jne @cycl
    mov checker, 1
    inc si
    dec cl
@cycl:
	mov bx, 10
	mul bx        
	mov [di], ax  
	cmp dx, 0     
	jnz error   
	mov al, [si]   
	cmp al, '0'
	jb  error
	cmp al, '9'
	ja  error
	sub al, '0'
	xor ah, ah
	add ax, [di]
	jc  error    
	inc si   
	loop @cycl
	cmp checker, 1
	jne notNegative
	neg ax
notNegative:
	mov [di], ax
	mov checker, 0
	clc
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
	ret
error:
	mov checker, 0
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
SStrToNum endp
end main