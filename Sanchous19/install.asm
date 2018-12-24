.MODEL TINY
.DATA
	handlerHasBeenInstalledMessage db 'The handler has been installed', 13, 10, '$'
	handlerAlreadyInstalledMessage db 'The handler already installed', 13, 10, '$'
	handlerHasBeenRemovedMessage db 'The handler has been removed', 13, 10, '$'
	handlerDidNotInstallMessage db 'The handler did not install', 13, 10, '$'
	parametrErrorMessage db 'Parametr error', 13, 10, '$'
.CODE
org 80h
	cmdLen db ?
	cmdLine db ?
org 100h

START:
    	jmp initialize
    	mov ah,4ch
    	int 21h
	
	int21hVector dd ?
	installFlag dw 13579
	inputWord db 30 dup(?)
	vocabulary db 100 dup(?)
	len dw 0
	handle dw 1
	fileName db 'words.txt', 0
	fileErrorMessage db 'Error with file', 13, 10, '$'
	endline db 13, 10, '$'
    
myHandler proc										; Наш обработчик
    	cmp ah, 0Ah
    	je  new0AhFunction
    	jmp dword ptr cs:[int21hVector]

new0AhFunction:										; Новая функция 0Ah
    	push ax
	push bx
	push cx									; Сохранение значений из регистров в стек
	push dx
	push di
	push si
	push ds
	push es
	
	push cs
	pop ds
	push cs
	pop es
	lea di,inputWord
	xor bx,bx
	xor cx,cx
	call readVocabularyFromFile						; Чтения словаря из файла
	lea dx,vocabulary
	mov ah,09h
	int 21h
	call printEndline

inputCharacter:										; Проверка на нажатие клавиши
	mov ah,01h
	int 21h
	cmp al,13
	je theEndOfInput
	cmp al,32
	je pressedSpace
	mov [di],al
	inc di
	inc cx
	jmp inputCharacter

pressedSpace:										; обработка нажатия на клавишу Space
	call findWordInVocabulary
	xor cx,cx
	lea di,inputWord
	jmp inputCharacter

theEndOfInput:
	pop es
	pop ds
    	pop si
	pop di
	pop dx
	pop cx											; Возвращение значений из стека
	pop bx
	pop ax
    	iret
myHandler endp


findWordInVocabulary proc							; Процедура нахождения слова в словаре
	push ax
	push bx
	push cx
	push di
	push si

	mov byte ptr[di],9
	inc cx
	lea di,vocabulary
compareWords:
	push cx
	lea si,inputWord
	repe cmpsb										; Проверяем слова на равенство
	je changeWord
	mov al,10
	mov cx,50
	repne scasb										; Ищем начало нового слова 
	mov ax,di
	lea bx,vocabulary
	sub ax,bx
	pop cx
	cmp ax,len								; Проверяем достигли ли мы конца словаря
	je theEndOfFindWord
	jmp compareWords

changeWord:
	pop cx
	call deleteWordFromConsole						; Удаляем слово из консоли
printWordInConsole:
	mov dl,[di]
	call printSymbol								; Выводим новое слово на консоль
	inc di
	cmp byte ptr[di],13
	jne printWordInConsole

theEndOfWord:
	mov dl,' '
	call printSymbol								; Выводим пробел

theEndOfFindWord:
	pop si
	pop di
	pop cx
	pop bx
	pop ax
	ret
findWordInVocabulary endp


deleteWordFromConsole proc							; Процедура удаления последнего символа в консоли
	push cx
delete:
	call deleteLastSymbol
	loop delete
	pop cx
	ret
deleteWordFromConsole endp


deleteLastSymbol proc								; Процедура удаления последнего символа в консоли
	push dx
	mov dl,8
	call printSymbol
	mov dl,32
	call printSymbol
	mov dl,8
	call printSymbol
	pop dx
	ret
deleteLastSymbol endp


printSymbol proc									; Процедура выводящая символ
	push ax
	mov ah,02h
	int 21h	
	pop ax
	ret
printSymbol endp


readVocabularyFromFile proc						; Процедура чтения словаря из файла
	push ax
	push bx
	push cx
	push dx
	push di

	mov ah,3dH
	lea dx,fileName
	xor al,al
	int 21h										; Открытие файла
	jnc fileIsOpen
	call errorWithFile
fileIsOpen:
	mov [handle],ax
	mov bx,ax
	mov ah,3fH
	lea dx,vocabulary
	mov cx,100
	int 21h										; Чтение файла
	jnc fileIsRead
	call errorWithFile
fileIsRead:
	lea di,vocabulary
	add di,ax
	mov byte ptr[di],13
	inc di
	mov byte ptr[di],10
	inc di
	mov byte ptr[di],'$'
	add ax,2
	mov len,ax

	mov ah,3eH									; Закрытие файла
	mov bx,[handle]
	int 21h
	jnc fileIsClose
	call errorWithFile
fileIsClose:

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret
readVocabularyFromFile endp


errorWithFile proc								; Процедура, обрабатывающая ошибки с файлами
	lea dx,fileErrorMessage
	call printString
	mov ah,4ch
    	int 21h
errorWithFile endp


printString proc								; Процедура выводящая строку
	push ax
	mov ah,09h
	int 21h	
	pop ax
	ret
printString endp


printEndline proc								; Процедура переноса каретки на другую строку
	push dx
	lea dx,endline
	call printString
	pop dx
	ret
printEndline endp


initialize:
	mov ah,35h
	mov al,21h
	int 21h										; Получаем вектор прерывания 21h
	mov word ptr int21hVector,bx
	mov word ptr int21hVector+2,es

	cmp cmdLen,0
	je install
	cmp cmdLen,3
	jne parametrError

	cmp cmdLine[0],' '
	jne parametrError
	cmp cmdLine[1],'-'							; Проверяем параметр 
	jne parametrError
	cmp cmdLine[2],'d'
	jne parametrError
	jmp remove

parametrError:									; Выдать сообщение об ошибке при передаче параметра
	mov ah,09h
	lea dx,parametrErrorMessage
	int 21h
	mov ah,4ch
    	int 21h
	
install:
	cmp es:installFlag,13579						; Проверяем установлен ли обработчик
	je alreadyInstalled
	
	mov ah,09h									; Устанавливаем обработчик
	lea dx,handlerHasBeenInstalledMessage
	int 21h										; Выдать сообщение, что обработчик установлен
	mov ah,25h
	mov al,21h
	mov dx,offset myHandler
	int 21h	
	jmp exit

alreadyInstalled:								; Выдать сообщение, что обработчик уже установлен
	mov ah,09h
	lea dx,handlerAlreadyInstalledMessage
	int 21h
	mov ah,4ch
    	int 21h

remove:
	cmp es:installFlag,13579						; Проверяем установлен ли обработчик
	jne didNotInstall
	
	mov ah,09h
	lea dx,handlerHasBeenRemovedMessage
	int 21h										; Выдать сообщение, что обработчик удален
	mov ah,25h
	mov al,21h
	mov ds,word ptr es:int21hVector+2
	mov dx,word ptr es:int21hVector
	int 21h										; Удаляем обрабочик прерывания
	mov ah,4ch
    	int 21h

didNotInstall:									; Выдать сообщение, что обработчик не был до этого установлен
	mov ah,09h
	lea dx,handlerDidNotInstallMessage
	int 21h
	mov ah,4ch
    	int 21h

exit:
	mov dx,offset initialize
    	int 27h
END START
