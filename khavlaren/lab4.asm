.model small
.386
.stack 100h
.data
    maxLine db 254
    len db 0
    line db 254 dup('$')
    
    messageMax db "The longest word is $"
    messageMin db "The shortest word is $"
    newLine db 10, 13, '$'
    
    maxLength dw 0
    minLength dw 254
    maxIndex dw 0
    minIndex dw 0
    
    minWord db 100 dup('$')
    maxWord db 100 dup('$')
.code

PrintNewLine PROC
    PUSH AX
    PUSH DX
    LEA DX, newLine
    MOV AH, 09h
    INT 21h
    POP DX
    POP AX
    RET
PrintNewLine ENDP

Output PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX
    MOV BX, 10
    
DivCycle:
    XOR DX, DX
    DIV BX
    PUSH DX			; Остаток от деления на 10 (т.е. последнюю цифру) кладём в стек.
    INC CX
    CMP AX, 0
    JNZ DivCycle
    
OutCycle:
    POP DX			; CX раз (число цифр в десятичной записи числа) берем из стека цифры и выводим на экран,
    ADD DL, '0'		; добавив при этом символ нуля (его код).
    MOV AH, 02h
    INT 21h
    LOOP OutCycle
    
    CALL PrintNewLine
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Output ENDP

main:

    MOV AX, @data
    MOV DS, AX
    MOV ES, AX
    
    ; Input.
    LEA DX, maxLine
    MOV AH, 0Ah
    INT 21h
    CALL PrintNewLine
    LEA DX, line
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine
    MOV AL, len
    XOR AH, AH
    CALL Output
    
    ; Processing.
    LEA SI, line
    MOV CX, AX					; Счётчик длины строки. (В AX сейчас находится len)
    XOR BX, BX					; Длина текущего слова.
    CLD
StringCycle:
    LODSB						; В AL текущий символ, переход на следующий символ.
    CMP AL, ' '
    JZ BlankSpace
    CMP AL, '.'
    JZ BlankSpace
    CMP AL, ','
    JZ BlankSpace
    CMP AL, ':'
    JZ BlankSpace
    CMP AL, '!'
    JZ BlankSpace
    CMP AL, '?'
    JZ BlankSpace
    CMP AL, '"'
    JZ BlankSpace
    CMP AL, 027h				; '
    JZ BlankSpace
    CMP AL, '('
    JZ BlankSpace
    CMP AL, ')'
    JZ BlankSpace
    
    INC BX
    DEC CX
    JCXZ Exit
    JMP StringCycle
    
BlankSpace:
    XOR AH, AH
    MOV AL, len
    SUB AX, CX
    SUB AX, BX
    CMP BX, maxLength
    JA MaxLengthChanged
LabelCheckForMinimal:
    CMP BX, minLength
    JB MinLengthChanged
RestartWord:
    XOR BX, BX
StillBlank:
    LODSB
    DEC CX
    JCXZ Exit
    ;
    CMP Al, ' '
    JZ StillBlank
    CMP Al, '.'
    JZ StillBlank
    CMP Al, ','
    JZ StillBlank
    CMP Al, '-'
    JZ StillBlank
    CMP Al, ':'
    JZ StillBlank
    CMP Al, '!'
    JZ StillBlank
    CMP Al, '?'
    JZ StillBlank
    CMP Al, '('
    JZ StillBlank
    CMP Al, ')'
    JZ StillBlank
    CMP Al, '"'
    JZ StillBlank
    CMP Al, 027h
    JZ StillBlank
    
    DEC SI
    JMP StringCycle
    ; End Processing.
    
MaxLengthChanged:
    MOV maxIndex, AX
    MOV maxLength, BX
    JMP LabelCheckForMinimal
    
MinLengthChanged:
    MOV minIndex, AX
    MOV minLength, BX
    JMP RestartWord
    
Exit:
    XOR AH, AH
    MOV AL, len
    SUB AX, BX
    CMP BX, maxLength
    JB MaxNotChanged
    MOV maxIndex, AX
    MOV maxLength, BX
    JMP DisplayResult
MaxNotChanged:
    CMP BX, 0
    JZ DisplayResult
    CMP BX, minLength
    JA DisplayResult
    MOV minIndex, AX
    MOV minLength, BX
    
DisplayResult:	
    
    ; Setting strings.
    LEA SI, line
    LEA DI, minWord
    ADD SI, minIndex
    MOV CX, minLength
    REP MOVSB
    CALL PrintNewLine
    LEA SI, line
    LEA DI, maxWord
    ADD SI, maxIndex
    MOV CX, maxLength
    REP MOVSB

    LEA DX, messageMin
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine
    LEA DX, minWord
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine
    MOV AX, minIndex
    CALL Output
    MOV AX, minLength
    CALL Output
    
    CALL PrintNewLine
    LEA DX, messageMax
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine
    LEA DX, maxWord
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine
    MOV AX, maxIndex
    CALL Output
    MOV AX, maxLength
    CALL Output
    
    CALL PrintNewLine

    MOV ax, 4c00h
    INT 21h

end main