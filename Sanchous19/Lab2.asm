;������������ ������ �2
.MODEL SMALL
.STACK 100h

.DATA
	ten dw 10
	quotient db 'quotient: ', '$'
	remainder db 'remainder: ', '$'
	error db 'Error', 13, 10, '$'
	buffer db 8 dup(?)
	endline db 13, 10, '$'
.CODE

output proc						; ��������� ������ ����� �� �������� AX � �������
	push ax
	push cx						; ���������� �������� �� ��������� � ����
	push dx
	push di
	xor cx,cx

toString:
	inc cx
	xor dx,dx
	div ten
	add dx,'0'					; ������� ����� � ������ � ������ � ����
	push dx
	test ax,ax
	jnz toString
	
	lea di,buffer
inBuffer:
	pop dx
	mov [di],dl
	inc di						; ��������� ����� � �����
	loop inBuffer

	mov byte ptr[di],'$'

	lea dx,buffer
	mov ah,9					; ����������� ������ � �������
	int 21h

	pop di
	pop dx
	pop cx						; ����������� �������� �� �����
	pop ax
	ret
output endp


input proc						; ��������� ������ ����� �� �������
	push bx
	push cx						; ���������� �������� �� ��������� � ����
	push dx
	push di

	lea di,buffer
	mov byte ptr[di],6			; ���������� ����� ������� ������� � ������
	mov byte ptr[di+1],0

	lea dx,buffer
	mov ah,0Ah					; ������ ����� � ����������
	int 21h

	xor cx,cx
	mov cl,[di+1]
	add di,2
	xor ax,ax
	xor bx,bx

numberFromBuffer:
	mov bl,byte ptr[di]
	inc di
	cmp bl,'0'
	jb errorLabel
	cmp bl,'9'
	ja errorLabel				; �������� �� ������������ �����
	sub bl,'0'
	mul ten						; ������� ������ � �����
	jc errorLabel
	add ax,bx
	jc errorLabel
	loop numberFromBuffer
	jmp exit

errorLabel:
	lea dx,error
	mov ah,9
	int 21h						; ������������� ������ � ���������
	mov ax,0
	mov ah,4ch
    int 21h
	
exit:
	pop di
	pop dx
	pop cx						; ����������� �������� �� �����
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

	call input
	call output					; ���� � ����� ��������
	call printEndline 

	mov bx,ax
	call input
	call output					; ���� � ����� ��������
	call printEndline 

	xchg ax,bx
	xor dx,dx
	div bx

	call printQuotient
	call output					; ����� ��������
	call printEndline

	mov ax,dx
	call printRemainder
	call output					; ����� �������
	call printEndline


	mov ah,4ch
    int 21h
END START