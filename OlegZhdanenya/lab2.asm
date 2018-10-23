.model small
.stack 256
.data
    dividend dw ?
    divisor dw ?
    ten dw 10
    errorMesssage db "Error$"
    resultMessage db "Result: $"
    remainderMessage db "Remainder: $"
    
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
    mov ah, 01h  ;reading char
    int 21h
    
    cmp al, 13 ;if al==13(enter)
    je exit
    
    cmp al, '0'  ;if al<'0'
    jc wrongChar
    
    cmp al, '9' ; if al>'9'
    ja wrongChar
    
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
    
  wrongChar:   ;if wrongCharInput clear and "reRead"
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
    push cx
    push dx
    xor cx, cx
    
  dividing:   ; pushing digits of number in stack
    xor dx, dx
    div ten
    push dx
    inc cx
    cmp ax, 0
    jne dividing
    
  printing: ; poping digits of number from stack to print
        pop dx
        add dx, '0'  ;adding '0' to get code of digit
    
        mov ah, 02h
        int 21h
    
    loop printing
    
    mov dl, 10
    
    mov ah, 02h
    int 21h
    
    pop dx
    pop cx
    ret
PrintProc endp
start:
    mov ax, @data
    mov ds, ax
    
    call ReadProc    ;reading and printing dividend
    mov dividend, ax
    call PrintProc
    
    call ReadProc   ;reading and printing divisor
    mov divisor, ax  
    call PrintProc
    
    cmp divisor, 0  ;dividingByZeroException
    je error
    
    mov ax, dividend
    
    lea dx, resultMessage
    call WriteMessage
    
    xor dx, dx
    
    div divisor
    mov bx, dx
    call PrintProc
    
    lea dx, remainderMessage
    call WriteMessage
    
    mov ax, bx
    call PrintProc
    
    jmp finish
    
error:
    lea dx, errorMesssage
    mov ah, 09h
    int 21h
    
finish:
    mov ah, 01h
    int 21h
    mov ax, 4c00h
    int 21h
end start