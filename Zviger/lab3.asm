Лабораторная работа 3                  
Задание:
1) написать процедуру для вывода знакового числа размерностью слово из регистра AX на экран
   на входе число в регистре AX
   на выходе это число на экране
   все задействованные регистры должны быть сохранены в процедуре
2) написать процедуру для ввода знакового числа с клавиатуры в регистр AX
   на входе пользовательский ввод, минус может быть только как первый символ
   на выходе введенное число в регистре AX
   все задействованные регистры должны быть сохранены в процедуре (кроме AX)
   также должна быть проверка вводимого числа на правильность:
      нельзя вводить не цифры, минус может быть только первым символом,
      проверка на допустимые значения [-32768;32767]
   дополнительно можно реализовать обработку клавиши бэкспэйс (удалить один
      последний введенный символ) и клавиши ескэйп (удалить все число).
3) в функции main действия, аналогичные предыдущей лабораторной работе, но для знаковых чисел.

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

	mov CX, 1
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
	push SI
	mov SI, 0
	mov CX, 0
	test AX,AX
	jns flag13
	neg AX
	mov SI, 1
	flag13:
	flag1:				;adding a character to a number on the stack 
		mov DX,0
		div ten
		add DX, '0'
		push DX
		inc CX
		cmp AX, 0
	JNZ flag1
	
	cmp SI,1
	jnz flag19
	inc CX
	push 2Dh
	flag19:

	cycle1:				;character printing
		pop DX
		mov AH, 02h
		int 21h
	LOOP cycle1

	pop SI
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

	mov SI, 0
	mov DX, 0
	mov CX, 0
	readSymbol:

		mov AH,08h			;character reading
		int 21h

		cmp AL, 8h			;check for a backspace
		jnz flag10

		cmp CX, 0			;check for a digit
		jz readSymbol
		cmp CX, 1			;delete sign
		jnz flag21
		mov SI, 0
		flag21:
		pop AX
		dec CX
		call deleteSymbol
		jmp readSymbol

		flag10:

		cmp AL, 1Bh			;check for a ESC
		jnz flag11

		cycle4:
		pop AX
		LOOP cycle4
		call deleteNum
		jmp readSymbol

		flag11:
		
		cmp AL, 13			;if the entered character is skipped processing of the entered character
		jz 	characterOnStack

		cmp AL, 2Dh
		jnz flag14

		cmp SI, 1
		jnz flag17

		call printError
		jmp start

		flag17:
		mov SI, 1
		push 2Dh
		inc CX

		mov DL, AL			;printing sign
		mov AH,02h
		int 21h

		jmp readSymbol

		flag14:

		mov SI, 1
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

		inc CX			;count of the number of digits in the number
	jmp readSymbol

	characterOnStack:

		mov SI, CX
		mov AX, 0

	cycle2:					;Adding number to the AX
		pop BX				;extract a digit from the stack

		cmp BX, 2Dh
		jnz flag16

		neg AX
		jmp exit

		flag16:

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

		test AX, AX
		jns flag15
		call printError
		jmp start
		flag15:

	LOOP cycle2
	exit:
	pop SI
	pop DX
	pop BX
	pop CX
	ret
	flag6:
	call printError
	jmp start
	ret
readAX endp

tenInDegreeAX proc
	push CX

	cmp AX, 0
	JNZ flag4

	mov AX, 1
	pop CX
	ret

	flag4:

	mov CX, AX
	mov AX, 1

	cycle3:
		mul ten
	LOOP cycle3

	pop CX
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

	call printNewLine

	lea DX, enter2
	mov AH,09h
	int 21h

	call readAX

	call printNewLine

	cmp AX, 0

	jnz flag23
	call printError
	jmp start

	flag23:

	mov DI, AX
	call printAX

	call printNewLine

	lea DX, result
	mov AH,09h
	int 21h

	mov DX, 0
	mov AX, SI

	CWD
	idiv DI
	
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