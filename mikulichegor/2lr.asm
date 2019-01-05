.model small
.stack 256
.data
    a db 0
    b dw 0
    c dw 0
    d dw 0
    e dw 0
    f dw 0
    error_symbol db "Error! Enter again$"
    error_zero db "Error! Division by zero$"
    error_overflow db "Error! Enter again(more than 65536)$"    
    remainder_string db "Remainder: $"
    answer_string db "Answer: $"
 .code
 
; -----input procedure-----	
INPUT PROC
  PUSH BX
  PUSH AX
  PUSH CX
  MOV AX,0
  MOV f, 0
  MOV BX,0
  MOV CX,10
  MOV b, 0
reading:
  MOV AH, 01h
  INT 21h
  MOV BL, 27 ;escape
  CMP AL, BL
  JZ ESCape
  MOV BL, 8;backspace
  CMP AL,BL
  JNZ step
  JMP BackSpace
step:
  MOV BL,13 ;carriage return
  CMP AL,BL
  JNZ step_2
  JMP end_reading
step_2:
  CMP AL,48 ;char 0
  JNC step_3
  JMP Error
step_3:
  MOV BL,57 ;char 9
  CMP BL,AL
  JNC step_4
  JMP Error
step_4:
  MOV CX,f
  INC CX
  MOV f,CX
  SUB AL, 48 ;char 0
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
  JMP reading
ESCape:
  MOV AX, 0
  MOV b,AX
  MOV CX, f
  INC CX
cycle:
  MOV DL, 8 ;backspace
  MOV AH, 02h
  INT 21h
  MOV DL, 32 ;space
  MOV AH, 02h
  INT 21h
  MOV DL, 8
  MOV AH, 02h
  INT 21h
LOOP cycle
  JMP reading
Error2:
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13 ;carriage return
  MOV AH, 02h
  INT 21h
  LEA DX, error_overflow
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
  JMP reading
BackSpace:
  MOV CX,10
  MOV DX,0
  MOV AX,b
  DIV CX
  MOV b, AX
  MOV DX,0
  MOV DL, 32 ;space
  MOV AH, 02h
  INT 21h
  MOV DL, 8
  MOV AH, 02h
  INT 21h
  JMP reading
Error:
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13
  MOV AH, 02h
  INT 21h
  LEA DX, error_symbol
  MOV AH, 09h
  INT 21h
  MOV DL, 10
  MOV AH, 02h
  INT 21h
  MOV DL, 13 ;carriage return
  MOV AH, 02h
  INT 21h
  MOV AX,0
  MOV BX,0
  MOV CX,10
  MOV b, 0
  JMP reading
end_reading:
  POP CX
  POP AX
  POP BX
RET		
INPUT ENDP

;-----output procedure-----
OUTPUT PROC
  PUSH BX
  PUSH AX
  PUSH CX
  PUSH DX
  MOV DX,0
  MOV BX,0
  MOV CX,0
  MOV CX,10
write:
  DIV CX
  PUSH AX
  PUSH DX
  INC BX
  CMP AX,0
  JZ exitWrite
  MOV DX,0
  JMP Write
 exitWrite:
  MOV CX,BX
 cyc:
  POP DX
  POP AX
  ADD DX, 48
  MOV AH, 02h
  INT 21h
 LOOP cyc
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
OUTPUT ENDP
;-----main-----
 main:
    mov ax, @data
    mov ds, ax
CALL INPUT
MOV AX,b
MOV d, AX
CALL OUTPUT
CALL INPUT
MOV AX,b
MOV e, AX
CALL OUTPUT
MOV AX, d
MOV BX, e
CMP BX, 0
JZ NULLdef
MOV DX,0
DIV BX
PUSH DX
PUSH AX
LEA DX, answer_string
MOV AH, 09h
INT 21h
MOV DL, 10
MOV AH, 02h
INT 21h
MOV DL, 13
MOV AH, 02h
INT 21h
POP AX
POP DX
CALL OUTPUT
PUSH DX
LEA DX, remainder_string
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
CALL OUTPUT
JMP exit
NULLdef:
MOV DL, 10
MOV AH, 02h
INT 21h
MOV DL, 13
MOV AH, 02h
INT 21h
LEA DX, error_zero
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
 