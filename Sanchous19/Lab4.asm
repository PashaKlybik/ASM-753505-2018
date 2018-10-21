;������������ ������ �4
.MODEL SMALL
.STACK 100h

.DATA
	string db 256 dup(?)
	len dw ?
	integerNumber db 6 dup(?)
	ten dw 10
	endline db 13, 10, '$'
.CODE

input proc						; ��������� ������ ����� �� �������
	push ax			
	push cx
	push dx						; ���������� �������� �� ��������� � ����
	push di

	lea di,string
	mov byte ptr[di],254				; ���������� ����� ������� ������� � ������
	mov byte ptr[di+1],0

	lea dx,string
	mov ah,0Ah					; ������ ������ � ����������
	int 21h
	call printEndline

	xor cx,cx
	mov cl,[di+1]
	mov len,cx					; ���������� ����� ������

	pop di
	pop dx						; ����������� �������� �� �����
	pop cx
	pop ax
	ret
input endp


solveFunction proc					; ���������, �������� ������
	push ax
	push bx
	push cx						; ���������� �������� �� ��������� � ����
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
	mov bx,di					; ���������� ������ �����
	dec bx
	repne scasb
	mov cx,di
	dec cx
	sub cx,bx					; ���������� ����� �����
	inc dx
	push di

	lea di,string+2					; ���������� ��������� �� ������ ������
	mov si,bx
	xor ax,ax
	call countTheWordInTheLine
	call outputResult			; ������� ������� ��� ����� ����������� � ������ ������ ����
	pop di
	jmp findWord

finishSolveFunction:
	pop di
	pop si
	pop dx
	pop cx						; ����������� �������� �� �����
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

	repe cmpsb					; ���������� �� �������
	jne notEqual
	inc ax						; ���� ����� ���������, �� ����������� ���������� ���������
	
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


outputResult proc					; ���������, ��������� ������� ��� ����� ����������� � ������ ������
	push cx
	push dx
	dec ax
	cmp ax,0						; ��������� ���������� �� 0
	je exit

	push ax
	mov ax,dx
	call printIntegerNumber			; ������� �� ������� ����� �����
	mov ah,02h
	mov dl,')'
	int 21h						; ������� �� ������� ����������� �����
printCharacter:
	mov dl,[si]
	int 21h						; ������� �� ������� ����������� �����
	inc si
	loop printCharacter

	mov dl,'-'
	int 21h
	pop ax					
	call printIntegerNumber 			; ������� �� ������� ����������
	call printEndline

exit:
	pop dx
	pop cx
	ret
outputResult endp


printIntegerNumber proc					; ��������� ������ ����� �� �������� AX � �������
	push ax
	push cx						; ���������� �������� �� ��������� � ����
	push dx
	push di
	xor cx,cx

convertToChar:						; ��������������� ���� � ������� � ������ � ����
	inc cx
	xor dx,dx
	div ten
	add dx,'0'					
	push dx
	test ax,ax
	jnz convertToChar
	
	lea di,integerNumber
putCharactersInString:				; ��������� �������� � ������
	pop dx
	mov [di],dl
	inc di						
	loop putCharactersInString
	mov byte ptr[di],'$'
	
	mov ah,09h
	lea dx,integerNumber
	int 21h							; ����������� ������ � �������

	pop di
	pop dx
	pop cx						; ����������� �������� �� �����
	pop ax
	ret
printIntegerNumber endp


printEndline proc					; ������� �� ����� ������
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