.model small
.stack 256
.data
    messageDivident db "Enter a dividend: ", 10, '$'
    messageDivider db "Enter a divider: ", 10, '$'
    messageRemainder db "Remainder: ", 10, '$'
    messageoutput db "You have entered: ", 10, '$'
    messageDivideByZero db "Error. Division by zero", 10, '$'
    messageOveflow db "Overflow", 10, '$'
    messageAnswer db "Answer: ", 10, '$'
    minus dw ?
    number dw ? ; push pop slower
    maxPositive dw 32767
    maxNegative dw 32768
    ten dw 10
.code

    input proc
        push bx
        push cx
        push dx
        
        xor cx, cx ; cx == counter
        xor ax, ax
        mov number, 0
        mov minus, 0
        
        inp:
            mov ah, 01h
            int 21h
            
            cmp al, 13
            jz goToFinishLabel
            cmp al, 8
            jz goToBackspaceLabel
            cmp al, 27;escape
            jz goToEscapeLabel
            cmp al, '-'
            jnz positiveNumber
            cmp cx, 0
            jnz deleteSymbol
            mov minus, '-'
            inc cx
            jnp inp
            
        positiveNumber:
            cmp al, '0'
            jc deleteSymbol
            cmp al, '9'
            ja deleteSymbol
            xor bx, bx
            mov bl, al
            sub bl, '0'
            mov ax, number
            mul ten
            jc deleteSymbol
            add ax, bx
            
            cmp minus, '-'
            jnz positive
                cmp ax, maxNegative
                jmp nextStep
            positive:
                cmp ax, maxPositive
            nextStep:
                ja deleteSymbol
                mov number, ax
                inc cx
                jmp inp
                
            ;labels
            jmp labelsList
            goToFinishLabel:
            jmp finish
            goToBackspaceLabel:
            jmp backspace
            goToEscapeLabel:
            jmp escape
            inputLabel:
            jmp inp
            labelsList:
                
        deleteSymbol:
            mov ah, 02h
            mov dl, 8
            int 21h
            mov dl, ' '
            int 21h
            mov dl, 8
            int 21h
            jmp inputLabel
            
        backspace:
            cmp cx, 0
            jz inputLabel
            cmp cx, 1
            jnz notMinus
            cmp minus, '-'
            jnz notMinus
            mov minus, 0
            jmp deleting
            
        notMinus:
            xor dx, dx
            mov ax, number
            div ten
            mov number, ax
        
        deleting:
            mov ah, 02h
            mov dl, ' '
            int 21h
            mov dl, 8
            int 21h
            dec cx
            jmp inputLabel
            
        escape:
            mov ah, 02h
            mov dl, 13
            int 21h
            cmp cx, 0
            jz escapeEnd
            mov minus, 0
            mov dl, ' '
            deleteAllSymbols:
                int 21h
                loop deleteAllSymbols
            escapeEnd:
            int 21h
            mov dl, 13
            int 21h
            mov number, 0
            jmp inputLabel
            
        finish:
            mov ax, number
            cmp minus, '-'
            jnz toExit
            neg ax
            toExit:
            mov minus, 0
            pop dx
            pop cx
            pop bx
            ret        
    input endp

    output proc
        push bx
        push cx
        push dx
        xor cx, cx
        mov number, ax
        mov minus, 0
        
        cmp ax, maxPositive
        jna NumberInStack
        neg ax
        mov dl, '-'
        call write
        
        NumberInStack:
            xor dx, dx
            div ten
            push dx
            inc cx
            cmp ax,0
            jnz NumberInStack
            
        mov ah, 02h
        Print:
            pop dx
            add dx, '0'
            int 21h
            loop Print
        
        mov dl, 10
        call write
        pop dx
        pop cx
        pop bx
        mov ax, number
        ret
    output endp
    
    write proc
        push ax
        mov ah, 02h
        int 21h
        pop ax
        ret
    write endp
    
    writeString proc
        push ax
        mov ah, 09h
        int 21h
        pop ax
        ret
    writeString endp
    
main:
    mov ax, @data
    mov ds, ax    
    
    lea dx, messageDivident
    call writeString
    call input
    lea dx, messageoutput
    call writeString
    call output
    
    mov bx, ax ;dividend
    
    lea dx, messageDivider
    call writeString
    call input
    lea dx, messageoutput
    call writeString
    call output
    
    cmp ax, 0
    jz divideByZero
    mov cx, ax
    mov ax, bx
    mov bx, 0
    cmp cx, -1
    jz divideOnMinusOne
    cmp cx, 1
    jz answeroutput
    cwd

    idiv cx ;cx = divider
    mov bx, dx
    cmp bx, maxPositive ;finding remainder
    jna answeroutput
    cmp cx, maxPositive
    jna addDivider
    sub bx, cx
    inc ax
    jmp answeroutput
addDivider:
    add bx, cx
    dec ax
answeroutput:
    lea dx, messageAnswer
    call writeString
    call output
    lea dx, messageRemainder
    call writeString
    mov ax, bx

    call output
    jmp exit
    
    divideOnMinusOne:
        neg ax
        cmp ax, maxPositive
        ja overflow
        jmp answeroutput
        
    divideByZero:
        lea dx, messageDivideByZero
        call writeString
        jmp exit
    
    overflow: 
        lea dx, messageOveflow
        call writeString
        
    exit:
    mov ax, 4c00h
    int 21h
end main