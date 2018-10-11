.model small
.stack 256
.data
    a db 0
    b dw 0
    c dw 0
    d dw 0
    e dw 0
    i dw 0
    errorMessage1 db "Invalid input, uncorrect symbol,enter again$"
    errorMessage2 db "Invalid input, Number>65536, enter again$"
    errorMessage3 db "Division by zero, the result is not obtained$"
    remainder db "remainder$"
.code
PUTCHAR PROC
  PUSH BX
  PUSH AX
  PUSH CX
  PUSH DX
  MOV DX,0
  MOV BX,0
  MOV CX,0
  MOV CX,10
vivod:
  DIV CX
  PUSH AX
  PUSH DX
  INC BX
  CMP AX,0
  JZ exitVivod
  MOV DX,0
  JMP vivod
  exitVivod:
  MOV CX,BX
  cicle:
  POP DX
  POP AX
  ADD DX, 48
  MOV AH, 02h
  INT 21h
  LOOP cicle
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13
  MOV AH, 02h
  INT 21h
  POP DX
  POP CX
  POP AX
  POP BX
RET
PUTCHAR ENDP
	
GETCHAR PROC
  PUSH BX
  PUSH AX
  PUSH CX
  MOV AX,0
  MOV i, 0
  MOV BX,0
  MOV CX,10
  MOV b, 0
Vvod:
  MOV AH, 01h
  INT 21h
  MOV BL, 27
  CMP AL, BL
  JZ ESCape
  MOV BL, 8
  CMP AL,BL
  JNZ next1
  JMP BackSpace
next1:
  MOV BL,13
  CMP AL,BL
  JNZ next2
  JMP ExitVvod
next2:
  CMP AL,48
  JNC next3
  JMP Error
next3:
  MOV BL,57
  CMP BL,AL
  JNC next4
  JMP Error
next4:
  MOV CX,i
  INC CX
  MOV i,CX
  SUB AL, 48
  MOV a,AL
  MOV BL,1
  MUL BL
  MOV c,AX
  MOV AX,b
  MOV CX,10
  MUL CX
  JC Error2
  ADD AX,c
  JC Error2
  MOV b,AX
  JMP Vvod
ESCape:
  MOV AX, 0
  MOV b,AX
  MOV CX, i
  INC CX
cicleFor:
  MOV DL, 8
  MOV AH, 02h
  INT 21h
  MOV DL, 32
  MOV AH, 02h
  INT 21h
  MOV DL, 8
  MOV AH, 02h
  INT 21h
LOOP cicleFor
  JMP Vvod
Error2:
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13
  MOV AH, 02h
  INT 21h
  LEA DX, errorMessage2
  MOV AH, 09h
  INT 21h
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13
  MOV AH, 02h
  INT 21h
  MOV AX,0
  MOV BX,0
  MOV CX,10
  MOV b, 0
  JMP Vvod 
BackSpace:
  MOV CX,10
  MOV DX,0
  MOV AX,b
  DIV CX
  MOV b, AX
  MOV DX,0
  MOV DL, 32
  MOV AH, 02h
  INT 21h
  MOV DL, 8
  MOV AH, 02h
  INT 21h
  JMP Vvod
Error:
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13
  MOV AH, 02h
  INT 21h
  LEA DX, errorMessage1
  MOV AH, 09h
  INT 21h
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13
  MOV AH, 02h
  INT 21h
  MOV AX,0
  MOV BX,0
  MOV CX,10
  MOV b, 0
  JMP Vvod 
ExitVvod:
  POP CX
  POP AX
  POP BX
RET		
GETCHAR ENDP
main:
    mov ax, @data
    mov ds, ax
CALL GETCHAR
MOV AX,b
MOV d, AX
CALL PUTCHAR
CALL GETCHAR
MOV AX,b
MOV e, AX
CALL PUTCHAR
MOV AX, d
MOV BX, e
CMP BX, 0
JZ NULLdef
MOV DX,0
DIV BX
CALL PUTCHAR
PUSH DX
LEA DX, remainder
MOV AH, 09h
INT 21h
MOV DL, 10
MOV AH, 02h
INT 21h
MOV DL, 13
MOV AH, 02h
INT 21h
POP DX
MOV AX, DX
CALL PUTCHAR
JMP exit
NULLdef:
MOV DL, 10
MOV AH, 02h
INT 21h
MOV DL, 13
MOV AH, 02h
INT 21h
LEA DX, errorMessage3
MOV AH, 09h
INT 21h
MOV DL, 10
MOV AH, 02h
INT 21h
MOV DL, 13
MOV AH, 02h
INT 21h
exit:
    mov ax, 4c00h
    int 21h
end main