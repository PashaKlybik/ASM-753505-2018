.model small
.stack 256
.data
    lenth db 0
    sign db 0
    border dw 32768
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

setsign:
    inc sign
    inc border
    inc lenth
    jmp read

ReadProc proc
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
    jmp WrongChar
    
    nextstep3:
    cmp al, '9'+1
    jnc WrongChar
    sub al, '0'
    xor ah, ah
    mov bx, ax
    inc lenth
    jmp read
    
    read:
    mov ah, 01h
    int 21h
    cmp al, 13
    jne nextstep2
    jmp exit
    
    nextstep2:
    cmp al, 8
    je backspace
    cmp al, '0'
    jc WrongChar
    cmp al, '9'+1
    jnc WrongChar
    sub al, '0'
    xor ch, ch
    mov cl, al
    mov ax, bx
    xor dx, dx
    mul ten
    cmp dx, 1
    jnc WrongChar
    cmp ax, border
    jnc WrongChar
    add ax, cx
    cmp ax, border
    jnc WrongChar
    mov bx, ax
    inc lenth
    jmp read

    backspace:
    cmp lenth, 0
    je FirstInput
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
    dec lenth
    cmp lenth, 0
    je revsign
    jmp read

    WrongChar:
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    mov ah, 02h
    int 21h
    jmp read

    revsign:
    pop border
    push border
    mov ax, 0
    mov sign, al
    mov dl, ' '
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
ReadProc endp

WriteProc proc
    push bx
    push cx
    push dx
    xor bx, bx
    cmp ax, border
    jnc showsign
    
    dividing:   ; pushing digits of number in stack
        xor dx, dx
        div ten
        push dx
        inc cx
        cmp ax, 0
    jne dividing   
    
    print:
        pop dx
        add dx, '0'
        mov ah, 02h
        int 21h
    loop print
    
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
    jmp dividing
WriteProc endp

start:
    mov ax, @data
    mov ds, ax

    call ReadProc
    mov dividend, ax
    call WriteProc
    
    call ReadProc
    mov divisor, ax
    call WriteProc
    
    xor dx, dx
    mov ax, dividend
    cmp ax, border
    cmp divisor, 0
    je caseerror
    cmp divisor, -1
    je error
	
    nextstep4:
    cwd
    idiv divisor
    cmp dx, border
    jnc changerem
	
    nextstep5:
    push dx
    lea dx, resultMessage
    call WriteMessage
    pop dx
    call WriteProc
    mov ax, dx
    lea dx, remainderMessage
    call WriteMessage
    call WriteProc
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
  
    error:
    mov cx, border
    cmp dividend, cx
    jc nextstep4
	
    caseerror:
    lea dx, errorMesssage
    mov ah, 09h
    int 21h
	
    toend:
    mov ah, 01h
    int 21h
    mov ax, 4c00h
    int 21h
end start
