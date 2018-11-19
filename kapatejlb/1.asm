model small
.stack 100h  
.data

    amula dw 0
    bmulc dw 0
    cmulb dw 0
    ddivb dw 0
    cmulaminb dw 0
    aorb dw 0
    result dw 0

    a dw 21
    b dw 3
    c dw 147
    d dw 41

.code	
start:
    MOV AX, @data
    MOV DS, AX
				; start of prog
    MOV AX, a
    MUL a
    MOV amula, Ax

    MOV AX, b
    MUL c
    MOV  bmulc,AX

    MOV AX, c
    MUL b
    MOV  cmulb, AX
 
    MOV AX, d
    DIV b
    MOV ddivb, AX

    MOV AX, c
    MUL a
    SUB AX, b
    MOV cmulaminb, AX

    MOV AX, a
    OR AX, b
    MOV aorb, AX

    MOV AX, amula
    MOV BX, bmulc
    CMP AX, BX

    JNZ Neravno1
    JZ Ravno1

Neravno1:
    MOV AX, cmulaminb
    MOV result, AX
    JMP Endofprogram
Ravno1:
    MOV AX, cmulb
    MOV BX, ddivb

    CMP AX, BX

    JZ Ravno2
    JNZ Neravno2

Ravno2:
    MOV AX, aorb
    MOV result, AX
    JMP Endofprogram

Neravno2:
    MOV AX, c
    MOV result, AX
    JMP Endofprogram

Endofprogram:
    MOV AX, result
						;end of prog
    MOV AH, 4Ch
    INT 21h
end start
