model small
.stack 100h         
.data 			

u dw 10
strmin db "-$"
rows dw 0
cols dw 0
sum dw 0
array dw 50*50 dup(0)
array2 dw 50*50 dup(0)
array3 dw 50*50 dup(0)
msgErr db 13, 10, "Repeat please!$"
msgOv db 13, 10, "Overfloat in process$"
msgRo db 13, 10, "Input count of rows: $"
msgCo db 13, 10, "Input count of colums: $"
msgEl db 13, 10, "Input elements: ", 13, 10, "$"
msgSu db 13, 10, "Max Matrix: ",  13, 10, "$"
msgEn db 13, 10, "$"
msgMa db 13, 10, "Your 1 matrix : ", 13, 10, "$"
msgMa2 db 13, 10, "Your 2 matrix : ", 13, 10, "$"
msgNewLine db 13, 10, "$"

repeat db 13, 10,"Repeat please!", 13, 10, '$'
temporary dw 0
unusial dw -32768
currentpos dw ?
isnegative dw ?

.code	

proc InputElements
mov ax, rows
mul cols ;v ax kol elementov
mov cx, ax
qwe:
	call inputint
	mov ax, temporary
	mov [si], ax
	inc si 
	inc si
	loop qwe

	ret
InputElements endp

InputInt proc
push ax
push bx
push cx
push dx
	
	mov temporary, 0
	mov currentpos, 0
	mov isnegative, 0

	entersymb:
		add currentpos, 1

		MOV AH, 01h
		INT 21h
		xor ah, ah

		cmp ax, 43
		jz plus

		cmp ax, 45
		jz minus	

	usiallint:
		CMP AX, 13 ;проверка на энтр
		JZ end1
		CMP AX, 48 ;проверка на 0-9
		JC error
		CMP AX, 58
		;Jc usiallint
		JNC error

	contin:
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
		cmp currentpos, 1
		jz positive
		jmp error

	positive:
		mov isnegative, 0
		jmp entersymb

	minus:
		cmp currentpos, 1
		jz negative
		jmp error

	negative:
		mov isnegative, 1
		jmp entersymb

	error:
		mov currentpos, 0
		mov isnegative, 0
		LEA DX, repeat
		MOV AH, 09h
		INT 21h
		MOV AX, 0
		MOV temporary, AX
		JMP entersymb

	makeneg:
		neg temporary
		jmp end2

	end1:
		cmp isnegative, 1
		jz makeneg

	end2:
		mov cx, temporary
		cmp cx,unusial
		jz error

	pop dx
	pop cx
	pop bx
	pop ax
	ret
InputInt endp

proc OutputMass


	MOV BX, rows
	PUSH BX
	MOV BX, cols
	PUSH BX

outstr:
	MOV AX, [SI]
	TEST AX, 1000000000000000b
	JZ next
	LEA DX, strmin
	PUSH AX
	MOV AH, 09h
	INT 21h
	POP AX
	NEG AX

next:
	MOV DX, 0
	IDIV u
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

	INC SI
	INC SI
	POP BX
	DEC BX
	CMP BX, 0
	JZ zero
	PUSH BX
	MOV DL, 9
	MOV AH, 2

	INT 21h
	JMP outstr

zero:
	POP BX
	DEC BX
	CMP BX, 0
	JZ zero2
	PUSH BX
	MOV BX, cols
	PUSH BX
	LEA DX, msgEn
	MOV AH, 09h
	INT 21h
	JMP outstr

zero2:

ret
OutputMass endp



start:
MOV AX, @data
MOV DS, AX

startRo:
	LEA DX, msgRo
	MOV AH, 09h
	INT 21h
	enterRo:
	MOV AH, 01h
	INT 21h
	MOV AH, 0
	CMP AX, 13
	JZ startCo
	CMP AX, 48
	JC errorRo
	CMP AX, 57
	JZ J9a
	JNC errorRo
	J9a:
	SUB AL, 48
	MOV AH, 0
	MOV BX, AX
	MOV AX, rows
	MUL u
	JC errorRo
	ADD AX, BX
	JC errorRo
	MOV rows, AX
	JMP enterRo

errorRo:
	LEA DX, msgErr
	MOV AH, 09h
	INT 21h
	MOV AX, 0
	MOV rows, AX
	MOV cols, AX
	JMP startRo

startCo:
	LEA DX, msgCo
	MOV AH, 09h
	INT 21h
	enterCo:
	MOV AH, 01h
	INT 21h
	MOV AH, 0
	CMP AX, 13
	JZ endCo
	CMP AX, 48
	JC errorCo
	CMP AX, 57
	JZ J9b
	JNC errorCo
J9b:
	SUB AL, 48
	MOV AH, 0
	MOV BX, AX
	MOV AX, cols
	MUL u
	JC errorCo
	ADD AX, BX
	JC errorCo
	MOV cols, AX
	JMP enterCo

errorCo:
	LEA DX, msgErr
	MOV AH, 09h
	INT 21h
	MOV AX, 0
	MOV cols, AX
	JMP startCo

endCo:
	MOV AX, rows
	MOV BX, cols
	MUL BX
	CMP AX, 0
	JZ errorRo
	CMP AX, 2501
	JC EntOk
	JMP errorRo

EntOk:



lea dx, msgEl
mov ah, 09h
int 21h

LEA SI, array
call inputelements


lea dx, msgEl
mov ah, 09h
int 21h

LEA SI, array2
call inputelements

mov ax, rows
mul cols ;v ax kol elementov
mov cx, ax
;dec cx

mov si, offset array
mov di, offset array2

cycle54:
	
	mov ax, [si]
	cmp ax, [di]
	jnc men

	mov ax, [di]
	push ax
	jmp bol
	
	men:
		push ax
	bol:
		inc si
		inc si
		inc di
		inc di

loop cycle54

mov ax, rows
mul cols ;v ax kol elementov
mov cx, ax
dec cx

lea di, array3
cycle228:
	inc di
	inc di
	loop cycle228;чтобы di указывал на ласт элемент цепочки

mov ax, rows
mul cols ;v ax kol elementov
mov cx, ax

cyclen:
	pop [di]
	dec di 
	dec di
	loop cyclen

LEA DX, msgMa
MOV AH, 09h
INT 21h
LEA SI, array
call OutputMass

LEA DX, msgMa2
MOV AH, 09h
INT 21h
LEA SI, array2
call OutputMass

LEA DX, msgSu
MOV AH, 09h
INT 21h
LEA SI, array3
call OutputMass

lea dx, msgNewLine 
mov ah, 09h
int 21h

MOV AH, 4Ch
INT 21h
end start