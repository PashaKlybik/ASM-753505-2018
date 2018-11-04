.model small
.stack 256
.data
    welcome db "Enter the string: ", 10, '$'
    answer db "Words with two consecutive vowels: ", 10, '$'
    vowelsLength dw 12
    vowels db "aeiouyAEIOUY"
    spaceSymbolsLength dw 5
    spaceSymbols db " ,.!?"
    sourceLength db 254
    currentSourceLength db 0 
    source db 255 dup (?)
.code

    isSpaceSymbol proc
        push cx
        mov cx, spaceSymbolsLength
        lea di, spaceSymbols
        cld
        repnz scasb
        jnz spaceExit
        mov al, 0 ;if space sumbol has found
    spaceExit:
        pop cx
        ret
    isSpaceSymbol endp

    isVowel proc
        push cx
        mov cx, vowelsLength
        lea di, vowels
        cld 
        repnz scasb    
        jnz ifNotVowelExit
        mov al, 0 ; if al is a vowel
    ifNotVowelExit:
        pop cx
        ret
    isVowel endp
    
    wordsWithTwoVowels proc
        push ax
        push bx ;counter of letters in the word
        push cx
        push dx ;counter of vowels 
        push si
        push di ; push in order to don't push this regester in isVowel and isSpaceSymbol procedures
        lea si, source
        xor ch, ch
        mov cl, currentSourceLength
        xor dx, dx ; xor only bl, because length of all string cann't be more than 255
        xor bx, bx
        cld
        getSymbol:
            lodsb
            call isSpaceSymbol
            cmp al, 0
            jnz notSpace
            cmp dx, 2
            jnz next
            call printWord
        next:
            xor bx, bx
            xor dx, dx
            jmp toLoopEnd
        notSpace:
            inc bx
            cmp dx, 2 ; if vowels amount >= 2, others shouldn't be checked
            jz toLoopEnd
            call isVowel
            cmp al, 0
            jnz notVowel
            inc dx
            jmp toLoopEnd
        notVowel:    
            xor dx, dx
        toLoopEnd:    
            loop getSymbol
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret    
    wordsWithTwoVowels endp
    
    stringInput proc ;i know you can do it easier
        push ax
        push di
        push dx
        mov currentSourceLength, 0 ; if you want to use it several times
        lea dx, sourceLength
        mov ah, 0Ah
        int 21h
        lea di, source
        xor ah, ah
        mov al, currentSourceLength
        add di, ax
        mov al, ' ' 
        inc currentSourceLength
        stosb
        pop dx
        pop di
        pop ax
        ret
    stringInput endp
    
    printWord proc
        push ax
        push cx
        push dx
        sub si, bx
        dec si ; space has been counted
        mov cx, bx
        mov ah, 02h
        output_loop:
            mov dx, [si]
            int 21h
            inc si
            loop output_loop
        mov dl, 10
        int 21h
        inc si ; in order to return in previous position
        pop dx
        pop cx
        pop ax
        ret
    printWord endp
    
    printSymbol proc
        push ax
        mov ah, 02h
        int 21h
        pop ax
        ret
    printSymbol endp
    
    printString proc
        push ax
        mov ah, 09h
        int 21h
        pop ax
        ret
    printString endp
        
main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    lea dx, welcome
    call printString
    call stringInput
    mov dl, 10
    call printSymbol
    lea dx, answer
    call printString
    call wordsWithTwoVowels
    
    mov ax, 4c00h
    int 21h
end main