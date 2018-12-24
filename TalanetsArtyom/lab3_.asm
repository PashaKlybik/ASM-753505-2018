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

INPUT PROC 
	PUSH BX
	PUSH AX			;÷èñëî ïðè âûõîäå èç ïðîöåäóðû
    PUSH CX 		;õðàíèì ÷èñëî âî âðåìÿ èñïîëíåíèÿ
    PUSH DX  
    PUSH SI    		;si = 1 <=> cx=0, íî â êîíñîëü íå î÷èùåíà
    PUSH DI			;di = 1 <=> ÷èñëî îòðèöàòåëüíîå
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
    CMP AL, 13			;ïðîâåðêà íà enter
    JE _press_enter
    CMP AL, 8			;ïðîâåðêà íà backspace
    JE press_backspace 	
    CMP AL, 27			;ïðîâåðêà íà escape
    JE press_escape 
    CMP AL, '-'			;ïðîâåðêà íà ìèíóñ
    JE press_minus   
    CMP AL, '0'			;Åñëè êîä ñèìâîëà ìåíüøå êîäà '0', òî 
    JL delete_symbol	;óäàëÿåì ñèìâîë
    CMP AL,'9'          ;Åñëè êîä ñèìâîëà áîëüøå êîäà '9', òî
    JG delete_symbol	;óäàëÿåì ñèìâîë
    SUB AL, '0'
	CBW 				;ðàñøèðÿåì al íà ax       
    MOV BX, AX
   
	MOV AX, CX
    MUL ten
	JC delete_symbol      ;åñëè ïåðåíîñ - îøèáêà
    JO delete_symbol      ;Åñëè ïåðåïîëíåíèå - îøèáêà
	ADD AX, BX
	JC delete_symbol      ;Åñëè ïåðåíîñ - îøèáêà
    JO delete_symbol      ;Åñëè ïåðåïîëíåíèå - îøèáêà
    CMP AX, 32767
    JG delete_symbol      ;Åñëè ïåðåíîñ - îøèáêà
 
	;MOV AX, 10
    ;MUL CX
    ;CMP DX, 0
	;JG delete_symbol	;åñëè ïåðåïîëíåíèå
	;JG input_loop
	;ADD AX, BX
    ;JB delete_symbol	;åñëè ïåðåïîëíåíèå
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
	;ñìîòðè çíàê
    CMP CX, 0
    JNE lbl88
    MOV DI, 0
    lbl88:
    ;äåëèì cx íà 10
    MOV AX,CX
    MOV BX,10
    XOR DX,DX
    DIV BX
    MOV CX,AX
    ;óäàðÿåì ñèìâîë
	MOV AH,02h
    MOV DL,' '		;ïåðåçàïèñûâàåì ïîñëåäíèé ñèìâîë íà ïðîáåë
    INT 21h
    MOV DL,8		;äâèãàåì êîðåòêó âëåâî
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
       MOV DL, 8		;äâèãàåì êîðåòêó âëåâî
       MOV AH, 02h
       INT 21H
       MOV DL,' '	;ïåðåçàïèñûâàåì ïîñëåäíèé ñèìâîë íà ïðîáåë
       INT 21H
       MOV DL,8		;äâèãàåì êîðåòêó âëåâî
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
	PUSH DI 			;di = 1 <=> ÷èñëî îòðèöàòåëüíîå
	
	XOR CX, CX
	XOR DI, DI
	
	OR AX, AX
	JNS push_digit_to_stack
	MOV DI, 1
	NEG AX
	
push_digit_to_stack:
    XOR DX,DX
    DIV ten
    PUSH DX						;äîáàâèëè â ñòåê î÷åðåäíóþ öèôðó ÷èñëà
    INC CX
    TEST AX, AX					;(ëîãè÷åñêîå È)
    JNZ push_digit_to_stack 	;åñëè ax - íå íîëü, òî äîáàâëÿåì ñëåäóþùóþ öèôðó
       
    MOV AH, 02h
    CMP DI, 1
    JNZ PRINT
    MOV DX, '-'
    INT 21h
print:
	POP DX			;â dx - öèôðà, êîòîðóþ íåîáõîäèìî âûâåñòè
    ADD DL, '0'		;ñèìâîë, âûâîäèìû íà äèñïëåé
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
    
SIGNED_DIVISION PROC;äåëåíèå ñî çíàêîì, 
					;âõîä: AX - äåëèìîå, BX - äåëèòåëü
					;âûõîä: AX - ÷àñòíîå
	PUSH DX	
	XOR DX, DX		;dx = 0 <=> äåëèìîå ïîëîæèòåëüíîå
	OR AX, AX		;ïðîâåðÿåì çíàê äåëèìîãî
	JNS division	;åñëè äåëèìîå ïîëîæèòåëüíîå, îñòàâëÿåì  dx = 0
	SUB DX, 1		;åñëè äåëèìîå îòðèöàòåëüíî, òî dx=1..1 
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
