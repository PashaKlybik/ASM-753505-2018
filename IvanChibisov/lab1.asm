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
CMP bx, cx
JG bigger1
CMP bx, dx
JG bigger2
mov dx, d
CMP bx, dx
JG bigger3
mov ax, a
JMP exit
bigger3:
mov ax, d
JMP exit
bigger2:
mov bx, d
CMP dx,bx
JG bigger3
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