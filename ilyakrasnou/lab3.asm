.model small
.stack 256
.data
    dividend dw 42
    divisor dw 42
	ten dw 10
	len db 0
	sign db 0
	border dw 32768
	errmes db "Error", '$'
.code

setsign:
	inc sign
	inc border
	jmp Input

MyInput proc
	push bx
	push cx
	push dx
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	mov ax, 32768
	mov border, ax
	mov ax, 0
	mov sign, al
FirstInput:
	mov ah, 01h
	int 21h
	cmp al, '-'
	je setsign
	cmp al, 13
	jne nextstep1
	jmp exit
nextstep1:
	cmp al, 8
	je backspace
	cmp al, '0'
	jnc nextstep3
	jmp ErrChar
nextstep3:
	cmp al, '9'+1
	jnc ErrChar
	sub al, '0'
	xor ah, ah
	mov bx, ax
	inc len
	jmp Input
  Input:
	mov ah, 01h
	int 21h
	cmp al, 13
	jne nextstep2
	jmp exit
nextstep2:
	cmp al, 8
	je backspace
	cmp al, '0'
	jc ErrChar
	cmp al, '9'+1
	jnc ErrChar
	sub al, '0'
	xor ch, ch
	mov cl, al
	mov ax, bx
	xor dx, dx
	mul ten
	cmp dx, 1
	jnc ErrChar
	cmp ax, border
	jnc ErrChar
	add ax, cx
	cmp ax, border
	jnc ErrChar
	mov bx, ax
	inc len
	jmp Input

backspace:
	cmp len, 0
	je revsign
	mov dl, ' '
	mov ah, 02h
	int 21h
	mov dl, 8
	mov ah, 02h
	int 21h
	mov ax, bx
	xor dx, dx
	div ten
	mov bx, ax
	dec len
	cmp len, 0
	je revsign
	jmp Input

  ErrChar:
	mov dl, 8
	mov ah, 02h
	int 21h
	mov dl, ' '
	mov ah, 02h
	int 21h
	mov dl, 8
	mov ah, 02h
	int 21h
	jmp Input

revsign:
	mov ax, 32768
	mov border, ax
	mov ax, 0
	mov sign, al
	mov dl, ' '
	mov ah, 02h
	int 21h
	mov dl, 8
	mov ah, 02h
	int 21h
	jmp FirstInput

  reverse:
    neg bx
	jmp next
	
	exit:
	cmp sign, 1
	jnc reverse
  next:
    mov ax, 32768
	mov border, ax
	mov ax, 0
	mov sign, al
	mov ax, bx
	pop dx
	pop cx
	pop bx
	ret
MyInput endp

MyOutput proc
	push bx
	push cx
	push dx
	xor bx, bx
	xor cx, cx
	cmp ax, border
	jnc showsign
  DivCycle:
    xor dx, dx
	div ten
	push dx
	inc bx
	mov cx, ax
	inc cx
	loop DivCycle
	mov cx, bx
  Output:
	pop dx
	add dx, '0'
	mov ah, 02h
	int 21h
	loop Output
	mov dl, 10
	mov ah, 02h
	int 21h
	pop dx
	pop cx
	pop bx
	ret
showsign:
	push ax
	mov dl, '-'
	mov ah, 02h
	int 21h
	pop ax
	neg ax
	jmp DivCycle
MyOutput endp

start:
    mov ax, @data
    mov ds, ax

	mov ax, dividend
	call MyInput
	mov dividend, ax
	call MyOutput
	call MyInput
	mov divisor, ax
	call MyOutput
	xor dx, dx
	mov ax, dividend
	cmp ax, border
	cwd
	cmp divisor, 0
	je caseerr
	cmp divisor, -1
	je err1
nextstep4:
	idiv divisor
	call MyOutput
	jmp toend

err1:
	mov cx, border
	cmp dividend, cx
	jc nextstep4
	mov ah, 02h
	mov dl, '3'
	int 21h
	mov dl, '2'
	int 21h
	mov dl, '7'
	int 21h
	mov dl, '6'
	int 21h
	mov dl, '8'
	int 21h
	jmp toend
caseerr:
	lea dx, errmes
	mov ah, 09h
	int 21h
toend:
	mov ah, 01h
	int 21h
    mov ax, 4c00h
    int 21h
end start