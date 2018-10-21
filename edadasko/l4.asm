.model small
.386
.stack 256
.data
    ;обрабатываемая строка
    max db 100
    len db ?
    string db 100 dup('$')

    ;строка гласных
    vowelsLen db 31
    vowels db "AEIOUaeiouаоиеёэыуюяАОИЕЁЭЫУЮЯ$"
.code

newline PROC
    PUSH AX
    PUSH DX

    MOV AH, 02h
    MOV DL, 13
    INT 21h
    MOV DL, 10
    INT 21h

    POP DX
    POP AX
RET
newline ENDP

counterOfWordsThatBeginsWithVowel PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
	
    ;в CX длина введенной строки
    MOVZX CX, len
    ;счетчик гласных
    XOR AX, AX
    ;индексатор для введенной строки
    XOR SI, SI

    checkVowels:
        PUSH CX
        PUSH AX

        ;поиск очередного символа в строке гласных
        MOV AL, string[SI]
        LEA DI, vowels
        MOVZX CX, vowelsLen
        REPNE SCASB
        JNE nextSymbol

        ;проверка, является ли символ началом слова
        checkBeginning:
        CMP SI, 0
        JZ itIsBeginningOfWord
			
        MOV DL, string[SI - 1] 
        CMP DL, ' '
        JNE nextSymbol

        itIsBeginningOfWord:
            POP AX
            INC AX
            PUSH AX
		
        nextSymbol:
            INC SI	
            POP AX
            POP CX
    loop checkVowels

    POP SI
    POP DX
    POP CX
    POP BX
RET
counterOfWordsThatBeginsWithVowel ENDP

;процедура вывода числа из 2 лабы
output PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX ;счетчик цифр
    MOV BX,10
 	
    ;пока число больше 10 -> деление на 10 + остаток в стек
    cycleRestToStack:
        CMP AX, 10 
        JC exit
        MOV DX, 0 
        DIV BX
        PUSH DX
        INC CX
        JMP cycleRestToStack
        exit:		
            PUSH AX
            INC CX
 	
    ;вывод чисел из стека 	
    cycleOutputStack:		
        POP DX	
        ADD DX, 48
        MOV AH, 02h
        INT 21h
    LOOP cycleOutputStack
 	
    POP DX
    POP CX
    POP BX
    POP AX
RET
output ENDP


main:
    MOV ax, @data
    MOV ds, ax
    MOV es, ax

    ;ввод строки
    LEA DX, max
    MOV AH, 0aH
    INT 21h
	
    CALL newline
    CALL counterOfWordsThatBeginsWithVowel
    CALL output
   
    MOV ax, 4c00h
    INT 21h	
end main