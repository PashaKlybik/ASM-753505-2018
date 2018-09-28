.model small
.stack 256
.data
    dividend dw ?
    divisor dw ?
    ten dw 10
    errmes db "Error", '$'
.code

MyInput proc
    push bx
    push cx
    push dx
    xor ax, ax
    xor bx, bx
    xor dx, dx
Input:
    mov ah, 01h
    int 21h
    cmp al, 13
    je exit
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
    mul ten
    cmp dx, 1
    jnc ErrChar
    add ax, cx
    jc ErrChar
    mov bx, ax
    jmp Input

backspace:
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

exit:
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
    cmp divisor, 0
    je caseerr
    mov ax, dividend
    xor dx, dx
    div divisor
    call MyOutput
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
