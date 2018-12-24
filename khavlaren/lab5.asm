.model small
.386
.stack 100h
.data
	CAPACITY EQU 256
	EXTRACAPACITY = CAPACITY + 16
	rows dw 0
	columns dw 0
    array dw EXTRACAPACITY dup(0)
	
	messageDimensionError db 10, 13, "Error: total number of elements must be greater than 0 and equal or less than 256.", 10, 13, '$'
	messageLongInput db 10, 13, "Error: too long number.", 10, 13, '$'
    messageIncorrect db 10, 13, "Error: incorrect symbol.", 10, 13, '$'
	messageRows db "Enter number of rows:", 10, 13, '$'
	messageColumns db "Enter number of columns:", 10, 13, '$'
	messageEnterElement db "Enter element:", 10, 13, '$'
	newLine db 10, 13, '$'
	messageChoice db "Press 0 to delete row, 1 to delete column.", 10, 13, '$'
	messageEnterNumberToDelete db "Enter the number of row / column for deleting.", 10, 13, '$'
	messageIncorrectNumber db 10, 13, "Error: there is no such a row / column in the array.", 10, 13, '$'
	messageResult db 10, 13, "Result:", 10, 13, '$'
	messageEmpty db 10, 13, "Empty array.", 10, 13, '$'
.code

WriteLine MACRO line: REQ
	PUSH AX
	PUSH DX
	MOV AH, 09h
	MOV DX, offset line
	INT 21h
	POP DX
	POP AX
ENDM

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

Delete PROC 			; Выводит ' ' и перемещается назад на 1 позицию (позицию только что выведенного пробела).  
    PUSH AX 			; Реализовано так, потому что вызывается по нажатию Backspace (если обработка без него, это учтено).
    PUSH DX 
    
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    MOV DL, 8
    MOV AH, 02h
    INT 21h 

    POP DX
    POP AX 
    RET 
Delete ENDP

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
    ADD DL, '0' 	; добавив при этом символ нуля (его код).
    MOV AH, 02h
    INT 21h
    LOOP OutCycle
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Output ENDP

OutputSigned PROC
    PUSH AX
    PUSH DX
    
    TEST AX, 1000000000000000b		; Проверка знака числа.
    JZ Print						; Если 0 (число положительное), то просто выводим число.
    PUSH AX
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    POP AX
    NEG AX							; Превращаем в положительное.
Print:
    CALL Output						; Вывод числа как положительного.
    
    POP DX
    POP AX
    RET
OutputSigned ENDP

InputSigned PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
StartInput:
    XOR DI, DI
    XOR BX, BX						; Обнулить BX.
    XOR SI, SI						; Обнулить SI. Регистр отвечает за хранение.
    MOV AH, 01h
    INT 21h
    CMP AL, '-'						; Проверка первого символа на '-'.
    JNZ Continue					; Если нет - идем на проверку как обычной циферки.
    MOV SI, 1
    INC DI
    
Cycle:
    MOV AH, 01h
    INT 21h
Continue:
	INC DI
    CMP AL, 13						; Enter.
    JZ Next							
    CMP AL, 8						; Backspace.
    JZ Backspace
    CMP AL, 1Bh						; Escape.
    JZ Escape
    SUB AL, '0'						; Отнять код нуля, если ввод верный, будет цифра от 0 до 9.
    CMP AL, 10
    JNC WrongInput					; При правильном вводе всегда будет CF = 1.
    XOR CX, CX
    MOV CL, AL						; В CX - очередная цифра.
    MOV AX, BX
	MOV BX, 10
    MUL BX
    CMP DX, 0
    JNZ Overflow					; Если DX != 0, то число уже не помещается в 16 бит.
    ADD AX, CX
    JC Overflow
    MOV DX, 32767
    CMP SI, 1
    JNZ EndOfCycle				; Если нет минуса, то максимальный модуль 32767.
    INC DX							; Если минус есть, то на 1 больше.
EndOfCycle:
    CMP DX, AX
    JC Overflow
    MOV BX, AX
    JMP Cycle
    
Backspace:
    CALL Delete
	DEC DI
    MOV AX, BX
    XOR DX, DX
	MOV BX, 10
    DIV BX
    MOV BX, AX
    CMP BX, 0
    JNZ Cycle
    
    MOV AH, 03h
    INT 10h
    CMP DL, 0				; Определить позицию курсора. Если нулевой столбец (нет минуса),
    JZ StartInput			; То перейти в начало процедуры ввода.
    JMP Cycle
    
Escape:
    XOR BX, BX				; Занулить BX и регистр минуса.
    XOR SI, SI
    MOV CX, DI
	XOR DI, DI
    INC CX
BackLoop:
    MOV DL, 8				; "Нарисовать" Backspace - передвинуться влево на 1 позицию (если это ещё возможно).
    MOV AH, 02h
    INT 21h
    CALL Delete
    LOOP BackLoop
    JMP StartInput
    
Overflow:
    LEA DX, messageLongInput
    MOV AH, 09h
    INT 21h
    JMP Next
    
WrongInput:
    LEA DX, messageIncorrect
    MOV AH, 09h
    INT 21h
    
Next:
    MOV AX, BX
    CMP SI, 1
    JNZ Finish
    NEG AX
Finish:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    RET
InputSigned ENDP

main:

    MOV AX, @data
    MOV DS, AX
	MOV ES, AX
    
	; Reading dimensions.
    WriteLine messageRows
	CALL InputSigned
	CMP AX, 1
	JL IncorrectData
	CMP AX, CAPACITY
	JA IncorrectData
	MOV rows, AX
	WriteLine messageColumns
	CALL InputSigned
	CMP AX, 1
	JL IncorrectData
	MUL rows
	CMP AX, CAPACITY
	JA IncorrectData
	CMP DX, 0
	JNZ IncorrectData
	MOV columns, AX
	; End reading dimendions.
	
	; Reading elements.
	XOR SI, SI
	MOV CX, rows
InputByRowCycle:
	PUSH CX
	MOV CX, columns
InputByColumnsCycle:
	WriteLine messageEnterElement
	CALL InputSigned
	MOV array[SI], AX
	ADD SI, 2
	DEC CX
	CMP CX, 0
	JNZ InputByColumnsCycle
	POP CX
	DEC CX
	CMP CX, 0
	JNZ InputByRowCycle
	; End reading elements.
	
	; Output elements.
	XOR SI, SI
	MOV CX, rows
OutputByRowCycle:
	PUSH CX
	MOV CX, columns
OutputByColumnsCycle:
	MOV AX, array[SI]
	CALL OutputSigned
	MOV DL, 09h
	MOV AH, 02h
    INT 21h
	ADD SI, 2
	DEC CX
	CMP CX, 0
	JNZ OutputByColumnsCycle
	CALL PrintNewLine
	POP CX
	DEC CX
	CMP CX, 0
	JNZ OutputByRowCycle
	; End output elements.
	
	WriteLine messageChoice
	MOV AH, 01h
    INT 21h
	CALL PrintNewLine
	XOR DI, DI
	CMP AL, '0'
	JZ InputNumberToDelete
	MOV DI, 1
	
InputNumberToDelete:
	WriteLine messageEnterNumberToDelete
	CALL InputSigned
	CMP AX, 0
	JL IncorrectNumberToDelete
	CMP DI, 1
	JZ CaseColumns
	CMP AX, rows
	JL Processing
	JMP IncorrectNumberToDelete
CaseColumns:
	CMP AX, columns
	JL Processing
	JMP IncorrectNumberToDelete
	
Processing:
    MOV DX, columns
	CMP DI, 1
	JZ CaseColumnsProcessing
	PUSH AX
	MUL DX
	MOV BX, 2
	MUL BX
	LEA SI, array
	ADD SI, AX
	MOV DX, columns
	ADD SI, DX
	ADD SI, DX
	LEA DI, array
	ADD DI, AX
	POP CX
	INC CX
	MOV AX, rows
	SUB AX, CX
	MUL DX
	MOV CX, AX
	CLD
	REP MOVSW
	CALL PrintNewLine
	DEC rows
	JMP FinalDisplay
	
CaseColumnsProcessing:
	LEA DI, array
	MOV BX, 2
	MUL BX
	ADD DI, AX
	MOV SI, DI
	ADD SI, 2
	CLD
	MOV DX, rows
	MOV BX, columns
	DEC BX
ColumnsCycle:
	MOV CX, BX
	REP MOVSW
	ADD SI, 2
	DEC DX
	CMP DX, 0
	JNZ ColumnsCycle
	DEC columns
	JMP FinalDisplay
	
IncorrectData:
	WriteLine messageDimensionError
	JMP Exit

IncorrectNumberToDelete:
	WriteLine messageIncorrectNumber
	JMP Exit

FinalDisplay:
	WriteLine messageResult
	CMP rows, 0
	JZ EmptyArray
	CMP columns, 0
	JZ EmptyArray
	XOR SI, SI
	MOV CX, rows
OutputByRowCycleF:
	PUSH CX
	MOV CX, columns
OutputByColumnsCycleF:
	MOV AX, array[SI]
	CALL OutputSigned
	MOV DL, 09h
	MOV AH, 02h
    INT 21h
	ADD SI, 2
	DEC CX
	CMP CX, 0
	JNZ OutputByColumnsCycleF
	CALL PrintNewLine
	POP CX
	DEC CX
	CMP CX, 0
	JNZ OutputByRowCycleF
	JMP Exit
	
EmptyArray:
	WriteLine messageEmpty
	
	Exit:
    MOV ax, 4c00h
    INT 21h

end main