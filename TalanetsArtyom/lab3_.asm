.MODEL SMALL
.STACK 100h

.DATA
	ten dw 10
	endl db 13, 10, '$'
	errorInput db "Input error", 13, 10, '$'
	errorDivByZero db "Division by zero", 13, 10, '$'
	buffer   db 7,  256 dup(?)
.CODE

END_LINE PROC
	PUSH AX
	MOV AH, 9
	LEA DX, ENDL
	INT 21h
	POP AX	
RET
END_LINE ENDP

COMPARING_NUMBER PROC
	
RET
COMPARING_NUMBER ENDP

INPUT PROC 
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
 
	;MOV AX, 10
    ;MUL CX
    ;CMP DX, 0
	;JG delete_symbol	;если переполнение
	;JG input_loop
	;ADD AX, BX
    ;JB delete_symbol	;если переполнение
    ;JB input_loop	
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
INPUT ENDP

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

OUTPUT PROC
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
    CALL END_LINE
    
    POP DI 	
	POP DX
    POP CX 
    POP BX 
    POP AX  
RET
OUTPUT ENDP

CHECK_DIV_BY_ZERO PROC
	PUSH AX
	XOR AX, AX  
	CMP BX, AX
	JNZ NO_ERROR
    MOV AH, 9
    LEA DX, ERRORDIVBYZERO
    INT 21h      
    JMP END_PROGRAM   
no_error:    
    POP AX
RET
CHECK_DIV_BY_ZERO ENDP
    
SIGNED_DIVISION PROC;деление со знаком, 
					;вход: AX - делимое, BX - делитель
					;выход: AX - частное
	PUSH DX	
	XOR DX, DX		;dx = 0 <=> делимое положительное
	OR AX, AX		;проверяем знак делимого
	JNS division	;если делимое положительное, оставляем  dx = 0
	SUB DX, 1		;если делимое отрицательно, то dx=1..1 
division:		
	CALL CHECK_DIV_BY_ZERO
	IDIV BX	
	POP DX
RET
SIGNED_DIVISION ENDP


START:	
    MOV AX,@DATA
	MOV DS,AX
		
	CALL INPUT      
   	CALL OUTPUT
	MOV BX, AX
	CALL INPUT      
   	CALL OUTPUT   	
	XCHG AX, BX
	
	CALL SIGNED_DIVISION		
	CALL OUTPUT
	
END_PROGRAM:
    MOV AH,4CH
    INT 21H    
    
END START