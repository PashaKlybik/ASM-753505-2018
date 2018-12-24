.model small
.stack 256
.data
    dividend dw ?
    divisor dw ?
    ten dw 10
    len db 0
    sign db 0
    border dw 32768
    errmes db "Error", '$'
    mesDividend db "Dividend: $"
    mesDivisor db "Divisor: $"
    mesQuotient db 10,"Quotient: $"
    mesRemainder db "Remainder: $"
.code

WriteMes proc
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret
WriteMes endp

setsign:
    inc sign
    inc border
    jmp Input

MyInput proc
    push bx
    push cx
    push dx
    push border
    xor bx, bx
    xor dx, dx
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
    pop border
    push border
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
    mov ax, 0
    mov sign, al
    mov ax, bx
    pop border
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
    lea dx, mesDividend
    call WriteMes
    call MyOutput
    call MyInput
    mov divisor, ax
    lea dx, mesDivisor
    call WriteMes
    call MyOutput
    xor dx, dx
    mov ax, dividend
    cmp ax, border
    cmp divisor, 0
    je caseerr
    cmp divisor, -1
    je err1
nextstep4:
    lea dx, mesQuotient
    call WriteMes
    cwd
    idiv divisor
    cmp dx, border
    jnc changerem
nextstep5:
    call MyOutput
    mov ax, dx
    lea dx, mesRemainder
    call WriteMes
    call MyOutput
    jmp toend

changerem:
    mov bx, divisor
    cmp bx, border
    jc decquot
    sub dx,bx
    inc ax
    jmp nextstep5
decquot:
    add dx, bx
    dec ax
    jmp nextstep5
    
err1:
    mov cx, border
    cmp dividend, cx
    jc nextstep4
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