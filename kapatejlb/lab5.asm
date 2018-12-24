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

InputUsInt proc	;ввод в АX 
	
	mov temporary, 0
	entersymbus:
		MOV AH, 01h
		INT 21h
		xor ah, ah
		CMP AX, 13 ;проверка на энтр
		JZ end1us
		CMP AX, 48 ;проверка на 0-9
		JC errorus
		CMP AX, 57
		JZ continus
		JNC errorus

	continus:
		SUB AL, 48
		MOV AH, 0
		MOV BX, AX
		MOV AX, temporary
		MUL u
		JC errorus
		ADD AX, BX
		JC errorus
		MOV temporary, AX
		JMP entersymbus

	errorus:
		LEA DX, repeat
		MOV AH, 09h
		INT 21h
		MOV AX, 0
		MOV temporary, AX
		JMP entersymbus

	end1us:

	ret
InputUsInt endp

proc InputElements
	mov ax, rows
	mul cols ;v ax kol elementov
	mov cx, ax
	qwe:
		call inputint

		push temporary
		pop ax

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

	lea dx, msgCo
	mov ah, 09h
	int 21h
	call inputusint
	push temporary
	pop cols

	lea dx, msgRo
	mov ah, 09h
	int 21h
	call inputusint
	push temporary
	pop rows

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

	mov si, offset array
	mov di, offset array2

	cycle54:
		mov ax, [si]
		cmp ax, 32767
		jc p1
		jmp n1

		n1:
			mov ax, [di]
			cmp ax, 32767
			jc n1p2
			jmp n1n2
	
		n1p2:
			jmp add2

		n1n2:
			mov ax, [si]
			cmp ax, [di]
			jc add2
			jmp add1


		p1:
			mov ax, [di]
			cmp ax, 32767
			jc p1p2
			jmp p1n2
		
		p1p2:
			mov ax, [si]
			cmp ax, [di]
			jc add2
			jmp add1

		p1n2:
			jmp add1
		
		add1:
			push [si]
			jmp asd

		add2:
			push [di]
			jmp asd
		
		asd:	
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
