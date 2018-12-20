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
 
	lea   dx, max      
	mov   ah, 10
	int   21h

	ret 
EnterString   endp 


isSpace   proc      

	xor bp, bp

beg1:   
	cmp [si], byte ptr ' '	
	je space			
	inc bp       			
	dec si	    			
	dec bx				
	cmp bx, 0			
	je space
	jmp beg1

space:
	inc si		
	dec bp		
	ret 
isSpace   endp


reverse_words proc

	xor   bx, bx      
	mov   bl, len	       
	mov   [bx+di], byte ptr '$'
	add si, bx
	dec si	
	dec bx
beg2:
	call isSpace
	mov cx, bp
	inc cx			
	rep movsb		
	cmp bx, 0		
	je fin
	mov [di], byte ptr ' '	
	inc di
	lea si, string		
	add si, bx				
	dec si								
	dec bx			
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
