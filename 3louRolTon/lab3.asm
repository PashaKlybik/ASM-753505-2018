.model small
.386
.stack 100h
.data
    ten dw 10 
    zero db '0'
    messageDivident db "Divident: ", 10, 13, '$'
    messageDivisor db 10, 13, "Divisor: ", 10, 13, '$'
    messageLongInput db 10, 13, "Error: too long number.", 10, 13, '$'
    messageIncorrect db 10, 13, "Error: incorrect symbol.", 10, 13, '$'
    messageDividingByZero db 10, 13, "Error: dividing by zero.", 10, 13, '$'
    messageResult db 10, 13, "Result: $"
	messageOverflow db 10, 13, "Error: overflow.", 10, 13, '$'
.code

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
    PUSH DX			
    INC CX
    CMP AX, 0
    JNZ DivCycle
    
OutCycle:
    POP DX			
    ADD DL, zero	
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
    
    TEST AX, 1000000000000000b		
    JZ Print						
    PUSH AX
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    POP AX
    NEG AX							
Print:
    CALL Output						
    
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
    XOR BX, BX						
    XOR SI, SI						
    MOV AH, 01h
    INT 21h
    CMP AL, '-'						
    JNZ Continue					
    MOV SI, 1
    INC DI
    
Cycle:
    MOV AH, 01h
    INT 21h
Continue:
	INC DI
    CMP AL, 13						
    JZ Next							
    CMP AL, 8						
    JZ Backspace
    CMP AL, 1Bh						
    JZ Escape
    SUB AL, zero					
    CMP AL, 10
    JNC WrongInput				
    XOR CX, CX
    MOV CL, AL					
    MOV AX, BX
    MUL ten
    CMP DX, 0
    JNZ Overflow					
    ADD AX, CX
    JC Overflow
    MOV DX, 32767
    CMP SI, 1
    JNZ EndOfCycle				
    INC DX						
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
    DIV ten
    MOV BX, AX
    CMP BX, 0
    JNZ Cycle
    
    MOV AH, 03h
    INT 10h
    CMP DL, 0				
    JZ StartInput			
    JMP Cycle
    
Escape:
    XOR BX, BX				
    XOR SI, SI
    MOV CX, DI
	XOR DI, DI
    INC CX
BackLoop:
    MOV DL, 8				
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


Delete PROC 			
    PUSH AX 			
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
    
    LEA DX, messageDivident
    MOV AH, 09h
    INT 21h
    CALL InputSigned
    CALL OutputSigned
    PUSH AX
    
    LEA DX, messageDivisor
    MOV AH, 09h
    INT 21h
    CALL InputSigned
    CALL OutputSigned
    CMP AX, 0
    JZ DividingByZeroException
    CMP AX, -1
    JNZ Dividing
    POP BX
    CMP BX, 8000h
    PUSH BX
    JNZ Dividing
    LEA DX, messageOverflow
    MOV AH, 09h
    INT 21h
    JMP ProgramFinish
    
Dividing:	
    MOV CX, AX
    POP AX
    CWD
    IDIV CX

    PUSH AX
    LEA DX, messageResult
    MOV AH, 09h
    INT 21h
    POP AX
    CALL OutputSigned

    MOV AH, 09h
    INT 21h
    POP AX

    JMP ProgramFinish
    
DividingByZeroException:
    LEA DX, messageDividingByZero
    MOV AH, 09h
    INT 21h
    
ProgramFinish:
    MOV AX, 4c00h
    INT 21h

end main
