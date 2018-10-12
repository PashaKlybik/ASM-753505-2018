.model small
.stack 256
.data
    a dw 4
    b dw 6
    c dw 9
    d dw 5
.code
main:
    mov ax, @data
    mov ds, ax
mov bx, a
mov cx, b
mov dx, c
CMP bx, cx		; algorithm diagram
JG bigger1              ;if (a>b)
CMP bx, dx		;	if (b>c)
JG bigger2		;		if (c>d)
mov dx, d		;			min=d
CMP bx, dx		;		else min=c
JG bigger3		;	else    if (b>d)
mov ax, a		;			min=d
JMP exit		;		else min=b
bigger3:		;else   if (a>c)
mov ax, d		;		if (c>d)
JMP exit		;			min=d
bigger2:		;		else min=c
mov bx, d		;	else    if (a>d)
CMP dx,bx		;			min=d
JG bigger3		;		else min=a
MaxC:			
mov ax, c
JMP exit
bigger1:
CMP cx, dx
JG bigger4
mov dx, d
CMP cx, dx
JG bigger3
mov ax, b
JMP exit
bigger4:
JMP bigger2
JMP exit
exit:
    mov ax, 4c00h
    int 21h
end main