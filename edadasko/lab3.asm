.model small
.stack 256
.data
 	n db 10
 	errorMessage db "ERROR!$"
.code

;переход на новую строку
newline PROC
 	push AX
 	push DX

 	MOV DL, n
 	mov AH, 02h
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
 	TEST AX, 1000000000000000b
 	JZ cycle1 ;если положительное - переход на цикл вывода числа
 	
 	;если отрицательное - вывод минуса и смена знака
 	push AX
 	push DX 
 	MOV DL, '-'
 	MOV AH, 02h
 	INT 21h
 	pop DX
 	pop AX
 	NEG AX
 	
 	cycle1:
 		CMP AX, 10
 		JC exit
 		MOV DX, 0
 		div BX
 		push DX
 		inc CX
 	JMP cycle1
	
 	exit:		
 		push AX
 		inc CX
 		
 	cycle2:		
 		pop DX	
 		add DX, 48
 		mov AH, 02h
 		int 21h
 	LOOP cycle2
 	
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
 		JZ exit1
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
 		JNZ continue
 		MOV SI, 0
 		pop DX
 		pop AX
 		jmp enterSymbol
 		
 		continue:
 			MOV AX, BX
 			CMP AX, 10
 			JNC continue1
 		
 		MOV BX, 0
 		pop DX
 		pop AX
 		jmp enterSymbol

 		continue1:	
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
 	
 	exit1:
 		MOV AX, BX
 		CMP SI, 0; если отрицательное - NEG
 		JZ exit2
 		NEG AX
		
 	exit2:
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
 		JMP e
 		checkPozitive:
 		CMP AX, 32768
 		JNC error
 		CMP BX, 32768
 		JNC error
e:		
RET
checkRange ENDP

division PROC
 	push AX
 	push BX
 	push CX
 	push DX
 	
	;проверка на -32768/(-1)
 	CMP AX, 32768
 	JZ check1
 	
 	continue2:
 	CMP BX, 0 ;если деление на 0
 	JZ error
 	 		
 	MOV DX, 0
 	CWD
 	IDIV BX
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
	
 	check1:
 	CMP BX, 65535
 	JNZ continue2
 	JMP error
	
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