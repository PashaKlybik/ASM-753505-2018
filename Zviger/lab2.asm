.model small
.stack 256
.data
ten dw 10
newLine db 10,13,'$'
error db 10, 13,"Input error", 10, 13, '$'
enter2 db "Enter the divisor", 10, 13, '$'
enter1 db "Enter a dividend", 10, 13, '$'
result db "Result", 10, 13, '$'
remainder db "Remainder", 10, 13, '$'
.code
printNewLine proc
	push AX
	push DX
	lea DX, newLine
	mov AH,09h
	int 21h
	pop DX
	pop AX
	ret
printNewLine endp

printError proc
	push AX
	push DX
	lea DX, error
	mov AH,09h
	int 21h
	pop DX
	pop AX
	ret
printError endp

deleteSymbol proc
	push AX
	push BX
	push CX
	push DX

	mov AH, 03h
	int 10h

	dec DL
	mov AH, 02h
	int 10h

	mov AL, 20H
	mov AH, 0AH
	int 10h

	pop DX
	pop CX
	pop BX
	pop AX
	ret
deleteSymbol endp

deleteNum proc
	push AX
	push BX
	push CX
	push DX

	mov AH, 03h
	int 10h

	mov BL, DL
	inc BL

	mov DL, 0
	mov AH, 02h
	int 10h

	mov CL, DL
	mov AL, 20H
	mov AH, 0AH
	int 10h

	pop DX
	pop CX
	pop BX
	pop AX
	ret
deleteNum endp

printAX proc
	push AX
	push BX
	push CX
	push DX

	mov CX, 0
	flag1:				;adding a character to a number on the stack 
		mov DX,0
		div ten
		add DX, '0'
		push DX
		inc CX
		cmp AX, 0
	JNZ flag1

	cycle1:				;character printing
		pop DX
		mov AH, 02h
		int 21h
	LOOP cycle1

	pop DX
	pop CX
	pop BX
	pop AX
	ret
printAX endp

readAX proc
	push CX
	push BX
	push DX
	push SI

	mov DX, 0
	mov CX, 0
	flag2:

		mov AH,08h			;character reading
		int 21h

		cmp AL, 8h
		jnz flag10
		cmp CX, 0
		jz flag2
		pop AX
		sub CX, 1
		call deleteSymbol
		jmp flag2

		flag10:

		cmp AL, 1Bh
		jnz flag11
		cycle4:
		pop AX
		LOOP cycle4
		
		call deleteNum
		jmp flag2

		flag11:
		
		cmp AL, 13			;if the entered character is skipped processing of the entered character
		jz flag3

		cmp AL, '0'			;check for a digit
		jb flag6
		cmp AL, '9'
		ja flag6

		mov DL, AL			;output of the entered character
		mov AH,02h
		int 21h

		mov AH, 0			;adding a digit to the stack
		sub AL, '0'
		push AX

		add CX, 1			;count of the number of digits in the number
	jmp flag2

	flag3:


		mov SI, CX
		mov AX, 0

	cycle2:					;Adding number to the AX
		pop BX				;extract a digit from the stack

		push AX				

		mov AX, SI			
		sub AX, CX	
		mov DX, 0
		call tenInDegreeAX
		
		push DX

		mul BX
		cmp DX, 0

		JZ flag9
		call printError
		jmp start

		flag9:

		pop DX
		cmp AX, AX
		mov BX, AX
		pop AX
		add AX, BX

		JNC flag8
		call printError
		jmp start
		flag8:

	LOOP cycle2

	pop SI
	pop DX
	pop BX
	pop CX

	jmp exit
	flag6:
	call printError
	jmp start
	exit:
	ret
readAX endp

tenInDegreeAX proc
	cmp AX, 0
	JZ flag4
	push CX
	mov CX, AX
	mov AX, 1
	cycle3:
		mul ten
	LOOP cycle3
	cmp DX, 0

	JZ flag12
	call printError
	jmp start

	flag12:
	pop CX
	jmp flag5
	flag4:
	mov AX, 1
	flag5:
	ret
tenInDegreeAX endp
main:
    mov AX, @data
    mov DS, ax

	start:
	lea DX, enter1
	mov AH,09h
	int 21h

	call readAX

	call printNewLine

	mov SI, AX

	call printAX

	push AX
	call printNewLine
	lea DX, enter2
	mov AH,09h
	int 21h
	pop AX

	call readAX

	call printNewLine

	mov DI, AX

	call printAX

	call printNewLine

	lea DX, result
	mov AH,09h
	int 21h

	mov DX, 0
	mov AX, SI
	div DI
	
	call printAX
	
	call printNewLine
	
	push DX
	lea DX, remainder
	mov AH,09h
	int 21h
	pop DX

	mov AX, DX

	call printAX

	call printNewLine

    mov ax, 4c00h
    int 21h
end main