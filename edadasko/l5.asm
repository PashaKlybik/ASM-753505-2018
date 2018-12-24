LOCALS
.model small
.386
.stack 256
.data
    dimension db ?
    array dw 9 dup (?)
    elementSize = 2
    handle dw 1
    enterDimensionMessage db "Please enter a dimension of the array: $"
    determinant db 100 dup (?)
    numberOfDeterminantDigits dw ?
    determinantMessage db "Determinant = $"
    matrixMessage db "Matrix:$"
    inputFileName db 'input.txt', 0
    outputFileName db 'output.txt', 0
    fileErrorMessage db 'Error with file', 13, 10, '$'
    number dw ?
    digit db ?
.code

;переход на новую строку
newline PROC
    push AX
    push DX
	
    MOV AH, 02h
    MOV DL, 13
    int 21h
    MOV DL, 10
    int 21h

    pop DX
    pop AX
    RET
newline ENDP

;процедура вывода числа из 3 лабы
output PROC
    push AX
    push BX
    push CX
    push DX
    mov CX, 0 ;счетчик цифр
    mov BX, 10
 	
    ;проверка знака
    CMP AX, 0
    JNS cycleRestToStack ;если положительное
 	
    ;если отрицательное - вывод минуса и смена знака
    push AX
    push DX 
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    pop DX
    pop AX
    NEG AX
 	
    cycleRestToStack:
        CMP AX, 10
        JC exit
        MOV DX, 0
        div BX
        push DX
        inc CX
    JMP cycleRestToStack
	
    exit:		
        push AX
        inc CX
 		
    cycleOutputStack:		
        pop DX	
        add DX, 48
        mov AH, 02h
        int 21h
    LOOP cycleOutputStack
 	
    pop DX
    pop CX
    pop BX
    pop AX
RET
output ENDP

inputArrayFromFile PROC
    PUSHA
    MOV AH,3dH
    LEA DX,inputFileName
    XOR AL,AL
    INT 21h   
    MOV [handle],AX                               
    JNC @@fileIsOpen
    CALL fileError

    @@fileIsOpen:
        CALL readNumberFromFile
        MOV AX, number
        MOV dimension, AL

        MOV SI, 0 ;столбцы
        MOV BX, 0 ;строки
        MOVSX CX, [dimension]

        @@externalCycle:
            PUSH CX
            MOVSX CX, [dimension]
            MOV SI, 0
            @@iternalCycle:
                CALL readNumberFromFile
                MOV AX, [number]
                MOV array[BX][SI], AX
                ADD SI, elementSize
            loop @@iternalCycle
            POP CX
            MOVSX DX, [dimension] ;BX += размерность_массива*размер_элемента
            IMUL DX, elementSize
            ADD BX, DX
        loop @@externalCycle

        MOV AH,3eH                               
        MOV BX,[handle]
        INT 21h
        JNC @@fileIsClose
        CALL fileError

    @@fileIsClose:
    POPA
RET
inputArrayFromFile ENDP

readNumberFromFile PROC
    PUSHA
    XOR BX, BX
    XOR SI, SI
    MOV [number], 0
    read:
        call isEndOfFile
        CMP AL, 0
        JZ endReading
        call readDigitFromFile
        CMP [digit], ' '
        JZ endReading
        CMP [digit], 0Ah
        JZ endReading
        CMP [digit], '-'
        JNZ notMin
        MOV SI, 1
        JMP read
        notMin:
            SUB [digit], 48
            MOV AX, 10
            MUL BX
            MOV BX, AX
            ADD BX, word ptr[digit]
    JMP read

    endReading:
    CMP SI, 0; если отрицательное - NEG
    JZ endPr
    NEG BX

    endPr:
    MOV [number], BX
    MOV AX, BX
    POPA
RET
readNumberFromFile ENDP

readDigitFromFile PROC
    PUSHA
    MOV AX, [handle]
    MOV BX,AX
    MOV AH,3fH
    LEA DX,digit
    MOV CX,1
    int 21h

    jnc @@fileIsRead
    call fileError

    @@fileIsRead:
    MOV AX, word ptr[digit]
    POPA
RET
readDigitFromFile ENDP

isEndOfFile PROC
    PUSH BX
    MOV AX, [handle]
    MOV BX,AX
    MOV AX,4406h
    int 21h
    POP BX
RET
isEndOfFile ENDP


;вывод массива на консоль
outputArray PROC
    PUSHA

    LEA DX, matrixMessage
    MOV AH, 09h
    int 21h
    CALL newline

    MOV SI, 0 ;столбцы
    MOV BX, 0 ;строки
    MOVSX CX, [dimension]

    @@externalCycle:
        PUSH CX
        MOVSX CX, [dimension]
        MOV SI, 0
        @@iternalCycle:
            ;вывод табуляции
            MOV DX, 9
            mov AH, 02h
            int 21h

            MOV AX, array[BX][SI]
            CALL output
            ADD SI, elementSize
            loop @@iternalCycle
                POP CX
                MOVSX DX, [dimension] ;BX += размерность_массива*размер_элемента
                IMUL DX, elementSize
                ADD BX, DX
                CALL newline
        loop @@externalCycle
    POPA
RET
outputArray ENDP

;вывод определителя на консоль
outputDeterminant PROC
    PUSHA
    PUSH AX
    LEA DX, determinantMessage
    MOV AH, 09h
    int 21h
    POP AX
    CALL output
    POPA
    RET
outputDeterminant ENDP

evaluatingDeterminant2x2 PROC
    PUSH DX
    MOV AX, array[0][0]
    IMUL AX, array[elementSize*2][elementSize]
    MOV DX, array[0][elementSize]
    IMUL DX, array[elementSize*2][0]
    SUB AX, DX
    POP DX
    RET
evaluatingDeterminant2x2 ENDP

evaluatingDeterminant3x3 PROC
    PUSH DX
    MOV AX, array[0][0]
    IMUL AX, array[elementSize*3][elementSize]
    IMUL AX, array[elementSize*6][elementSize*2]
    MOV DX, array[0][elementSize]
    IMUL DX, array[elementSize*3][elementSize*2]
    IMUL DX, array[elementSize*6][0]
    ADD AX, DX
    MOV DX, array[0][elementSize*2]
    IMUL DX, array[elementSize*3][0]
    IMUL DX, array[elementSize*6][elementSize]
    ADD AX, DX
    MOV DX, array[0][elementSize*2]
    IMUL DX, array[elementSize*3][elementSize]
    IMUL DX, array[elementSize*6][0]
    SUB AX, DX
    MOV DX, array[0][0]
    IMUL DX, array[elementSize*3][elementSize*2]
    IMUL DX, array[elementSize*6][elementSize]
    SUB AX, DX
    MOV DX, array[0][elementSize]
    IMUL DX, array[elementSize*3][0]
    IMUL DX, array[elementSize*6][elementSize*2]
    SUB AX, DX
    POP DX
RET
evaluatingDeterminant3x3 ENDP

convertDeterminantToString PROC
    PUSHA
    MOV numberOfDeterminantDigits, 0
    XOR SI, SI
    XOR CX, CX
    CMP AX,0
    JGE convert
    MOV determinant[SI],'-'
    MOV numberOfDeterminantDigits, 1
    INC SI
    neg ax

    convert:
        INC CX
        XOR DX,DX
        MOV BX, 10
        DIV BX
        ADD DX,'0'
        PUSH DX
        test AX,AX
    JNZ convert

    ADD numberOfDeterminantDigits, CX

    putDigitsToString:
        POP dx
        MOV determinant[SI],DL
        INC SI
        loop putDigitsToString
    POPA
RET
convertDeterminantToString ENDP

outputInFile PROC
    PUSHA
    PUSH AX
    MOV AH,3cH
    XOR CX,CX
    lea DX,outputFileName
    int 21h

    jnc @@fileIsOpen
    call fileError
    @@fileIsOpen:
        MOV [handle],AX
        MOV BX,AX
        LEA DX, determinantMessage
        MOV AH,40H
        MOV CX, 14
        INT 21h

        POP AX
        CALL convertDeterminantToString
        LEA DX, determinant
        MOV AH,40H
        MOV CX, numberOfDeterminantDigits
        INT 21h

        JNC @@output
        CALL fileError
        @@output:
            MOV AH,3eH
            MOV BX,[handle]
            INT 21h
            JNC @@fileIsClose
            CALL fileError
            @@fileIsClose:
    POPA
RET
outputInFile ENDP

fileError PROC
    LEA DX, fileErrorMessage
    MOV AH, 09h
    int 21h
    MOV ax, 4c00h
    INT 21h
fileError ENDP

main:
    MOV AX, @data
    MOV DS, AX
    MOV ES, AX

    CALL inputArrayFromFile
    CALL outputArray

    CMP [dimension], 1
    JNZ determinant2x2
    MOV AX, array[0][0]
    JMP endProgram

    determinant2x2:
    CMP [dimension], 2
    JNZ determinant3x3
    CALL evaluatingDeterminant2x2
    JMP endProgram
	
    determinant3x3:
    CALL evaluatingDeterminant3x3

    endProgram:
    CALL outputDeterminant
    CALL outputInFile	
MOV ax, 4c00h
INT 21h
end main
