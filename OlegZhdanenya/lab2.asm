.model small
.stack 256
.data
    dividend dw ?
    divisor dw ?
    ten dw 10
    errormesssage db "Error$"
    resultmessage db "Result: $"
.code
WriteMessage proc
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret
WriteMessage endp
ReadProc proc
    push bx
    push cx
    push dx
    xor bx, bx
  reading:
    mov ah, 01h
    int 21h
    cmp al, 13
    je exit
    cmp al, 8
    cmp al, '0'
    jc wrongChar
    cmp al, '9'+1
    jnc wrongChar
    sub al, '0'
    xor ch, ch
    mov cl, al
    mov ax, bx
    xor dx, dx
    mul ten
    cmp dx, 1
    jnc wrongChar
    add ax, cx
    jc wrongChar
    mov bx, ax
    jmp reading
  wrongChar:
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    mov ah, 02h
    int 21h
    jmp reading
  exit:
    mov ax, bx
    pop dx
    pop cx
    pop bx
    ret
ReadProc endp
PrintProc proc
    push bx
    push cx
    push dx
    xor bx, bx
  DivCycle:
    xor dx, dx
    div ten
    push dx
    inc bx
    mov cx, ax
    inc cx
    loop DivCycle
    mov cx, bx
  printing:
    pop dx
    add dx, '0'
    mov ah, 02h
    int 21h
    loop printing
    mov dl, 10
    mov ah, 02h
    int 21h
    pop dx
    pop cx
    pop bx
    ret
PrintProc endp
start:
    mov ax, @data
    mov ds, ax

    mov ax, dividend
    call ReadProc
    mov dividend, ax
    call PrintProc
    call ReadProc
    mov divisor, ax  
    call PrintProc
    cmp divisor, 0
    je caseerror
    mov ax, dividend
    lea dx, resultmessage
    call WriteMessage
    xor dx, dx
    div divisor
    call PrintProc
    jmp finish
caseerror:
    lea dx, errormesssage
    mov ah, 09h
    int 21h
finish:
    mov ah, 01h
    int 21h
    mov ax, 4c00h
    int 21h
end start
