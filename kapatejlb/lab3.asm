model small			; модель памяти
.stack 100h         ; установка размера стека
.data

devident dw 0
devider dw 0
temporary dw 0

currentpos dw ?

tempsign dw ?
signfirst dw ? ;если 1, то +, а если 0, то -
signsecond dw ?

enterdevident db "Enter devident: ", '$'
enterdevider db "Enter devider: ", '$'
repeat db 13, 10,"Repeat please!", 13, 10, '$'
wholerespos db "Result: ", '$'
wholeresneg db "Result: -", '$'
fractional db ", fractional = $"
errorzero db "Division by zero!", 13, 10, '$'
n db 10,"$"
u dw 10
ost dw ?
cel dw ?

.code

InputInt proc	;ввод в АX 

	mov currentpos, 0 

	entersymb:
		MOV AH, 01h
		INT 21h
		xor ah, ah

		add currentpos, 1

		cmp ax, 43
		jz plus

		cmp ax, 45
		jz minus

	usuallyint:
	CMP AX, 13 ;проверка на энтр
	JZ end1
	CMP AX, 48 ;проверка на 0-9
	JC error
	CMP AX, 57
	JZ continusiallyint
	JNC error

	continusiallyint:
		SUB AL, 48
		MOV AH, 0
		MOV BX, AX
		MOV AX, temporary
		MUL u
		JC error
		ADD AX, BX
		JC error
		MOV temporary, AX
		JMP entersymb

	plus:
		mov tempsign, 1
		cmp currentpos, 1
		jz entersymb
		jmp error

	minus:
		mov tempsign, 0
		cmp currentpos, 1
		jz entersymb
		jmp error

	error:
		mov currentpos, 0
		LEA DX, repeat
		MOV AH, 09h
		INT 21h
		MOV AX, 0
		MOV temporary, AX
		JMP entersymb

	end1:
	ret
InputInt endp

OutputInt proc
	MOV CX, 0
	next:
		MOV DX, 0
		DIV u
		PUSH DX
		MOV DX, 0
		INC CX
		CMP AX, 0
		JNZ next

	cycle:
		POP DX
		MOV DH, 0
		ADD DL, 48
		MOV AH, 02h
		INT 21h
		LOOP cycle

	ret
OutputInt endp

stasyan proc
	push ax
	push dx

	lea dx, n
	mov ah, 09h
	int 21h

	pop dx
	pop ax

	ret
stasyan endp

start: 
MOV AX, @data
MOV DS, AX

LEA DX, enterdevident
MOV AH, 09h
INT 21h
call InputInt
push temporary
pop devident
mov temporary, 0

mov ax, tempsign
mov signfirst, ax

LEA DX, enterdevider
MOV AH, 09h
INT 21h
call InputInt
push temporary
pop devider
mov temporary, 0

mov ax, tempsign
mov signsecond, ax

cmp devider, 0
jz altendofprog

mov ax, devident
cwd
div devider

mov cel, ax ;ax=целое
mov ost, dx ;dx=остаток

mov ax, signfirst
cmp ax, signsecond
jz ansplus
jnz ansminus

ansplus:
LEA DX, wholeresneg
MOV AH, 09h
INT 21h
mov ax, cel
call outputint
jmp enddd

ansminus:
LEA DX, wholerespos
MOV AH, 09h
INT 21h
mov ax, cel
call outputint
jmp enddd

enddd:
call stasyan

MOV AH, 4Ch
INT 21h

altendofprog:
LEA DX, errorzero
MOV AH, 09h
INT 21h

MOV AH, 4Ch
INT 21h
end start 
