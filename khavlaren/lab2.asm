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
	newline db 10, 13, '$'
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
	
	XOR BX, BX
Cycle:
	MOV AH, 01h
	INT 21h
	CMP AL, 13			; Enter.
	JZ Finish
	CMP AL, 8			; Backspace.
	JZ Backspace
	CMP AL, 1Bh			; Escape.
	JZ Escape
	
	SUB AL, zero		; Отнять код нуля, если ввод верный, будет цифра от 0 до 9.
	CMP AL, 10
	JNC Wrong_Input		; При правильном вводе всегда будет CF = 1.
	XOR CX, CX
	MOV CL, AL			; В CX - очередная цифра.
	MOV AX, BX			
	MUL ten
	CMP DX, 0			; Если DX != 0, то число уже не помещается в 16 бит.
	JNZ Overflow
	ADD AX, CX
	JC Overflow
	MOV BX, AX
	JMP Cycle
	
Backspace:
	CALL Delete
	MOV AX, BX
	XOR DX, DX
	DIV ten
	MOV BX, AX
	JMP Cycle
	
Escape:
	MOV CX, 6		; 6 раз стереть символ. Больше не понадобится, так как ввод не позволит этого сделать (max 5 знаков в числе).
	XOR BX, BX
Back_Loop:
	MOV DL, 8		; "Нарисовать" Backspace - передвинуться влево на 1 позицию (если это ещё возможно).
	MOV AH, 02h
	INT 21h
	CALL Delete
	LOOP Back_Loop
	JMP Cycle
	
Overflow:
	LEA DX, message1
	MOV AH, 09h
	INT 21h
	JMP Finish
	
Wrong_Input:
	LEA DX, message2
	MOV AH, 09h
	INT 21h
	
Finish:
	MOV AX, BX
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
	
	MOV CX, AX
	POP AX
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
	JMP Pr_finish
	
Dividing_by_zero_exception:
	LEA DX, div_by_zero
	MOV AH, 09h
	INT 21h
	
Pr_finish:
	MOV AX, 4c00h
	INT 21h

end main