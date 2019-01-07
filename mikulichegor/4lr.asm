.model small
.stack 256
.386
.data    
    max db 50 ;----our string
    len db ?
    string db 100 dup('$')    
    vowels_length db 13  ;----string of vowels
    vowels_string db "AEIOUYaeiouy$"
.code

;-----NEWLINE PROCEDURE-----
newline PROC
    PUSH AX
    PUSH DX
      MOV AH, 02h
      MOV DL, 13
      INT 21h
      MOV DL, 10
      INT 21h
    POP DX
    POP AX
RET
newline ENDP

;-----COUNTER PROCEDURE-----
vowels_counter PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI	
    MOVZX CX, len
    XOR AX, AX ;---counter---
    XOR SI, SI ;---indexer---
    CALL is_symbol
    INC SI

    begin_of_word: ;---checking for the beginning of the word---
        MOV DL, string[SI - 1] 
        CMP DL, ' '
        JNE nextSymbol
        CALL is_symbol	    	
        nextSymbol:
        INC SI
    loop begin_of_word

    POP SI
    POP DX
    POP CX
    POP BX
RET
vowels_counter ENDP

;---SEARCHING VOWELS PROCEDURE---
is_symbol PROC
    PUSH CX
    PUSH AX
    MOV AL, string[SI]
    LEA DI, vowels_string
    MOVZX CX, vowels_length
    REPNE SCASB ;---scanning for comparing---
    JNE exitFromChecking
    POP AX 
    INC AX ;---if we found a symbol - increment counter---
    PUSH AX
    exitFromChecking:
        POP AX
        POP CX
RET
is_symbol ENDP

;---OUTPUT PROCEDURE---
output PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX ;---counter of numbers---
    MOV BX,10 	
    
    cycle: ;while numbers more than 10 - division by 10 + reminder in stack
        CMP AX, 10 
        JC exit
        MOV DX, 0 
        DIV BX
        PUSH DX
        INC CX
        JMP cycle
        exit:		
            PUSH AX
            INC CX 		
    output_stack:		
        POP DX	
        ADD DX, 48
        MOV AH, 02h
        INT 21h
    LOOP output_stack 	
    POP DX
    POP CX
    POP BX
    POP AX
RET
output ENDP

main:
    MOV ax, @data
    MOV ds, ax
    MOV es, ax
    LEA DX, max 
    MOV AH, 0aH
    INT 21h	
    call newline
    call vowels_counter
    call output
    call newline   
    MOV ax, 4c00h
    INT 21h	
end main