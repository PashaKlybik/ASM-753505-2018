.model   small
.stack 100h
.data 
 
	max   			db   100      
	len   			db   0 
	string   		db   100 dup (0) 
	 
	sEnter      	db   "Enter string: $" 
	sResult      	db   13, 10, "Result      : $" 
	sAny      		db   13, 10, "Press any key", 13, 10, "$" 
	final_string 	db 100 dup (0)

.code  

EnterString   proc  
	
	lea   dx, sEnter   
	mov   ah, 9 
	int   21h
 
	lea   dx, max      ;ввод строки
	mov   ah, 10
	int   21h

	ret 
EnterString   endp 


isSpace   proc      ;проход слова до пробела 

	xor bp, bp

beg1:   
	cmp [si], byte ptr ' '	;проверяем пробел ли это 
	je space			
	inc bp       			;помечаем, что найдена буква очередного слова 
	dec si	    			;переходим на следующую букву(читаем с конца)
	dec bx					;bx - длина строки, которая еще не прочитана
	cmp bx, 0				;проверка на конец строки
	je space
	jmp beg1

space:
	inc si					; устанавливаем указатель на первую букву копируемого слова
	dec bp					; уменьшаем слово на 1 (пробел)
	ret 
isSpace   endp


reverse_words proc

	xor   bx, bx      
	mov   bl, len					;помещаем в bx длину строки исходной       
	mov   [bx+di], byte ptr '$'		; устанавливаем длину выходящей строки такую как и входящая
	add si, bx
	dec si		;перемещаем si в конец строки
	dec bx
beg2:
	call isSpace
	mov cx, bp		; cx - длина копируемого слова(без последней буквы)
	inc cx			; полная длина слова
	rep movsb		; копируем слово из si в di
	cmp bx, 0		; проверяем на конец строки
	je fin
	mov [di], byte ptr ' '	; ставим пробел после слова
	inc di
	lea si, string			; перемещаемся в начало строки
	add si, bx				
	dec si					; перемещаемся на текущую позицию					
	dec bx					; уменьшаем строку на 1(пробел)
	dec si					
	jmp beg2

fin:	
	ret

reverse_words endp

 
 
start:
	mov   ax, @data 
	mov   ds, ax 
	mov   es, ax

	call   EnterString 
	lea si, string
	lea di, final_string
	call reverse_words
     	 
	lea   dx, sResult 
	mov   ah, 9 
	int   21h

	lea   dx, final_string 
	mov   ah, 9 
	int   21h

	lea   dx, sAny
	mov   ah, 9 
	int   21h

	mov   ah, 0 
	int   16h

	mov   ax, 4c00h
	int   21h

end start 
