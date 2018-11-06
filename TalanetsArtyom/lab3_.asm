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
	PUSH AX			;����� ��� ������ �� ���������
    PUSH CX 		;������ ����� �� ����� ����������
    PUSH DX  
    PUSH SI    		;si = 1 <=> cx=0, �� � ������� �� �������
    PUSH DI			;di = 1 <=> ����� �������������
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
    CMP AL, 13			;�������� �� enter
    JE _press_enter
    CMP AL, 8			;�������� �� backspace
    JE press_backspace 	
    CMP AL, 27			;�������� �� escape
    JE press_escape 
    CMP AL, '-'			;�������� �� �����
    JE press_minus   
    CMP AL, '0'			;���� ��� ������� ������ ���� '0', �� 
    JL delete_symbol	;������� ������
    CMP AL,'9'          ;���� ��� ������� ������ ���� '9', ��
    JG delete_symbol	;������� ������
    SUB AL, '0'
	CBW 				;��������� al �� ax       
    MOV BX, AX
   
	MOV AX, CX
    MUL ten
	JC delete_symbol      ;���� ������� - ������
    JO delete_symbol      ;���� ������������ - ������
	ADD AX, BX
	JC delete_symbol      ;���� ������� - ������
    JO delete_symbol      ;���� ������������ - ������
    CMP AX, 32767
    JG delete_symbol      ;���� ������� - ������
 
	;MOV AX, 10
    ;MUL CX
    ;CMP DX, 0
	;JG delete_symbol	;���� ������������
	;JG input_loop
	;ADD AX, BX
    ;JB delete_symbol	;���� ������������
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
	;������ ����
    CMP CX, 0
    JNE lbl88
    MOV DI, 0
    lbl88:
    ;����� cx �� 10
    MOV AX,CX
    MOV BX,10
    XOR DX,DX
    DIV BX
    MOV CX,AX
    ;������� ������
	MOV AH,02h
    MOV DL,' '		;�������������� ��������� ������ �� ������
    INT 21h
    MOV DL,8		;������� ������� �����
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
       MOV DL, 8		;������� ������� �����
       MOV AH, 02h
       INT 21H
       MOV DL,' '	;�������������� ��������� ������ �� ������
       INT 21H
       MOV DL,8		;������� ������� �����
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
	PUSH DI 			;di = 1 <=> ����� �������������
	
	XOR CX, CX
	XOR DI, DI
	
	OR AX, AX
	JNS push_digit_to_stack
	MOV DI, 1
	NEG AX
	
push_digit_to_stack:
    XOR DX,DX
    DIV ten
    PUSH DX						;�������� � ���� ��������� ����� �����
    INC CX
    TEST AX, AX					;(���������� �)
    JNZ push_digit_to_stack 	;���� ax - �� ����, �� ��������� ��������� �����
       
    MOV AH, 02h
    CMP DI, 1
    JNZ PRINT
    MOV DX, '-'
    INT 21h
print:
	POP DX			;� dx - �����, ������� ���������� �������
    ADD DL, '0'		;������, �������� �� �������
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
    
SIGNED_DIVISION PROC;������� �� ������, 
					;����: AX - �������, BX - ��������
					;�����: AX - �������
	PUSH DX	
	XOR DX, DX		;dx = 0 <=> ������� �������������
	OR AX, AX		;��������� ���� ��������
	JNS division	;���� ������� �������������, ���������  dx = 0
	SUB DX, 1		;���� ������� ������������, �� dx=1..1 
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