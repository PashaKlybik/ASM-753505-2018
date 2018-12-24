.model   small
.stack 100h
.data 
 
	maximum   			db   100      
	len   				db   0 
	inputString   		db   100 dup (0) 
	 
	enterMessage      	db   "Enter inputString: $" 
	resultMessage      	db   13, 10, "Result      : $" 
	anyKeyMessage      	db   13, 10, "Press any key", 13, 10, "$" 
	outputString 		db 	 100 dup (0)

.code  

enterInputString   proc  
	
	lea   dx, enterMessage   
	mov   ah, 9 
	int   21h
 
	lea   dx, maximum      
	mov   ah, 10
	int   21h

	ret 
enterInputString   endp 


isSpace   proc     

	xor bp, bp

begin1:   
	cmp [si], byte ptr ' '	
	je space			
	inc bp       			
	dec si	    			
	dec bx					
	cmp bx, 0				
	je space
	jmp begin1

space:
	inc si					
	dec bp					
	ret
isSpace endp


reverse proc

	xor bx, bx      
	mov bl, len				       
	mov [di + bx], byte ptr '$'		
	add si, bx  
	dec si							
	dec bx
begin2:
	call isSpace
	mov cx, bp		
	inc cx			
	rep movsb		
	cmp bx, 0		
	je final
	mov [di], byte ptr ' '	
	inc di
	lea si, inputString		
	add si, bx				
	dec si										
	dec bx					
	dec si					
	jmp begin2

final:	
	ret

reverse endp

 
 
start:
	mov   ax, @data 
	mov   ds, ax 
	mov   es, ax

	call enterInputString 
	lea si, inputString
	lea di, outputString
	call reverse
	
	lea   dx, resultMessage 
	mov   ah, 9 
	int   21h

	lea   dx, outputString 
	mov   ah, 9 
	int   21h

	lea   dx, anyKeyMessage
	mov   ah, 9 
	int   21h

	mov   ah, 0 
	int   16h

	mov   ax, 4c00h
	int   21h

end start 
