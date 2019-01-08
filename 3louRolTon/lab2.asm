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

Input PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    XOR BX, BX
    XOR SI, SI
InCycle:
    MOV AH, 01h
    INT 21h
    
    CMP AL, 13			
    JZ FinishInput
    CMP AL, 8		
    JZ Backspace
    CMP AL, 1Bh			
    JZ Escape
    
    SUB AL, zero		
    CMP AL, 10
    JNC WrongInput		
    XOR CH, CH
    MOV CL, AL		
    MOV AX, BX			
    MUL ten
    CMP DX, 0		
    JNZ Overflow
    ADD AX, CX
    JC Overflow
    MOV BX, AX
    INC SI
    JMP InCycle
    
Backspace:
    CALL Delete
    MOV AX, BX
    XOR DX, DX
    DIV ten
    MOV BX, AX
    JMP InCycle
    
Escape:
    MOV CX, SI
    XOR SI, SI
    XOR BX, BX
    INC CX
ClearLoop:
    MOV DL, 8		
    MOV AH, 02h
    INT 21h
    CALL Delete
    LOOP ClearLoop
    JMP InCycle
    
Overflow:
    LEA DX, messageLongInput
    MOV AH, 09h
    INT 21h
    JMP FinishInput
    
WrongInput:
    LEA DX, messageIncorrect
    MOV AH, 09h
    INT 21h
    
FinishInput:
    MOV AX, BX
    POP SI
    POP DX
    POP CX
    POP BX
    RET
Input ENDP


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
    CALL Input
    CALL Output
    PUSH AX
    
    LEA DX, messageDivisor
    MOV AH, 09h
    INT 21h
    CALL Input
    CALL Output
    CMP AX, 0
    JZ DividingByZeroException
    
    MOV CX, AX		
    POP AX			
    XOR DX, DX
    DIV CX
    PUSH DX
    PUSH AX
    LEA DX, messageResult
    MOV AH, 09h
    INT 21h
    POP AX
    CALL Output

    MOV AH, 09h
    INT 21h
    POP AX

    JMP Exit
    
DividingByZeroException:
    LEA DX, messageDividingByZero
    MOV AH, 09h
    INT 21h
    
Exit:
    MOV AX, 4c00h
    INT 21h

end main
