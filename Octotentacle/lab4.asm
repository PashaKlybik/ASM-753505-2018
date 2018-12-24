.model small
.stack 256
.data
    temp dw 0
    maxCounter dw 0
    wordsCount dw 0
    current dw 0
    maxWord db 16, 0, 16 dup('$')
    tmpWord db 16, 0, 16 dup('$')
    inpbuf db 80, 0, 80 dup('$')
    words db 50, 0, 50 dup(16 dup('$'))
    CR_LF db 0Dh, 0Ah, '$'
    TST db 'f', 'o', 'u', '$'
.code
main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    mov ah, 0Ah
    lea dx, inpbuf
    int 21h
    lea dx, CR_LF
    mov ah, 09h
    int 21h
    mov words, '$'
    mov words[0][1], '$'
    mov bx, 0
    cld
    lea si, inpbuf + 2
    mov cx, 3000
    splitToWords:
        mov al, [si]
        cmp al, ' '
        jne noSpaces
        inc si
        loop splitToWords
        noSpaces:    
        lea di, words[bx]
        @cycle:
            mov al, [si]
            cmp al, 0Dh
            je endSplit
            cmp al, ' '
            je endCycle
            mov [di], al
            inc di
            inc si
        loop @cycle 
        endCycle:    
        add bx, 16
    loop splitToWords
    endSplit:
    cmp inpbuf[2], 0Dh
    jnz notEmpty
    mov ax, 4c00h
    int 21h
    notEmpty:
    mov temp, bx
    mov bx, 16
    mov ax, temp
    xor dx, dx
    div bx
    inc ax
    cwd
    mov bx, 0
    mov maxCounter, 0
    mov wordsCount, ax
    mov cx, ax
    checkAll:
        mov ax, cx
        sub ax, wordsCount
        neg ax
        mov dx, 16
        mul dx
        mov current, ax
        mov bx, current
        lea si, words[bx]
        push cx
        mov cx, wordsCount
        mov temp, 0
        compAll:
            mov bx, current
            lea si, words[bx]
            mov ax, cx
            sub ax, wordsCount
            neg ax
            mov dx, 16
            mul dx
            mov bx, ax
            lea di, words[bx]
            push cx
            mov cx, 16
            cwd
            repe cmpsb
            pop cx
            je equal
        loop compAll
            equal:
            jcxz skipper2
            inc temp
        loop compAll
        skipper2:
        mov bx, temp
        mov cx, maxCounter
        cmp bx, cx
        pop cx
        ja updateMax
    loop checkAll
    jcxz skipper
    updateMax:
        mov bx, current
        lea si, words[bx]
        lea di, maxWord
        push cx
        mov cx, 16
        cwd
        rep movsb
        mov cx, temp
        mov maxCounter, cx
        pop cx
    loop checkAll
    skipper:
    mov ah, 09h
    lea dx, maxWord
    int 21h
    mov ah, 09h
    lea dx, CR_LF
    int 21h
    mov ax, 4c00h
    xor dx, dx
    int 21h
    ret
end main