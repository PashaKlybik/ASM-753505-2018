;Ëàáîðàòîðíàÿ ðàáîòà ¹2
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

output proc						; Ïðîöåäóðà çàïèñè ÷èñëà èç ðåãèñòðà AX â êîíñîëü
	push ax
	push cx						; Ñîõðàíåíèå çíà÷åíèé èç ðåãèñòðîâ â ñòåê
	push dx
	push di
	xor cx,cx

toString:
	inc cx
	xor dx,dx
	div ten
	add dx,'0'					; Ïåðåâîä ÷èñëà â ñòðîêó è çàïèñü â ñòåê
	push dx
	test ax,ax
	jnz toString
	
	lea di,buffer
inBuffer:
	pop dx
	mov [di],dl
	inc di						; Çàíåñåíèå ÷èñëà â áóôåð
	loop inBuffer

	mov byte ptr[di],'$'

	lea dx,buffer
	mov ah,9					; Îòîáðàæåíèå ñòðîêè â êîíñîëè
	int 21h

	pop di
	pop dx
	pop cx						; Âîçâðàùåíèå çíà÷åíèé èç ñòåêà
	pop ax
	ret
output endp


input proc						; Ïðîöåäóðà ÷òåíèÿ ÷èñëà èç êîíñîëè
	push bx
	push cx						; Ñîõðàíåíèå çíà÷åíèé èç ðåãèñòðîâ â ñòåê
	push dx
	push di

	lea di,buffer
	mov byte ptr[di],6				; Óïðàâëåíèå äâóìÿ ïåðâûìè áàéòàìè â áóôåðå
	mov byte ptr[di+1],0

	lea dx,buffer
	mov ah,0Ah					; ×òåíèå ÷èñëà ñ êëàâèàòóðû
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
	ja errorLabel					; Ïðîâåðêè íà êîððåêòíîñòü ââîäà
	sub bl,'0'
	mul ten						; Ïåðåâîä ñòðîêè â ÷èñëî
	jc errorLabel
	add ax,bx
	jc errorLabel
	loop numberFromBuffer
	jmp exit

errorLabel:
	lea dx,error
	mov ah,9
	int 21h						; Îáðàáàòûâàíèå îøèáêè â ïðîãðàììå
	mov ax,0
	mov ah,4ch
    	int 21h
	
exit:
	pop di
	pop dx
	pop cx						; Âîçâðàùåíèå çíà÷åíèé èç ñòåêà
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
	call output					; Ââîä è âûâîä äåëèìîãî
	call printEndline 

	mov bx,ax
	call input
	call output					; Ââîä è âûâîä äåëèòåëÿ
	call printEndline 

	xchg ax,bx
	xor dx,dx
	div bx

	call printQuotient
	call output					; Âûâîä ÷àñòíîãî
	call printEndline

	mov ax,dx
	call printRemainder
	call output					; Âûâîä îñòàòêà
	call printEndline

	mov ah,4ch
    	int 21h
END START
