.model small
.stack 256
.data
    abc dw 0
    abc1 dw 0
    abc2 dw 0
    a db 0
    b dw 0
    c dw 0
    d dw 0
    e dw 0
    i dw 0
    rez dw 0
    ostatok db "Ostatok ot delenya: $"
    resultat db "Resultat delenya: $"
    errorMessage1 db "Error! Try again$"
    errorMessage2 db "Error!, Number<-32768 AND Number>32767, Try again$"
    errorMessage3 db "Division by zero!$"
    .code
PUTCHARSIGNUM PROC
    push BX
    push AX
    push CX
    push DX
    mov DX,0
    mov BX,0
    mov CX,0
    shl AX,1
    jnc Wnext1
    mov DL, 45
    mov AH, 02h
    int 21h
    mov DX, 0
    mov AX,b
    neg AX
    jmp Write
 Wnext1:
    mov DX, 0
    mov AX, b
 Write:
    mov CX,10
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
   loop cicle
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
PUTCHARSIGNUM ENDP
	
GETCHARSIGNUM PROC
    push BX
    push AX
    push CX
    mov AX,0
    mov abc, AX
    mov i, AX
    mov BX,0
    mov CX,10
    mov b, 0
 Read:
    mov AH, 01h
    int 21h
    mov CX,i
    inc CX
    mov i,CX
    mov BL, 27
    cmp AL, BL
    jnz next12
    jmp ESCape
 next12:
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
    cmp AL, 45
    jz next5 
    jmp Error
 next5:
    mov rez, CX
    mov CX, i
    cmp CX, 1
    jz SIGNUM
    jmp Error 
 SIGNUM:
    mov rez, CX
    mov CX, 1
    mov abc, CX
    jmp Read	  	
 next3:
    mov BL,57
    cmp BL,AL
    jnc next4
    jmp Error
 next4:
    sub AL, 48
    mov a,AL
    mov BL,1
    mul BL
    mov c,AX
    mov AX,b
    mov CX,10
    mul CX
    jnc next6
    jmp Error2
 next6:
    add AX,c
    jnc next11
    jmp Error2
 next11:
    push CX
    mov CX, 32768
    cmp CX, AX
    pop CX
    jz next10
    jnc next7 
    jmp Error2
 next10:
    push CX
    mov CX, abc
    cmp CX, 1
    pop CX
    jz next7 
    jmp Error2
 next7: 
    mov b,AX
    jmp Read
 ESCape:
    mov AX, 0
    mov b,AX
    mov CX, i
    inc CX
    mov i, AX
    mov abc, AX
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
   loop cicleFor
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
    mov i,AX
    mov abc, AX
    jmp Read 
 BackSpace:
    mov CX,i
    dec CX
    dec CX
    mov i,CX
    mov CX,i
    cmp CX, 0
    jnz next8
    mov CX, 2
    mov i, CX
    jmp ESCape
 next8:	
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
    mov i,AX
    mov abc, AX
    jmp Read 
 ExitRead:
    mov AX, b
    mov CX, abc
    cmp CX, 1
    jnz EXITT
    neg AX
    mov b, AX
 EXITT:
    pop CX
    pop AX
    pop BX 
RET		
GETCHARSIGNUM ENDP

main:
     mov ax, @data
     mov ds, ax
   call GETCHARSIGNUM
   mov AX,b
   mov d, AX
   mov b, AX
   call PUTCHARSIGNUM
   call GETCHARSIGNUM
   mov AX,b
   mov e, AX
   mov b, AX
   call PUTCHARSIGNUM
   mov AX, d
   mov BX, e
   cmp BX, 0
   jz NULLdef
   CWD
   IDIV BX
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
   mov b, AX
   call PUTCHARSIGNUM
   push DX
   push AX
   lea DX, ostatok
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
   mov AX,DX
   mov b, AX
   call PUTCHARSIGNUM
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
exit:
    mov ax, 4c00h
    int 21h
end main