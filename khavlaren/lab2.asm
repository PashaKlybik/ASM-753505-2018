.model small
.386
.stack 100h
.data
	ten dw 10
	zero db '0'
	mes_divider db "Divident: ", 10, 13, '$'
	mes_divisor db 10, 13, "Divisor: ", 10, 13, '$'
	message_long_input db 10, 13, "Error: too long number.", 10, 13, '$'
	message_incorrect db 10, 13, "Error: incorrect symbol.", 10, 13, '$'
	message_div_by_zero db 10, 13, "Error: dividing by zero.", 10, 13, '$'
	mes_result db 10, 13, "Result: $"
	mes_rem db 10, 13, "Remainder: $"
.code

Output PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	XOR DX, DX
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

Input PROC
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	
	XOR BX, BX
	XOR SI, SI
In_Cycle:
	MOV AH, 01h
	INT 21h
	
	CMP AL, 13			; Enter.
	JZ Finish_Input
	CMP AL, 8			; Backspace.
	JZ Backspace
	CMP AL, 1Bh			; Escape.
	JZ Escape
	
	SUB AL, zero		; Отнять код нуля, если ввод верный, будет цифра от 0 до 9.
	CMP AL, 10
	JNC Wrong_Input		; При правильном вводе всегда будет CF = 1.
	XOR CH, CH
	MOV CL, AL			; В CX - очередная цифра.
	MOV AX, BX			
	MUL ten
	CMP DX, 0			; Если DX != 0, то число уже не помещается в 16 бит.
	JNZ Overflow
	ADD AX, CX
	JC Overflow
	MOV BX, AX
	INC SI
	JMP In_Cycle
	
Backspace:
	CALL Delete
	MOV AX, BX
	XOR DX, DX
	DIV ten
	MOV BX, AX
	JMP In_Cycle
	
;Escape:
;	MOV CX, 6		; 6 раз стереть символ. Больше не понадобится, так как ввод не позволит этого сделать (max 5 знаков в числе).
;	XOR BX, BX
;Back_Loop:
;	MOV DL, 8		; "Нарисовать" Backspace - передвинуться влево на 1 позицию (если это ещё возможно).
;	MOV AH, 02h
;	INT 21h
;	CALL Delete
;	LOOP Back_Loop
;	JMP In_Cycle
	
Escape:
	MOV CX, SI
	XOR SI, SI
	XOR BX, BX
	INC CX
Clear_Loop:
	MOV DL, 8		; "Нарисовать" Backspace - передвинуться влево на 1 позицию (если это ещё возможно).
	MOV AH, 02h
	INT 21h
	CALL Delete
	LOOP Clear_Loop
	JMP In_Cycle
	
Overflow:
	LEA DX, message_long_input
	MOV AH, 09h
	INT 21h
	JMP Finish_Input
	
Wrong_Input:
	LEA DX, message_incorrect
	MOV AH, 09h
	INT 21h
	
Finish_Input:
	MOV AX, BX
	POP SI
	POP DX
	POP CX
	POP BX
	RET
Input ENDP


Delete PROC 		; Выводит ' ' и перемещается назад на 1 позицию (позицию только что выведенного пробела).  
	PUSH AX 		; Реализовано так, потому что вызывается по нажатию Backspace (если обработка без него, это учтено).
	PUSH BX 
	PUSH CX 
	PUSH DX 
	
	MOV DL, ' '
	MOV AH, 02h
	INT 21h
	MOV DL, 8
	MOV AH, 02h
	INT 21h

	POP DX 
	POP CX 
	POP BX 
	POP AX 
	RET 
Delete ENDP

main:

    MOV AX, @data
    MOV DS, AX
	
	LEA DX, mes_divider
	MOV AH, 09h
	INT 21h
	CALL Input
	CALL Output
	PUSH AX
	
	LEA DX, mes_divisor
	MOV AH, 09h
	INT 21h
	CALL Input
	CALL Output
	CMP AX, 0
	JZ Dividing_by_zero_exception
	
	MOV CX, AX		; Помещаем в CX делитель.
	POP AX			; Достаем делимое из стека.
	XOR DX, DX
	DIV CX
	PUSH DX
	PUSH AX
	LEA DX, mes_result
	MOV AH, 09h
	INT 21h
	POP AX
	CALL Output
	LEA DX, mes_rem
	MOV AH, 09h
	INT 21h
	POP AX
	CALL Output
	JMP Exit
	
Dividing_by_zero_exception:
	LEA DX, message_div_by_zero
	MOV AH, 09h
	INT 21h
	
Exit:
	MOV AX, 4c00h
	INT 21h

end main