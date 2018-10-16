.model small
.stack 256
.data
   a db 0
   b dw 0
   c dw 0
   d dw 0
   e dw 0
   i dw 0
   ostatok db "Ostatok ot delenya: $"
   resultat db "Resultat delenya: $"
   errorMessage1 db "Error! Please, try again$"
   errorMessage2 db "Error!, Number>65536, try again$"
   errorMessage3 db "Division by zero!$"
.code

PUTCHAR PROC
    push BX
    push AX
    push CX
    push DX
    mov DX,0
    mov BX,0
    mov CX,0
    mov CX,10
write:
    div CX
    push AX
    push DX
    inc BX
    cmp AX,0
    jz exitWrite
    mov DX,0
    jmp Write
 exitWrite:
    mov CX,BX
 cicle:
    pop DX
    pop AX
    add DX, 48
    mov AH, 02h
    int 21h
 LOOP cicle
    mov DL, 10
    mov AH, 02h
    int 21h
    mov DL, 13
    mov AH, 02h
    int 21h
  pop DX
  pop CX
  pop AX
  pop BX
RET
PUTCHAR ENDP
	
GETCHAR PROC
    push BX
    push AX
    push CX
    mov AX,0
    mov i, 0
    mov BX,0
    mov CX,10
    mov b, 0
Read:
    mov AH, 01h
    int 21h
    mov BL, 27
    cmp AL, BL
    jz ESCape
    mov BL, 8
    cmp AL,BL
    jnz next1
    jmp BackSpace
next1:
    mov BL,13
    cmp AL,BL
    jnz next2
    jmp ExitRead
next2:
    cmp AL,48
    jnc next3
    jmp Error
next3:
    mov BL,57
    cmp BL,AL
    jnc next4
    jmp Error
next4:
    mov CX,i
    inc CX
    mov i,CX
    sub AL, 48
    mov a,AL
    mov BL,1
    mul BL
    mov c,AX
    mov AX,b
    mov CX,10
    mul CX
    jc Error2
    add AX,c
    jc Error2
    mov b,AX
    jmp Read
ESCape:
    mov AX, 0
    mov b,AX
    mov CX, i
    inc CX
cicleFor:
    mov DL, 8
    mov AH, 02h
    int 21h
    mov DL, 32
    mov AH, 02h
    int 21h
    mov DL, 8
    mov AH, 02h
    int 21h
LOOP cicleFor
    jmp Read
Error2:
    mov DL, 10
    mov AH, 02h
    int 21h
    mov DL, 13
    mov AH, 02h
    int 21h
    lea DX, errorMessage2
    mov AH, 09h
    int 21h
    mov DL, 10
    mov AH, 02h
    int 21h
    mov DL, 13
    mov AH, 02h
    int 21h
    mov AX,0
    mov BX,0
    mov CX,10
    mov b, 0
    jmp Read 
BackSpace:
    mov CX,10
    mov DX,0
    mov AX,b
    div CX
    mov b, AX
    mov DX,0
    mov DL, 32
    mov AH, 02h
    int 21h
    mov DL, 8
    mov AH, 02h
    int 21h
    jmp Read
Error:
    mov DL, 10
    mov AH, 02h
    int 21h
    mov DL, 13
    mov AH, 02h
    int 21h
    lea DX, errorMessage1
    mov AH, 09h
    int 21h
    mov DL, 10
    mov AH, 02h
    int 21h
    mov DL, 13
    mov AH, 02h
    int 21h
    mov AX,0
    mov BX,0
    mov CX,10
    mov b, 0
    jmp Read
ExitRead:
    pop CX
    pop AX
    pop BX
RET		
GETCHAR ENDP

main:
      mov ax, @data
      mov ds, ax
  call GETCHAR
  mov AX,b
  mov d, AX
  call PUTCHAR
  call GETCHAR
  mov AX,b
  mov e, AX
  call PUTCHAR
  mov AX, d
  mov BX, e
  cmp BX, 0
  jz NULLdef
  mov DX,0
  div BX
  push DX
  push AX
  lea DX, resultat
  mov AH, 09h
  int 21h
  mov DL, 10
  mov AH, 02h
  int 21h
  mov DL, 13
  mov AH, 02h
  int 21h
  pop AX
  pop DX
  call PUTCHAR
  push DX
  lea DX, ostatok
  mov AH, 09h
  int 21h
  mov DL, 10
  mov AH, 02h
  int 21h
  mov DL, 13
  mov AH, 02h
  int 21h
  pop DX
  mov AX, DX
  call PUTCHAR
  jmp exit
NULLdef:
  mov DL, 10
  mov AH, 02h
  int 21h
  mov DL, 13
  mov AH, 02h
  int 21h
  lea DX, errorMessage3
  mov AH, 09h
  int 21h
  mov DL, 10
  mov AH, 02h
  int 21h
  mov DL, 13
  mov AH, 02h
  int 21h
exit:
     mov ax, 4c00h
     int 21h
end main 