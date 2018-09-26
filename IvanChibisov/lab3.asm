.model small
.stack 256
.data
    a db 0
    b dw 0
    c dw 0
    d dw 0
    e dw 0
    i dw 0
    sig dw 0
    sig1 dw 0
    sig2 dw 0
    rez dw 0
    errorMessage1 db "Invalid input, uncorrect symbol,enter again$"
    errorMessage2 db "Invalid input, Number<-32768 AND Number>32767, enter again$"
    errorMessage3 db "Division by zero, the result is not obtained$"
.code
	PUTCHARSIGNUM PROC
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		MOV DX,0
		MOV BX,0
		MOV CX,0
		SHL AX,1
		JNC VVnext1
		MOV DL, 45
		MOV AH, 02h
		INT 21h
		MOV DX, 0
		MOV AX,b
		NEG AX
		JMP vivod
		VVnext1:
		MOV DX, 0
		MOV AX, b
	vivod:
		MOV CX,10
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
	PUTCHARSIGNUM ENDP
	
	GETCHARSIGNUM PROC
		PUSH BX
		PUSH AX
		PUSH CX
		MOV AX,0
		MOV sig, AX
		MOV i, AX
		MOV BX,0
		MOV CX,10
		MOV b, 0
	Vvod:
		MOV AH, 01h
		INT 21h
		MOV CX,i
		INC CX
		MOV i,CX
		MOV BL, 27
		CMP AL, BL
		JNZ next12
		JMP ESCape
	next12:
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
			CMP AL, 45
			JZ next5 
			JMP Error
		next5:
			MOV rez, CX
			MOV CX, i
			CMP CX, 1
			JZ SIGNUM
			JMP Error 
		SIGNUM:
			MOV rez, CX
			MOV CX, 1
			MOV sig, CX
			JMP Vvod	  	
		next3:
			MOV BL,57
			CMP BL,AL
			JNC next4
			JMP Error
		next4:
			SUB AL, 48
			MOV a,AL
			MOV BL,1
			MUL BL
			MOV c,AX
			MOV AX,b
			MOV CX,10
			MUL CX
			JNC next6
			JMP Error2
		next6:
			ADD AX,c
			JNC next11
			JMP Error2
		next11:
			PUSH CX
			MOV CX, 32768
			CMP CX, AX
			POP CX
			JZ next10
			JNC next7 
			JMP Error2
		next10:
			PUSH CX
			MOV CX, sig
			CMP CX, 1
			POP CX
			JZ next7 
			JMP Error2
		next7: 
			MOV b,AX
			JMP Vvod
	ESCape:
		MOV AX, 0
		MOV b,AX
		MOV CX, i
		INC CX
		MOV i, AX
		MOV sig, AX
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
		MOV i,AX
		MOV sig, AX
		JMP Vvod 
	BackSpace:
		MOV CX,i
		DEC CX
		DEC CX
		MOV i,CX
		MOV CX,i
		CMP CX, 0
		JNZ next8
		MOV CX, 2
		MOV i, CX
		JMP ESCape
	next8:	
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
		MOV i,AX
		MOV sig, AX
		JMP Vvod 
	ExitVvod:
		MOV AX, b
		MOV CX, sig
		CMP CX, 1
		JNZ EXITT
		NEG AX
		MOV b, AX
	EXITT:
		POP CX
		POP AX
		POP BX
		RET		
	GETCHARSIGNUM ENDP
main:
    mov ax, @data
    mov ds, ax
    	
	CALL GETCHARSIGNUM
	MOV AX,b
	MOV d, AX
	MOV b, AX
	CALL PUTCHARSIGNUM
	CALL GETCHARSIGNUM
	MOV AX,b
	MOV e, AX
	MOV b, AX
	CALL PUTCHARSIGNUM
	MOV AX, d
	MOV BX, e
	CMP BX, 0
	JZ NULLdef
	CWD
	IDIV BX
	MOV b, AX
	CALL PUTCHARSIGNUM
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
	exit:

    mov ax, 4c00h
    int 21h
end main