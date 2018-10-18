;Division of unsigned numbers

.model small
.stack 256
.data
ten dw 10
newLine db 10,13,'$'
errorMsg db 10, 13,"Input error!", 10, 13, '$'
repeatInput db 10, 13,"Repeat input!", 10, 13, '$'
enter2 db "Enter the divisor:", 10, 13, '$'
enter1 db "Enter a dividend:", 10, 13, '$'
result db "Result:", 10, 13, '$'
remainder db "Remainder:", 10, 13, '$'
.code
PrintStr proc
    push AX
    mov AH,09h
    int 21h
    pop AX
    ret
PrintStr endp

DeleteSymbolFromDisplay proc
    push AX
    push DX

    mov AH, 03h
    int 10h

    dec DL
    mov AH, 02h
    int 10h

    mov AL, 20H
    mov AH, 0AH
    int 10h

    pop DX
    pop AX
    ret
DeleteSymbolFromDisplay endp

DeleteNumFromDisplay proc
    push AX
    push CX
    push DX

    mov AH, 03h
    int 10h

    mov BL, DL
    inc BL

    mov DL, 0
    mov AH, 02h
    int 10h

    xor CH, CH
    mov CL, BL
    mov AL, 20H
    mov AH, 0AH
    int 10h

    pop DX
    pop CX
    pop AX
    ret
DeleteNumFromDisplay endp

PrintAX proc
    push AX
    push CX
    push DX

    mov CX, 0
    pushDigit:                ;adding a character to a number on the stack 
        mov DX,0
        div ten
        add DX, '0'
        push DX
        inc CX
        cmp AX, 0
    JNZ pushDigit

    printDigit:                ;character printing
        pop DX
        mov AH, 02h
        int 21h
    LOOP printDigit

    pop DX
    pop CX
    pop AX
    ret
PrintAX endp

ReadAX proc
    push CX
    push BX
    push DX
    push SI

    mov CX, 0
    readSymbol:

        mov AH,08h            ;character reading
        int 21h

        cmp AL, 8h
        jnz deleteSymbol
        cmp CX, 0
        jz readSymbol
        pop AX
        dec CX
        call DeleteSymbolFromDisplay
        jmp readSymbol

        deleteSymbol:

        cmp AL, 1Bh
        jnz deleteNum
        cycle1:
        pop AX
        LOOP cycle1
        call DeleteNumFromDisplay
        jmp readSymbol

        deleteNum:
        
        cmp AL, 13            ;if the entered character is skipped processing of the entered character
        jz addDigitsToNum

        cmp AL, '0'            ;check for a digit
        jb error
        cmp AL, '9'
        ja error

        mov DL, AL            ;output of the entered character
        mov AH,02h
        int 21h

        mov AH, 0            ;adding a digit to the stack
        sub AL, '0'
        push AX

        inc CX            ;count of the number of digits in the number
    jmp readSymbol

    addDigitsToNum:

        mov SI, CX            ;SI - length of the num
        mov DI, 0

    cycle2:                    ;Adding number to the AX
        pop BX                ;extract a digit from the stack
            
        mov AX, SI            
        sub AX, CX    
        xor DX, DX
        call tenInDegreeAX

        cmp DX, 0
        JNZ forError

        mul BX
        add DI, AX
        JC forError

        cmp DX, 0
        JNZ forError

        jmp continue

        forError:
        dec CX
        jmp error
        continue:
    LOOP cycle2

    mov AX, DI

    pop SI
    pop DX
    pop BX
    pop CX

    jmp exit
    error:
        lea DX, errorMsg
        call PrintStr
        lea DX, repeatInput
        call PrintStr
        cmp CX, 0
        JZ readSymbol
        popDigit:
            pop AX
        LOOP popDigit
        jmp readSymbol
    exit:
    ret
ReadAX endp

TenInDegreeAX proc
    cmp AX, 0
    JZ flag1
    push CX
    mov CX, AX
    mov AX, 1
    cycle3:
        mul ten
    LOOP cycle3
    pop CX

    jmp flag2
    flag1:
    mov AX, 1
    flag2:
    ret
TenInDegreeAX endp
main:
    mov AX, @data
    mov DS, ax

    lea DX, enter1
    call PrintStr

    call ReadAX

    lea DX, newLine
    call PrintStr

    call PrintAX
    mov SI, AX

    lea DX, newLine
    call PrintStr
    lea DX, enter2
    call PrintStr

    call ReadAX

    lea DX, newLine
    call PrintStr

    call PrintAX

    cmp AX, 0
    jz main
    
    mov DI, AX

    lea DX, newLine
    call PrintStr

    lea DX, result
    mov AH,09h
    int 21h

    mov DX, 0
    mov AX, SI
    div DI
    
    call PrintAX
    
    push DX
    lea DX, newLine
    call PrintStr
    pop DX
    
    push DX
    lea DX, remainder
    mov AH,09h
    int 21h
    pop DX

    mov AX, DX

    call PrintAX

    lea DX, newLine
    call PrintStr

    mov ax, 4c00h
    int 21h
end main