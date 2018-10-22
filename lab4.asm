
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
   jne not_letter
letter:
   inc   bp      ;помечаем, что найдена буква очередного слова 
   stc         ;помечаем, что буква 
   pop cx
   pop ax
   ret 
not_letter:
   clc         ;не буква 
   pop cx
   pop ax
   ret 
isLetter   endp

delete_word proc
	push cx
	push bx
	push ax
	
	xor cx, cx
	mov cx, bp
	DelWord_loop:
		dec si
		mov di, si
		DelLetter_loop:      
			mov   al, [di]    
			mov   [di-1], al 
			inc   di 
			cmp   al, '$' 
		jne   DelLetter_loop
		xor di, di 
	loop DelWord_loop
	
	pop ax
	pop bx
	pop cx
delete_word endp 

delete_words proc
	push ax
	push bx
	
	lea si, string
	xor bp, bp
	xor   bx, bx      
	mov   bl, len       
	mov   [bx+si], byte ptr '$' 
	
	check_isletter:
	
	lodsb
	call isLetter
	jc  check_isletter
	
	cmp bp, n
	jnb check_endstr

	or bp, bp
	je check_endstr

	call delete_word
	
	check_endstr:
	
	xor bp, bp
	cmp al, '$'
	jne check_isletter
	
	pop bx
	pop ax
	
	ret
delete_words endp

 
 
start:
   mov   ax, @data 
   mov   ds, ax 
   mov   es, ax 
 
	call   EnterString 
	call delete_words
     
	 
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
