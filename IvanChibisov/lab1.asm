.model small
.stack 256
.data
    a dw 1
    b dw 2
    c dw 2
    d dw 2
.code
main:
    mov ax, @data
    mov ds, ax
    
		mov bx, a
		mov cx, b
		mov dx, c
		CMP bx, cx
		JNC bigger1
		CMP bx, dx
		JNC bigger2
		mov dx, d
		CMP bx, dx
		JNC bigger3
		mov ax, a
		JMP exit
	bigger3:
		mov ax, d
		JMP exit
	bigger2:
		mov bx, d
		CMP dx,bx
		JNC bigger3
	MaxC:
		mov ax, c
		JMP exit
	bigger1:
		CMP cx, dx
		JNC bigger4
		mov dx, d
		CMP cx, dx
		JNC bigger3
		mov ax, b
		JMP exit
	bigger4:
		JMP bigger2
		JMP exit
    
	exit:

    mov ax, 4c00h
    int 21h
end main