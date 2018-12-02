.model small
.stack 256
.data
    N dw ?
    M dw ?
    A dw ?
    intToOut dw ?
    ten dw 10
    matrix dw 600 dup(0)
    helloMessage db 'This program sets all elements that greater than A to value of 0', 13, 10, '$'
    nMessage db 'Write N number:', 13, 10, '$'
    mMessage db 'Write M number:', 13, 10, '$'
    aMessage db 'Write A number:', 13, 10, '$'
    matrixMessage db 'Write your matrix elements:', 13, 10, '$'
    showFirstMatrix db 'Your matrix:', 13, 10, '$'
    showResult db 'Program result:', 13, 10, '$'
    symbError db 'Invalid input', 13, 10, '$'
    endline db 13, 10, '$'
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
        continueSmth:
            pop si
            pop cx
            pop bx
            pop ax
            ret
Input endp

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
    pop ax
    pop dx
    pop cx
    pop bx
    ret
ShowInt endp

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

nInput proc ; input of N
    push ax
    call Input
    mov ax, intToOut
    jns ok
    call Error
    ok:
        cmp al, 0
        jne absEnd
        call Error
        absEnd:
            mov N, ax
            pop ax
            ret
nInput endp

mInput proc ; input of M
    push ax
    call Input
    mov ax, intToOut
    jns mok
    call Error
    mok:
        cmp al, 0
        jne mAbsEnd
        call Error
        mAbsEnd:
            mov M, ax
            pop ax
            ret
mInput endp

aInput proc ; input of A
    push ax
    call Input
    mov ax, intToOut
    mov A, ax
    pop ax
    ret
aInput endp

matrixInput proc ; input of matrix
    push ax
    push si
    push cx
    xor si, si
    lea dx, matrixMessage
    mov ah, 09h
    int 21h
    mov ax, N
    mul M
    xor cx, cx
    mov cx, ax
    xor ax, ax
    superLoop:
        call Input
        mov ax, intToOut
        mov matrix[si], ax
        inc si
        inc si
        loop superLoop
    pop cx
    pop si
    pop ax
    ret
matrixInput endp

matrixOutput proc ; output of matrix
    push ax
    push cx
    push si
    push dx
    xor si, si
    mov cx, M
    rowLoop:
        push cx
        mov cx, N
        columnLoop:
            xor ax, ax
            mov ax, matrix[si]
            call ShowInt
            mov dl, 32
            mov ah, 02h
            int 21h
            inc si
            inc si
        loop columnLoop
        call NewLine
        pop cx
    loop rowLoop
    pop dx
    pop si
    pop cx
    pop ax
    ret
matrixOutput endp

compareWithA proc; main task
    push ax
    push cx
    push bx
    push si
    mov ax, N
    mul M
    xor bx, bx
    xor si, si
    xor cx, cx
    mov bx, A
    mov cx, ax
    compareLoop:
        xor ax, ax
        cmp matrix[si], 0
        je doAnyway
        cmp matrix[si], bx
        jle stp
        doAnyway:
            mov matrix[si], 0
            stp:
                inc si
                inc si
    loop compareLoop
    pop si
    pop bx
    pop cx
    pop ax
    ret
compareWithA endp

main:
    mov ax, @data
    mov ds, ax

    call NewLine
    lea dx, helloMessage
    mov ah, 09h
    int 21h
    call NewLine

    lea dx, nMessage
    mov ah, 09h
    int 21h
    call nInput

    lea dx, mMessage
    mov ah, 09h
    int 21h
    call mInput

    lea dx, aMessage
    mov ah, 09h
    int 21h
    call aInput

    call matrixInput

    call NewLine
    lea dx, showFirstMatrix
    mov ah, 09h
    int 21h
    call matrixOutput
    call NewLine

    call NewLine
    lea dx, showResult
    mov ah, 09h
    int 21h
    call compareWithA
    call matrixOutput
    call NewLine

    mov ax, 4c00h
    int 21h
end main
