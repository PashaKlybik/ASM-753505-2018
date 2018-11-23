
.model   small
.stack 100h
.data 
 
	max   db   80      
	len   db   0 
	string   db   80 dup (0) 
	 
	
	sAlphabet db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", 13, 10, '$'
	sEnter      db   "Enter string: $" 
	sResult      db   13, 10, "Result      : $" 
	sAny      db   13, 10, "Press any key", 13, 10, "$" 
	n dw 5
	
.code 
 ASSUME     ds:@data,es:@data
 
EnterString   proc  
	push dx
	push ax
	
	lea   dx, sEnter   
	mov   ah, 9 
	int   21h
 
	lea   dx, max      
	mov   ah, 10
	int   21h
	
	pop ax
	pop dx
	ret 
EnterString   endp 


isLetter   proc      ;проверка на букву 
   push ax
   push cx
   lea di, sAlphabet
   mov cx, 52
   repne scasb
   jne notLetter
letter:
   inc   bp      ;помечаем, что найдена буква очередного слова 
   stc         ;помечаем, что буква 
   pop cx
   pop ax
   ret 
notLetter:
   clc         ;не буква 
   pop cx
   pop ax
   ret 
isLetter   endp

deleteWord proc
	push cx
	push bx
	push ax
	
	xor cx, cx
	mov cx, bp
	DelWordLoop:
		dec si
		mov di, si
		DelLetterLoop:      
			mov   al, [di]    
			mov   [di-1], al 
			inc   di 
			cmp   al, '$' 
		jne   DelLetterLoop
		xor di, di 
	loop DelWordLoop
	
	pop ax
	pop bx
	pop cx
deleteWord endp 

deleteWords proc
	push ax
	push bx
	
	lea si, string
	xor bp, bp
	xor   bx, bx      
	mov   bl, len       
	mov   [bx+si], byte ptr '$' 
	
	checkIsletter:
	
	lodsb
	call isLetter
	jc  checkIsletter
	
	cmp bp, n
	jnb checkEndstr

	or bp, bp
	je checkEndstr

	call deleteWord
	
	checkEndstr:
	
	xor bp, bp
	cmp al, '$'
	jne checkIsletter
	
	pop bx
	pop ax
	
	ret
deleteWords endp

 
 
start:
   mov   ax, @data 
   mov   ds, ax 
   mov   es, ax 
 
	call   EnterString 
	call deleteWords
     
	 
	lea   dx, sResult 
	mov   ah, 9 
	int   21h

	lea   dx, string 
	mov   ah, 9 
	int   21h

	lea   dx, sAny
	mov   ah, 9 
	int   21h

	mov   ah, 0 
	int   16h

	mov   ax, 4c00h
	int   21h

end   start 
