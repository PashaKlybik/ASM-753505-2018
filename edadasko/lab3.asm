.model small
.stack 256
.data
 	errorMessage db "ERROR!$"
	exceptionTest db "32768(0)$"
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

input PROC
 	push BX
 	push CX
 	push DX
 	push SI
 	MOV AX, 0
 	MOV BX, 0
 	MOV CX, 0
 	MOV DX, 0
 	MOV SI, 0
 	
 	enterSymbol:
 		mov AH, 01h
 		INT 21h		
 		CMP AL, 13 ;enter
 		JZ enterExit
 		CMP AL, 8 ;backspace
 		JZ backspace
 		
 		CMP AL, '-'; -
 		JZ checkMinus
 		
		;проверка на ввод цифры
 		SUB AL, 48
 		CMP AL, 10
 		JNC error
		
 		MOV CL, AL
 		MOV AX, 10
 		MUL BX
 		;проверка диапазона
 		CALL checkRange
 		MOV BX, AX
 		ADD BX, CX
 		CALL checkRange
 	JMP enterSymbol

 	checkMinus:
 	CMP SI, 0
 	JNZ error
 	CMP BX, 0
 	JNZ error 
 	MOV SI, 1
 	JMP enterSymbol
 	
 	;обработка клавиши backspace
 	backspace:
 		push AX
 		push DX
 		MOV DL, ' '
 		MOV AH, 02h
 		INT 21h
 		
 		MOV DL, 8
 		MOV AH, 02h
 		INT 21h
 		
 		;если стирается -, то обнуление SI
 		CMP BX, 0
 		JNZ notMinus
 		MOV SI, 0
 		pop DX
 		pop AX
 		jmp enterSymbol
 		
 		notMinus:
 			MOV AX, BX
 			CMP AX, 10
 			JNC deleteLastDigit
 		
 		MOV BX, 0
 		pop DX
 		pop AX
 		jmp enterSymbol

 		deleteLastDigit:	
 			MOV DX, 0
 			MOV BX, 10
 			DIV BX
 			MOV BX, AX
 			pop DX
 			pop AX
			jmp  enterSymbol
 		
 	error:
 		CALL newline
 		LEA DX, errorMessage
 		MOV AH, 09h
 		int 21h
 		mov ax, 4c00h
 		int 21h
 	
 	enterExit:
 		MOV AX, BX
 		CMP SI, 0; если отрицательное - NEG
 		JZ exitInput
 		NEG AX
		
 	exitInput:
 		pop SI
 		pop DX
 		pop CX
 		pop BX
RET
input ENDP

checkRange PROC
	JC error
 	CMP SI, 0
 	JZ checkPozitive
 	CMP AX, 32769
 	JNC error
 	CMP BX, 32769
 	JNC error
 	JMP endCheck
 	checkPozitive:
 		CMP AX, 32768
 		JNC error
 		CMP BX, 32768
 		JNC error
endCheck:		
RET
checkRange ENDP

division PROC
 	push AX
 	push BX
 	push CX
 	push DX
 	
	;проверка на -32768/(-1)
 	CMP AX, 32768
 	JZ checkExceptionTest
 	
 	continueDivision:
 	CMP BX, 0 ;если деление на 0
 	JZ error
 	 		
 	CWD
 	IDIV BX
	
	;исправление отрицательного остатка
	CMP DX, 0
	JNS answerOutput
	MOV CX, -1
	CMP BX, 0
	JNS correctRest
	NEG BX ;если делитель отрицательный
	NEG CX ;то смена знака BX и CX
	correctRest: 
	ADD DX, BX 
	ADD AX, CX 

	answerOutput:
 	CALL output
 	MOV CX, DX
 	
 	MOV DL, '('
 	MOV AH, 02h
 	INT 21h
 	
 	MOV AX, CX
 	CALL output
 	
 	MOV DL, ')'
 	MOV AH, 02h
 	INT 21h
 		
	jmp endDivision
	
 	checkExceptionTest:
 	CMP BX, 65535
 	JNZ continueDivision
 	LEA DX, exceptionTest
 	MOV AH, 09h
 	int 21h
	
	endDivision:
 	pop DX
 	pop CX
 	pop BX
 	pop AX	
RET
division ENDP

main:
 	mov ax, @data
 	mov ds, ax
	
 	CALL input
 	MOV CX, AX
 	CALL output
 	CALL newline	
	
 	CALL input
 	MOV BX, AX
 	CALL output
 	CALL newline
 	
 	MOV AX, CX
 	CALL division
 	
 	mov ax, 4c00h
 	int 21h
end main 