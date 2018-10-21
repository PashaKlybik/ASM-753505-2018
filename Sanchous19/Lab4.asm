;Лабораторная работа №4
.MODEL SMALL
.STACK 100h

.DATA
	string db 256 dup(?)
	len dw ?
	integerNumber db 6 dup(?)
	ten dw 10
	endline db 13, 10, '$'
.CODE

input proc						; Процедура чтения числа из консоли
	push ax			
	push cx
	push dx						; Сохранение значений из регистров в стек
	push di

	lea di,string
	mov byte ptr[di],254				; Управление двумя первыми байтами в строке
	mov byte ptr[di+1],0

	lea dx,string
	mov ah,0Ah					; Чтение строки с клавиатуры
	int 21h
	call printEndline

	xor cx,cx
	mov cl,[di+1]
	mov len,cx					; Определяем длину строки

	pop di
	pop dx						; Возвращение значений из стека
	pop cx
	pop ax
	ret
input endp


solveFunction proc					; Процедура, решающая задачу
	push ax
	push bx
	push cx						; Сохранение значений из регистров в стек
	push dx
	push si
	push di
	
	cld
	inc len
	lea di,string+2
	add di,len
	mov byte ptr[di],' '
	lea di,string+2
	mov dx,0
findWord:
	cmp cx,0
	je finishSolveFunction

	lea cx,string+2
	sub cx,di
	add cx,len
	mov al,' '
	repe scasb
	jcxz finishSolveFunction
	mov bx,di					; Определяем начало слова
	dec bx
	repne scasb
	mov cx,di
	dec cx
	sub cx,bx					; Определяем длину слова
	inc dx
	push di

	lea di,string+2					; Возвращаем указатель на начало строки
	mov si,bx
	xor ax,ax
	call countTheWordInTheLine
	call outputResult			; Выводим сколько раз слово встретилось в частях других слов
	pop di
	jmp findWord

finishSolveFunction:
	pop di
	pop si
	pop dx
	pop cx						; Возвращение значений из стека
	pop bx
	pop ax
	ret
solveFunction endp


countTheWordInTheLine proc
	push dx

	mov dx,len
	inc dx
	sub dx,cx
goOnTheLine:
	push cx
	push si
	push di

	repe cmpsb					; Сравниваем по символу
	jne notEqual
	inc ax						; Если нашли вхождение, то увеличиваем количество вхождений
	
notEqual:
	pop di
	pop si
	pop cx
	inc di
	dec dx
	cmp dx,0
	jne goOnTheLine

	pop dx
	ret
countTheWordInTheLine endp


outputResult proc					; Процедура, выводящая сколько раз слово встретилось в других словах
	push cx
	push dx
	dec ax
	cmp ax,0						; Проверяем количество на 0
	je exit

	push ax
	mov ax,dx
	call printIntegerNumber			; Выводим на консоль номер слова
	mov ah,02h
	mov dl,')'
	int 21h						; Выводим на консоль проверяемое слово
printCharacter:
	mov dl,[si]
	int 21h						; Выводим на консоль проверяемое слово
	inc si
	loop printCharacter

	mov dl,'-'
	int 21h
	pop ax					
	call printIntegerNumber 			; Выводим на консоль количество
	call printEndline

exit:
	pop dx
	pop cx
	ret
outputResult endp


printIntegerNumber proc					; Процедура записи числа из регистра AX в консоль
	push ax
	push cx						; Сохранение значений из регистров в стек
	push dx
	push di
	xor cx,cx

convertToChar:						; Конвертирование цифр в символы и запись в стек
	inc cx
	xor dx,dx
	div ten
	add dx,'0'					
	push dx
	test ax,ax
	jnz convertToChar
	
	lea di,integerNumber
putCharactersInString:				; Занесение символов в строку
	pop dx
	mov [di],dl
	inc di						
	loop putCharactersInString
	mov byte ptr[di],'$'
	
	mov ah,09h
	lea dx,integerNumber
	int 21h							; Отображение строки в консоли

	pop di
	pop dx
	pop cx						; Возвращение значений из стека
	pop ax
	ret
printIntegerNumber endp


printEndline proc					; Переход на новую строку
	push ax
	push dx
	lea dx,endline		
	mov ah,9
	int 21h
	pop dx
	pop ax
	ret
printEndline endp


START:
    mov ax,@data
	mov ds,ax
	mov es,ax

	call input
	call solveFunction

	mov ah,4ch
    int 21h
END START