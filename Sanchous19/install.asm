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
    
myHandler proc										; ��� ����������
    cmp ah, 0Ah
    je  new0AhFunction
    jmp dword ptr cs:[int21hVector]

new0AhFunction:										; ����� ������� 0Ah
    push ax
	push bx
	push cx											; ���������� �������� �� ��������� � ����
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
	call readVocabularyFromFile						; ������ ������� �� �����
	lea dx,vocabulary
	mov ah,09h
	int 21h
	call printEndline

inputCharacter:										; �������� �� ������� �������
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

pressedSpace:										; ��������� ������� �� ������� Space
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
	pop cx											; ����������� �������� �� �����
	pop bx
	pop ax
    iret
myHandler endp


findWordInVocabulary proc							; ��������� ���������� ����� � �������
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
	repe cmpsb										; ��������� ����� �� ���������
	je changeWord
	mov al,10
	mov cx,50
	repne scasb										; ���� ������ ������ ����� 
	mov ax,di
	lea bx,vocabulary
	sub ax,bx
	pop cx
	cmp ax,len										; ��������� �������� �� �� ����� �������
	je theEndOfFindWord
	jmp compareWords

changeWord:
	pop cx
	call deleteWordFromConsole						; ������� ����� �� �������
printWordInConsole:
	mov dl,[di]
	call printSymbol								; ������� ����� ����� �� �������
	inc di
	cmp byte ptr[di],13
	jne printWordInConsole

theEndOfWord:
	mov dl,' '
	call printSymbol								; ������� ������

theEndOfFindWord:
	pop si
	pop di
	pop cx
	pop bx
	pop ax
	ret
findWordInVocabulary endp


deleteWordFromConsole proc							; ��������� �������� ���������� ������� � �������
	push cx
delete:
	call deleteLastSymbol
	loop delete
	pop cx
	ret
deleteWordFromConsole endp


deleteLastSymbol proc								; ��������� �������� ���������� ������� � �������
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


printSymbol proc									; ��������� ��������� ������
	push ax
	mov ah,02h
	int 21h	
	pop ax
	ret
printSymbol endp


readVocabularyFromFile proc						; ��������� ������ ������� �� �����
	push ax
	push bx
	push cx
	push dx
	push di

	mov ah,3dH
	lea dx,fileName
	xor al,al
	int 21h										; �������� �����
	jnc fileIsOpen
	call errorWithFile
fileIsOpen:
	mov [handle],ax
	mov bx,ax
	mov ah,3fH
	lea dx,vocabulary
	mov cx,100
	int 21h										; ������ �����
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

	mov ah,3eH									; �������� �����
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


errorWithFile proc								; ���������, �������������� ������ � �������
	lea dx,fileErrorMessage
	call printString
	mov ah,4ch
    int 21h
errorWithFile endp


printString proc								; ��������� ��������� ������
	push ax
	mov ah,09h
	int 21h	
	pop ax
	ret
printString endp


printEndline proc								; ��������� �������� ������� �� ������ ������
	push dx
	lea dx,endline
	call printString
	pop dx
	ret
printEndline endp


initialize:
	mov ah,35h
	mov al,21h
	int 21h										; �������� ������ ���������� 21h
	mov word ptr int21hVector,bx
	mov word ptr int21hVector+2,es

	cmp cmdLen,0
	je install
	cmp cmdLen,3
	jne parametrError

	cmp cmdLine[0],' '
	jne parametrError
	cmp cmdLine[1],'-'							; ��������� �������� 
	jne parametrError
	cmp cmdLine[2],'d'
	jne parametrError
	jmp remove

parametrError:									; ������ ��������� �� ������ ��� �������� ���������
	mov ah,09h
	lea dx,parametrErrorMessage
	int 21h
	mov ah,4ch
    int 21h
	
install:
	cmp es:installFlag,13579					; ��������� ���������� �� ����������
	je alreadyInstalled
	
	mov ah,09h									; ������������� ����������
	lea dx,handlerHasBeenInstalledMessage
	int 21h										; ������ ���������, ��� ���������� ����������
	mov ah,25h
	mov al,21h
	mov dx,offset myHandler
	int 21h	
	jmp exit

alreadyInstalled:								; ������ ���������, ��� ���������� ��� ����������
	mov ah,09h
	lea dx,handlerAlreadyInstalledMessage
	int 21h
	mov ah,4ch
    int 21h

remove:
	cmp es:installFlag,13579					; ��������� ���������� �� ����������
	jne didNotInstall
	
	mov ah,09h
	lea dx,handlerHasBeenRemovedMessage
	int 21h										; ������ ���������, ��� ���������� ������
	mov ah,25h
	mov al,21h
	mov ds,word ptr es:int21hVector+2
	mov dx,word ptr es:int21hVector
	int 21h										; ������� ��������� ����������
	mov ah,4ch
    int 21h

didNotInstall:									; ������ ���������, ��� ���������� �� ��� �� ����� ����������
	mov ah,09h
	lea dx,handlerDidNotInstallMessage
	int 21h
	mov ah,4ch
    int 21h

exit:
	mov dx,offset initialize
    int 27h
END START