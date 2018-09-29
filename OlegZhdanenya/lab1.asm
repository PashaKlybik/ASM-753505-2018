model small
.stack 100h
.data
a dw 3
b dw 13
c dw 14
d dw 17

.code

start:
 MOV AX, @data
 MOV DS, AX
 
 MOV AX, a
 MUL a
 MUL a
 MOV BX, AX
 MOV AX, b
 MUL b
 CMP BX, AX
 JNZ next
 JMP all

 next:
	JNC next1
	JC secondresult
 
 next1:
	MOV AX, c
	MUL d
	MOV BX, AX
	MOV AX, a
	DIV b
	CMP AX, BX
	JZ firstresult
	JNZ secondresult2
	 MOV AX, 65535
	JMP all

 firstresult:
		MOV AX, a
		AND AX, b
		JMP all
 
 secondresult:
		MOV AX, c
		MUL d
		ADD AX, b
		JMP all
	
	secondresult2:
		MOV AX, c
		JMP all

 all:
 MOV AH, 4Ch
 INT 21h
end start