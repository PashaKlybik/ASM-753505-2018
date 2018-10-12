;Лабораторная работа №3
.MODEL SMALL
.STACK 100h

.DATA
	ten dw 10
	dividend db 'dividend: ', '$'
	divisor db 'divisor: ', '$'
	quotient db 'quotient: ', '$'
	remainder db 'remainder: ', '$'
	error db 'Input error, please enter the number again', 13, 10, '$'
	dividedByZero db 'Error, divided by zero'
	buffer db 20 dup(?)
	endline db 13, 10, '$'
.CODE

output proc						; Процедура записи числа из регистра AX в консоль
	push ax
	push cx						; Сохранение значений из регистров в стек
	push dx
	push di
	xor cx,cx

	cmp ax,32767
	jbe convertPositiveNumberToString	; Проверка на отрицательность
	push ax
	mov dl,'-'					; Выводим в консоль минус, если число отрицательное
	mov ah,02h
	int 21h
	pop ax
	neg ax

convertPositiveNumberToString:
	inc cx
	xor dx,dx
	div ten
	add dx,'0'					; Перевод числа в строку и запись в стек
	push dx
	test ax,ax
	jnz convertPositiveNumberToString
	
	lea di,buffer
putInBuffer:
	pop dx
	mov [di],dl
	inc di						; Занесение числа в буфер
	loop putInBuffer

	mov byte ptr[di],'$'
	lea dx,buffer
	mov ah,9					; Отображение строки в консоли
	int 21h

	pop di
	pop dx
	pop cx						; Возвращение значений из стека
	pop ax
	ret
output endp


input proc						; Процедура чтения числа из консоли
	push bx
	push cx						; Сохранение значений из регистров в стек
	push di

startToInput:
	lea di,buffer
	xor cx,cx

inputAgain:
	mov ah,01h					; Чтение цифр с клавиатуры
	int 21h
	inc cx
	cmp al,27
	je pressedEscape
	cmp al,8
	je pressedBackspace
	cmp al,13
	je convertInIntegerNumber
	mov [di],al
	inc di
	jmp inputAgain

convertInIntegerNumber:
	lea di,buffer
	dec cx
	xor ax,ax
	xor bx,bx
	cmp byte ptr[di],'-'
	jne positiveNumber			; Проверка на отрицательность
	inc di
	dec cx

positiveNumber:
	mov bl,byte ptr[di]
	inc di
	cmp bl,'0'
	jb errorLabel
	cmp bl,'9'
	ja errorLabel				; Проверки на корректность ввода
	sub bl,'0'
	mul ten						; Перевод строки в число
	jc errorLabel
	add ax,bx
	jc errorLabel
	loop positiveNumber

	lea di,buffer
	cmp byte ptr[di],'-'
	jne cmpmax					; Проверка на отрицательность
	cmp ax,32768
	ja errorLabel
	neg ax
	jmp exit
cmpmax:
	cmp ax,32767
	ja errorLabel
	jmp exit
	
pressedEscape:
	call deleteLastSymbol
	loop pressedEscape
	jmp startToInput

pressedBackspace:
	mov ah,02h
	mov dl,' '
	int 21h
	dec cx
	cmp cx,0
	je inputAgain
	call deleteLastSymbol
	dec di
	dec cx
	jmp inputAgain

errorLabel:
	lea dx,error
	mov ah,9
	int 21h						; Обрабатывание ошибки в программе
	jmp startToInput
	
exit:
	pop di
	pop cx						; Возвращение значений из стека
	pop bx
	ret
input endp


deleteLastSymbol proc					; Процедура удаления последнего символа в консоли
	push ax
	push dx

	mov ah,02h
	mov dl,8
	int 21h
	mov dl,32
	int 21h
	mov dl,8
	int 21h

	pop dx
	pop ax
	ret
deleteLastSymbol endp


printDividend proc					; Процедура выводящая на консоли слово "dividend"
	push ax
	push dx
	lea dx,dividend
	mov ah,9
	int 21h	
	pop dx
	pop ax
	ret
printDividend endp


printDivisor proc					; Процедура выводящая на консоли слово "divisor"
	push ax
	push dx
	lea dx,divisor
	mov ah,9
	int 21h	
	pop dx
	pop ax
	ret
printDivisor endp


printQuotient proc					; Процедура выводящая на консоли слово "quotient"
	push ax
	push dx
	lea dx,quotient
	mov ah,9
	int 21h	
	pop dx
	pop ax
	ret
printQuotient endp


printRemainder proc					; Процедура выводящая на консоли слово "remainder"
	push ax
	push dx
	lea dx,remainder
	mov ah,9
	int 21h	
	pop dx
	pop ax
	ret
printRemainder endp


printEndline proc					; Процедура переноса каретки на другую строку
	push ax
	push dx
	lea dx,endline		
	mov ah,9
	int 21h
	pop dx
	pop ax
	ret
printEndline endp


printDividedByZero proc					; Процедура переноса каретки на другую строку
	push ax
	push dx
	lea dx,dividedByZero		
	mov ah,9
	int 21h
	call printEndline
	pop dx
	pop ax
	ret
printDividedByZero endp


START:
    	mov ax,@data
	mov ds,ax

	call input			
	call printDividend
	call output					; Ввод и вывод делимого
	call printEndline 

	mov bx,ax
	call input				
	call printDivisor
	call output					; Ввод и вывод делителя
	call printEndline 

	cmp ax,0
	jne divisorIsNotZero
	call printDividedByZero
	jmp theEnd

divisorIsNotZero:
	xchg ax,bx
	cwd
	idiv bx

	cmp dx,0
	jge remainderIsPositive
	cmp ax,0
	jge quotientIsPositive
	dec ax
	add dx,bx
	jmp remainderIsPositive
quotientIsPositive:
	inc ax
	neg bx
	add dx,bx


remainderIsPositive:
	call printQuotient
	call output					; Вывод частного
	call printEndline

	mov ax,dx
	call printRemainder
	call output					; Вывод остатка
	call printEndline

theEnd:
	mov ah,4ch
    	int 21h
END START
