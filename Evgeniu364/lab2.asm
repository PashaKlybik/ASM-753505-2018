model small
.stack 256
.data
    intToOut dw ?
    endline db 13,10,'$'
    result db 'Result:',13,10,'$'
    symbError db 'Invalid input',13,10,'$'
    interDiv db 'Write dividend int:',13,10,'$'
    divOn db 'Write divider int:',13,10,'$'
    zeroDiv db 'Division by zero',13,10,'$'
    ten dw 10
.code
 Input proc ;input of integer
    push ax
    push bx
    push cx
    push dx
    xor ax, ax
    xor cx, cx
    mov bx, 5
    consoleInput: 
        mov ah, 01h
        int 21h
        xor ah, ah
        cmp al, '0'
        jnae chech
        cmp al, '9'
        ja chech
        sub al, '0'
        xchg ax, cx
        mul ten        
        add ax, cx
        jc chech
        xchg ax, cx
        dec bx
        test bx, bx
        jnz consoleInput
        call NewLine
        jmp toend
    chech:
        cmp al, 13; if equals to button "Enter"
        je toend
        call NewLine
        call Error
        jmp exception
    toend:
        mov intToOut, cx
    exception:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
Input endp
 Error proc ;message for error 
    push dx
    push ax
    mov dx, offset symbError
    mov ah, 09h
    int 21h
    pop ax
    pop dx
    ret
Error endp
 NewLine proc ;go to new line
    push dx
    push ax
    mov dx, offset endline
    mov ah, 09h
    int 21h
    pop ax
    pop dx
    ret
NewLine endp
 ShowInt proc ;output of integer
    push ax
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
    divLoop:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        test ax, ax
        jnz divLoop
    showLoop:
        pop dx
        mov ah, 02h
        int 21h
        loop showLoop
    call NewLine
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ShowInt endp
 divByZero: ;if division by zero
    mov dx, offset zeroDiv
    mov ah, 09h
    int 21h
    jmp finish
 main:
    mov ax, @data
    mov ds, ax
     mov dx, offset interDiv
    mov ah, 09h
    int 21h
    call Input 
    mov ax, intToOut
    call ShowInt
    push ax
    mov dx, offset divOn
    mov ah, 09h
    int 21h
    call Input
    mov ax, intToOut
    mov bx, ax
    call ShowInt
    mov dx, offset result
    mov ah, 09h
    int 21h 
    pop ax
    test bx, bx; checkin' if divider is zero
    jz divByZero
    xor dx, dx
    div bx
    call ShowInt
    finish:
        mov ax, 4c00h    
        int 21h
end main
