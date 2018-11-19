.model small
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
    push si 
    xor si, si
    xor cx, cx
    mov bx, 5
    mov ah, 01h
    int 21h
    xor ah, ah
    cmp al, '-'
    jnz consolePostInput
    inc si

    consoleInput: 
        mov ah, 01h
        int 21h

    consolePostInput:
        xor ah, ah
        cmp al, '0'
        jnae check
        cmp al, '9'
        ja check
        sub al, '0'
        xchg ax, cx
        mul ten
        jc check    
        add ax, cx
        xchg ax, cx
        dec bx
        test bx, bx
        jnz consoleInput
        call NewLine
        jmp toEnd

    check:
        cmp al, 13; if equals to button "Enter"
        je toEnd
        call NewLine
        call Error

    toEnd:
        test si, si
        jz positive
        cmp cx, 32768
        jna stopCheckingSign
        call Error

        positive:
            cmp cx, 32767
            jna stopCheckingSign
            call Error
        stopCheckingSign:    
            test si, si
            jz preout
            neg cx

    preout:    
        mov intToOut, cx
        pop si
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
    mov ax, 4c00h    
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
    push bx
    push cx
    push dx
    push ax
    xor cx, cx
    mov bx, 10
    test ax, ax
    jns  divLoop
    mov ah, 02h
    mov dl, '-'
    int 21h
    pop ax
    push ax
    neg ax

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
    pop ax
    pop dx
    pop cx
    pop bx
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
    cmp ax, -32768
    je isMinusOne

    continue:
        cwd
        idiv bx
        call ShowInt
        finish:
            mov ax, 4c00h    
            int 21h
        isMinusOne:
            cmp bx, -1
            jne continue
            call Error
            jmp finish
end main