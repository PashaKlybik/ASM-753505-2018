;Лабораторная работа №3
.MODEL SMALL
.STACK 100h

.DATA
	ten dw 10
	quotient db 'quotient: ', '$'
	remainder db 'remainder: ', '$'
	error db 'Error', 13, 10, '$'
	buffer db 9 dup(?)
	endline db 13, 10, '$'
.CODE

output proc						; Процедура записи числа из регистра AX в консоль
	push ax
	push cx						; Сохранение значений из регистров в стек
	push dx
	push di
	xor cx,cx

	cmp ax,32767
	jbe positiveNumberToString	; Проверка на отрицательность
	push ax
	mov dl,'-'					; Выводим в консоль минус, если число отрицательное
	mov ah,02h
	int 21h
	pop ax
	neg ax

positiveNumberToString:
	inc cx
	xor dx,dx
	div ten
	add dx,'0'					; Перевод числа в строку и запись в стек
	push dx
	test ax,ax
	jnz positiveNumberToString
	
	lea di,buffer
inBuffer:
	pop dx
	mov [di],dl
	inc di						; Занесение числа в буфер
	loop inBuffer

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
	push dx
	push di

	lea di,buffer
	mov byte ptr[di],7	 		; Управление двумя первыми байтами в буфере
	mov byte ptr[di+1],0

	lea dx,buffer
	mov ah,0Ah					; Чтение числа с клавиатуры
	int 21h

	xor cx,cx
	mov cl,[di+1]
	add di,2
	xor ax,ax
	xor bx,bx

	cmp byte ptr[di], '-'
	jne positiveNumber			; Проверка на отрицательность
	inc di
	dec cl

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

	lea di,buffer+2
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

errorLabel:
	lea dx,error
	mov ah,9
	int 21h						; Обрабатывание ошибки в программе
	mov ax,0
	mov ah,4ch
    int 21h
	
exit:
	pop di
	pop dx
	pop cx						; Возвращение значений из стека
	pop bx
	ret
input endp


printQuotient proc
	push ax
	push dx
	lea dx,quotient
	mov ah,9
	int 21h	
	pop dx
	pop ax
	ret
printQuotient endp


printRemainder proc
	push ax
	push dx
	lea dx,remainder
	mov ah,9
	int 21h	
	pop dx
	pop ax
	ret
printRemainder endp


printEndline proc
	push ax
	push dx
	mov dx,offset endline		
	mov ah,9
	int 21h
	pop dx
	pop ax
	ret
printEndline endp


START:
    mov ax,@data
	mov ds,ax

	call input
	call output					; Ввод и вывод делимого
	call printEndline 

	mov bx,ax
	call input
	call output					; Ввод и вывод делителя
	call printEndline 

	xchg ax,bx
	cwd
	idiv bx

	cmp dx,0
	jge remainderIsPositive
	dec ax
	add dx,bx

remainderIsPositive:
	call printQuotient
	call output					; Вывод частного
	call printEndline

	mov ax,dx
	call printRemainder
	call output					; Вывод остатка
	call printEndline


	mov ah,4ch
    int 21h
END START