.MODEL SMALL
.STACK 100h

	.DATA
		ten dw 10	
		two dw 2
		MESSAGE DB "Manually(M)/From file(F)",0Dh,0Ah,'$'
		INPUT_FILE_NAME db "Input.txt",0
		OUTPUT_FILE_NAME db "Output.txt",0
		HANDLE dw 1 dup (?)
		BUFF db 200 dup (' '),' '
		LEN_BUFF dw ?
		MATRIX dw 10 dup (10 dup (0))
		N dw 0	
		M dw 0
		min_m_n dw (?)
		DIGIT DB 1 dup (?)
	.CODE
	
	
	INPUT_NUMBER PROC 
		PUSH BX
		PUSH AX			;число при выходе из процедуры
		PUSH CX 		;храним число во время исполнения
		PUSH DX  
		PUSH SI    		;si = 1 <=> cx=0, но в консоль не очищена
		PUSH DI			;di = 1 <=> число отрицательное
		MOV SI, 1
		XOR DI, DI
		XOR CX, CX
	input_loop: 
		CMP SI, 0
		JE GO	
		MOV SI, 0
		CMP CX, 0
		JNE GO
		CMP DI, 0
		JNE GO
		JMP delete_symbol
		GO:
		MOV SI, 1	
		MOV AH,01h
		INT 21H
		CMP AL, 13			;проверка на enter
		JE _press_enter
		CMP AL, 8			;проверка на backspace
		JE press_backspace 	
		CMP AL, 27			;проверка на escape
		JE press_escape 
		CMP AL, '-'			;проверка на минус
		JE press_minus   
		CMP AL, '0'			;Если код символа меньше кода '0', то 
		JL delete_symbol	;удаляем символ
		CMP AL,'9'          ;Если код символа больше кода '9', то
		JG delete_symbol	;удаляем символ
		SUB AL, '0'
		CBW 				;расширяем al на ax       
		MOV BX, AX
	   
		MOV AX, CX
		MUL ten
		JC delete_symbol      ;если перенос - ошибка
		JO delete_symbol      ;Если переполнение - ошибка
		ADD AX, BX
		JC delete_symbol      ;Если перенос - ошибка
		JO delete_symbol      ;Если переполнение - ошибка
		CMP AX, 32767
		JG delete_symbol      ;Если перенос - ошибка
	 	
		MOV CX, AX
		_input_loop:
		JMP input_loop
	press_minus:	
		CMP CX, 0
		JNE label2
		CMP DI, 1
		JE label2
		MOV DI, 1
		JMP input_loop	
		label1:
			MOV DI, 1
			JMP input_loop
		label2:
			JMP delete_symbol
			JMP input_loop	
		_press_enter:
		JMP press_enter
	press_backspace:
		;смотри знак
		CMP CX, 0
		JNE lbl88
		MOV DI, 0
		lbl88:
		;делим cx на 10
		MOV AX,CX
		MOV BX,10
		XOR DX,DX
		DIV BX
		MOV CX,AX
		;ударяем символ
		MOV AH,02h
		MOV DL,' '		;перезаписываем последний символ на пробел
		INT 21h
		MOV DL,8		;двигаем коретку влево
		INT 21h
		JMP input_loop    
	delete_symbol:
		CALL DELETESYMB
		JMP input_loop
	press_escape:
		MOV DI, 0
		MOV AX,CX
		MOV BX,10
		XOR DX,DX
		DIV BX
		MOV CX,AX
		CALL DELETESYMB
		XOR DX,DX
		CMP CX,DX
		CALL DELETESYMB
		JE _input_loop
		JMP press_escape
	press_enter:
		MOV AX,CX  
		CMP DI, 0
		JE pos
		NEG AX
		pos:	
		POP DI    
		POP SI 
		POP DX
		POP CX
		POP BX
		POP BX
	RET 
	INPUT_NUMBER ENDP

	DELETESYMB PROC
	   PUSH AX
	   PUSH DX     
	   MOV DL, 8		;двигаем коретку влево
	   MOV AH, 02h
	   INT 21H
	   MOV DL,' '	;перезаписываем последний символ на пробел
	   INT 21H
	   MOV DL,8		;двигаем коретку влево
	   INT 21H
	   POP DX
	   POP AX
	RET
	DELETESYMB ENDP

	OUTPUT_NUMBER PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		
		PUSH DI 			;di = 1 <=> число отрицательное
		
		XOR CX, CX
		XOR DI, DI
		
		OR AX, AX
		JNS push_digit_to_stack
		MOV DI, 1
		NEG AX
		
	push_digit_to_stack:
		XOR DX,DX
		DIV ten
		PUSH DX						;добавили в стек очередную цифру числа
		INC CX
		TEST AX, AX					;(логическое И)
		JNZ push_digit_to_stack 	;если ax - не ноль, то добавляем следующую цифру
		   
		MOV AH, 02h
		CMP DI, 1
		JNZ PRINT
		MOV DX, '-'
		INT 21h
	print:
		POP DX			;в dx - цифра, которую необходимо вывести
		ADD DL, '0'		;символ, выводимы на дисплей
		int 21h
		LOOP print   
			
		POP DI 	
		POP DX
		POP CX 
		POP BX 
		POP AX  
	RET
	OUTPUT_NUMBER ENDP

	CALCULATION_OF_min_m_n PROC
		PUSH AX
		MOV AX,M		
		MOV min_m_n, AX	;min_m_n = M
		CMP AX,N
		JG min_m_n_go
		MOV AX,N		;min_m_n = N
		MOV min_m_n,AX
		min_m_n_go:
		POP AX
		RET
	CALCULATION_OF_min_m_n ENDP


	INPUT_MATRIX PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH SI
		
		CALL INPUT_NUMBER      ;input N
		MOV N,AX
		CALL INPUT_NUMBER      ;input M
		MOV M,AX				
		XOR BX,BX		
		MOV AX,N
		MUL M
		MOV CX,AX
	input_next:		
		CALL INPUT_NUMBER 
		MOV MATRIX[BX],AX
		INC BX	
		INC BX		
		LOOP input_next	
		
		CALL CALCULATION_OF_min_m_n
		
		POP SI 
		POP CX
		POP BX
		POP AX
	RET
	INPUT_MATRIX ENDP

	OUTPUT_MATRIX PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
				
		XOR BX,BX		
		MOV AX,N
		MUL M
		MOV CX,AX
	output_next:	
		MOV AX,MATRIX[BX]
		CALL OUTPUT_NUMBER
		INC BX	
		INC BX
		MOV AX, BX
		XOR DX,DX
		DIV TWO
		DIV N
		CMP DX,0
		JE out_go1
		MOV AH, 02h
		MOV DL, 0	;пробел
		INT 21h
		JMP out_go2	
		out_go1:
		MOV AH, 02h
		MOV DL, 10	;enter
		INT 21h	
		out_go2:
		LOOP output_next
				
		POP SI 
		POP DX
		POP CX
		POP BX
		POP AX		
	RET
	OUTPUT_MATRIX ENDP

	READ_MATRIX_FROM_FILE PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSH DI
		XOR DI,DI
		
		LEA DX,INPUT_FILE_NAME	;считываем файл в строку buff
		MOV AH,03DH
		MOV AL,0
		XOR CX,CX
		INT 21H 
		MOV HANDLE,AX
		MOV BX,AX               
		MOV AH,3FH              
		LEA DX,BUFF      
		MOV CX,200          
		INT 21H
		MOV BX,AX
		MOV BUFF[BX],'$'
		MOV LEN_BUFF, BX
		MOV CX,BX
		MOV AH,03EH
		MOV BX,HANDLE
		INT 21H
								;записываем matrix из buff
		XOR BX, BX
		READ_N_FROM_FILE:
		XOR CH, CH		
		MOV CL, BUFF[BX]
		SUB CX, '0'
		MOV AX, N
		MUL TEN		
		ADD AX, CX
		MOV N, AX
		INC BX
		XOR CH, CH		
		MOV CL, BUFF[BX]		
		CMP CX, '0'
		JL READ_M_FROM_FILE_
		CMP CX, '9'
		JG READ_M_FROM_FILE_
		JMP READ_N_FROM_FILE	
		READ_M_FROM_FILE_:
		INC BX
		INC BX
		READ_M_FROM_FILE:
		XOR CH, CH		
		MOV CL, BUFF[BX]
		SUB CX, '0'
		MOV AX, M
		MUL TEN		
		ADD AX, CX
		MOV M, AX
		INC BX
		XOR CH, CH		
		MOV CL, BUFF[BX]	
		CMP CX, '0'
		JL READ_ELEMENT_FROM_FILE_
		CMP CX, '9'
		JG READ_ELEMENT_FROM_FILE_
		JMP READ_M_FROM_FILE	
		
		READ_ELEMENT_FROM_FILE_:
		INC BX
		XOR SI,SI
		DEC SI
		DEC SI
		READ_NEXT_ELEMENT_FROM_FILE:
		XOR DI,DI
		INC BX
		CMP BX, LEN_BUFF
		JE END_OF_FILE
		INC SI
		INC SI
		READ_ELEMENT_FROM_FILE:
		XOR CH, CH
		MOV CL, BUFF[BX]
		
		CMP CX,'-'
		JNE READ_ELEMENT_FROM_FILE_GO
		MOV DI,1
		READ_ELEMENT_FROM_FILE_GO:
		
		CMP CX, '0'
		JL READ_ELEMENT_FROM_FILE_GO1
		CMP CX, '9'
		JG READ_ELEMENT_FROM_FILE_GO1
		JMP READ_ELEMENT_FROM_FILE_GO2
		READ_ELEMENT_FROM_FILE_GO1:
		INC BX
		CMP BX, LEN_BUFF
		JE END_OF_FILE
		READ_ELEMENT_FROM_FILE_GO2:
		XOR CH, CH		
		MOV CL, BUFF[BX]
		SUB CX, '0' 
		MOV AX, MATRIX[SI]
		MUL TEN		
		ADD AX, CX
		CMP DI,0
		JE GO12345
		SUB AX, CX		
		SUB AX, CX
		GO12345:		
		MOV MATRIX[SI], AX
		INC BX
		CMP BX, LEN_BUFF
		JE END_OF_FILE
		XOR CH, CH		
		MOV CL, BUFF[BX]	
		CMP CX, '0'
		JL READ_NEXT_ELEMENT_FROM_FILE
		CMP CX, '9'
		JG READ_NEXT_ELEMENT_FROM_FILE
		JMP READ_ELEMENT_FROM_FILE	
		END_OF_FILE:			
		
		CALL CALCULATION_OF_min_m_n		
		POP DI
		POP SI 
		POP DX
		POP CX
		POP BX
		POP AX	
	RET
	READ_MATRIX_FROM_FILE ENDP

	WRITE_MATRIX_TO_FILE PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		
		PUSH DI 			;di = 1 <=> число отрицательное
		
		;открыть описатель файла
		MOV AH,3DH
		LEA DX,OUTPUT_FILE_NAME
		MOV AL,1
		INT 21H
		MOV HANDLE,AX
		;копируем matrix в buff
		XOR BX,BX		
	WRITE_NUMBER:
		MOV AX,MATRIX[BX] 
		XOR CX,CX
		XOR DI,DI				
		OR AX,AX
		JNS _push_digit_to_stack
		MOV DI, 1
		NEG AX		
	_push_digit_to_stack:
		XOR DX,DX
		DIV ten
		PUSH DX						;добавили в стек очередную цифру числа
		INC CX
		TEST AX,AX					;(логическое И)
		JNZ _push_digit_to_stack 	;если ax - не ноль, то добавляем следующую цифру		   
		MOV AH,40H
		CMP DI,1
		JNZ _PRINT
		MOV DL,'-'
		CALL WRITE_DL_TO_FILE
	_print:
		POP DX			;в dx - цифра, которую необходимо вывести
		ADD DL, '0'		;символ, выводимы на дисплей
		CALL WRITE_DL_TO_FILE
		LOOP _print   
			
		MOV DL, ' '
		CALL WRITE_DL_TO_FILE
		INC BX
		INC BX
		MOV AX,BX
		XOR DX,DX
		DIV TWO	
		XOR DX,DX	
		DIV N	
		CMP AX, M
		JGE _close		
		CMP DX, 0		
		JNE WRITE_NUMBER
		MOV DL, 0DH
		CALL WRITE_DL_TO_FILE
		MOV DL, 0AH
		CALL WRITE_DL_TO_FILE
		JMP WRITE_NUMBER
		
			
		
		_close:
		;закрыть описатель файла
		MOV AH, 3EH
		MOV BX, HANDLE
		INT 21H
				
		POP DI 	
		POP DX
		POP CX 
		POP BX 
		POP AX  
	RET 
	WRITE_MATRIX_TO_FILE ENDP
	
	WRITE_DL_TO_FILE PROC	;DL - символ, HANDLE - описатель файла
		PUSH AX
		PUSH BX
		PUSH CX		
		MOV DIGIT, DL
		LEA DX, DIGIT
		MOV BX, HANDLE
		MOV CX, 1
		MOV AH,40H
		int 21h
		POP CX
		POP BX
		POP AX
	WRITE_DL_TO_FILE ENDP

	TASK1 PROC			;возвращает в AX значение минимального элемента ниже побочной диагонали
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH DI
					
		MOV AX,N
		MUL M
		MOV CX,AX
		MUL two
		MOV BX, AX
		SUB BX,2
		MOV DI, MATRIX[BX]
		XOR BX,BX	
	task1_next:	
		MOV AX, BX
		XOR DX,DX
		DIV TWO
		DIV N
		ADD AX,DX
		CMP AX, min_m_n
		JL task1_go
		CMP DI,MATRIX[BX]				
		JLE task1_go
		MOV DI,MATRIX[BX]	 		
		task1_go:
		INC BX	
		INC BX		
		LOOP task1_next
			
		MOV AX,DI	
		POP DI 
		POP DX
		POP CX
		POP BX	
	RET
	TASK1 ENDP

	TASK2 PROC			;возвращает в AX индекс максимального элемента не ниже побочной диагонали
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH DI
				
		MOV AX,N
		MUL M
		MOV CX,AX
		MUL two
		MOV DI, 0
		XOR BX,BX	
	task2_next:	
		MOV AX, BX
		XOR DX,DX
		DIV TWO
		DIV N
		ADD AX,DX
		CMP AX, min_m_n
		JGE task2_go
		MOV AX,MATRIX[DI]
		CMP AX,MATRIX[BX]				
		JGE task2_go
		MOV DI,BX	 		
		task2_go:
		INC BX	
		INC BX		
		LOOP task2_next
			
		MOV AX,DI
		POP DI 
		POP DX
		POP CX
		POP BX	
	RET
	TASK2 ENDP

	TASK PROC
		PUSH AX
		PUSH BX
		
		CALL TASK2	;AX - индекс максимального элемента не ниже побочно диагонали
		MOV BX, AX  			
		CALL TASK1	;AX - минимальные элемент ниже побочной диагонали
		SUB MATRIX[BX], AX
				
		POP BX
		POP AX		
		RET
	TASK ENDP


	START:	
		MOV AX,@DATA
		MOV DS,AX
			
		LEA DX,MESSAGE
		MOV AH,09H
		INT 21H
		
		MOV AH,01h
		INT 21H
		CMP AL, 'M'
		JE MANUALLY		
		CMP AL, 'F'
		JE FROM_FILE
		JMP END_PROGRAM
	MANUALLY:
		CALL INPUT_MATRIX
		JMP START_GO	
	FROM_FILE:
		CALL READ_MATRIX_FROM_FILE
		START_GO:		
		CALL OUTPUT_MATRIX
		CALL TASK
		MOV AH, 02h
		MOV DL, 10	;enter
		INT 21h	
		CALL OUTPUT_MATRIX
		CALL WRITE_MATRIX_TO_FILE
		
		
	END_PROGRAM:
		MOV AH,4CH
		INT 21H    
		
	END START