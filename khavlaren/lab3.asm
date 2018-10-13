.model small
.386
.stack 100h
.data
	ten dw 10 
	zero db '0'
	mes_divider db "Divider: ", 10, 13, '$'
	mes_divisor db 10, 13, "Divisor: ", 10, 13, '$'
	message1 db 10, 13, "Error: too long number.", 10, 13, '$'
	message2 db 10, 13, "Error: incorrect symbol.", 10, 13, '$'
	div_by_zero db 10, 13, "Error: dividing by zero.", 10, 13, '$'
	mes_result db 10, 13, "Result: $"
	mes_rem db 10, 13, "Remainder: $"
.code

Output PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	XOR CX, CX
	MOV BX, 10
	
Div_cycle:
	XOR DX, DX
	DIV BX
	PUSH DX			; Остаток от деления на 10 (т.е. последнюю цифру) кладём в стек.
	INC CX
	CMP AX, 0
	JNZ Div_cycle
	
Out_cycle:
	POP DX			; CX раз (число цифр в десятичной записи числа) берем из стека цифры и выводим на экран,
	ADD DL, zero	; добавив при этом символ нуля (его код).
	MOV AH, 02h
	INT 21h
	LOOP Out_cycle
	
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
	
Start_Input:
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
	CMP AL, 13						; Enter.
	JZ Next							
	CMP AL, 8						; Backspace.
	JZ Backspace
	CMP AL, 1Bh						; Escape.
	JZ Escape
Continue:
	SUB AL, zero					; Отнять код нуля, если ввод верный, будет цифра от 0 до 9.
	CMP AL, 10
	JNC Wrong_Input					; При правильном вводе всегда будет CF = 1.
	XOR CX, CX
	MOV CL, AL						; В CX - очередная цифра.
	MOV AX, BX
	MUL ten
	CMP DX, 0
	JNZ Overflow					; Если DX != 0, то число уже не помещается в 16 бит.
	ADD AX, CX
	JC Overflow
	MOV DX, 32767
	CMP SI, 1
	JNZ End_of_Cycle				; Если нет минуса, то максимальный модуль 32767.
	INC DX							; Если минус есть, то на 1 больше.
End_of_Cycle:
	CMP DX, AX
	JC Overflow
	MOV BX, AX
	INC DI
	JMP Cycle
	
Backspace:
	CALL Delete
	MOV AX, BX
	XOR DX, DX
	DIV ten
	MOV BX, AX
	CMP BX, 0
	JNZ Cycle
	
	MOV AH, 03h
	INT 10h
	CMP DL, 0				; Определить позицию курсора. Если нулевой столбец (нет минуса),
	JZ Start_Input			; То перейти в начало процедуры ввода.
	JMP Cycle
	
Escape:
	XOR BX, BX				; Занулить BX и регистр минуса.
	XOR SI, SI
	MOV CX, DI
	INC CX
Back_Loop:
	MOV DL, 8				; "Нарисовать" Backspace - передвинуться влево на 1 позицию (если это ещё возможно).
	MOV AH, 02h
	INT 21h
	CALL Delete
	LOOP Back_Loop
	JMP Start_Input
	
Overflow:
	LEA DX, message1
	MOV AH, 09h
	INT 21h
	JMP Next
	
Wrong_Input:
	LEA DX, message2
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

main:

    MOV AX, @data
    MOV DS, AX
	
	LEA DX, mes_divider
	MOV AH, 09h
	INT 21h
	CALL InputSigned
	CALL OutputSigned
	PUSH AX
	
	LEA DX, mes_divisor
	MOV AH, 09h
	INT 21h
	CALL InputSigned
	CALL OutputSigned
	CMP AX, 0
	JZ Dividing_by_zero_exception
	
	MOV CX, AX
	POP AX
	CWD
	IDIV CX
	; Блок проверки: если остаток отрицательный (алгебра требует положительный остаток, 
	; но деление в Ассемблере так не всегда делает). Если такое произошло,
	; уменьшаем на 1 результат деления, а к остатку прибавляем делитель (в CX).
	TEST DX, 1000000000000000b
	JZ Non_Negative_Remainder
	TEST CX, 1000000000000000b
	JZ Non_Negative_Divisor
	INC AX
	SUB DX, CX
	JMP Non_Negative_Remainder
	Non_Negative_Divisor:
	DEC AX
	ADD DX, CX
Non_Negative_Remainder:
	PUSH DX
	PUSH AX
	LEA DX, mes_result
	MOV AH, 09h
	INT 21h
	POP AX
	CALL OutputSigned
	LEA DX, mes_rem
	MOV AH, 09h
	INT 21h
	POP AX
	CALL OutputSigned
	JMP Pr_finish
	
Dividing_by_zero_exception:
	LEA DX, div_by_zero
	MOV AH, 09h
	INT 21h
	
Pr_finish:
	MOV AX, 4c00h
	INT 21h

end main