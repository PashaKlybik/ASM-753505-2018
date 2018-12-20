.model small
.stack 100h
.data
    a 				dw ?
    b 				dw ?

    inputString 	db 100, 100 dup ('$')
    endl	 		db 13, 10, '$'
    outputString	db 6, 6 dup ('$')
    zeroMessage 	db "Error: dividing by zero", 13, 10, '$'
    largeMessage 	db "Error: Your number is too big", 13, 10, '$'
    letterMessage	db "Error: You've entered some invalid symbols", 13, 10, '$'
.code



proc inputStr

    lea dx, inputString   ;65536 / 12 = 0!!
    mov ah, 10
    int 21h

    lea dx, endl
    mov ah, 9
    int 21h

    lea si, inputString   
    inc si
    inc si

    ret
endp inputStr


proc toNum
    
    xor dx, dx 

toReg:
    xor ax, ax
    mov al, [si]    
    inc si           
    cmp al, 13        
    je exit
    
    cmp al,'9'    
    jg notNum
    cmp al,'0'      
    jb notNum
    
    sub ax, '0'    
    
    shl dx, 1    
    add ax, dx
    jc overflow
    
    shl dx, 2
    add dx, ax    
    jc overflow

    jmp toReg

notNum:
    mov bp, 2
    jmp exit

overflow:
    mov bp, 1

exit:    
    mov ax, dx
   
    ret
endp toNum


proc toStr

    push cx    
    push dx
    push bx

    mov bx, 10    
    xor cx, cx    

digitToStack:    
    xor dx, dx    
    div bx       
    push dx      
    inc cx       
    cmp ax, 0   
    jne digitToStack 
	
stackToStr:    
    pop ax        
    add al, '0'    
    mov [di], al
    inc di        
    loop stackToStr  

    pop bx       
    pop dx
    pop cx
    
    ret
endp toStr


proc checkNum

    push ax
    xor ax, ax
    
    cmp bp, 1                ;переполнение                            
    jne checkOtherSymbols
    
    lea dx, largeMessage
    mov ah, 9
    int 21h
    pop ax
    jmp endprog

checkOtherSymbols:
    cmp bp, 2
    jne checkZeroDiv
    lea dx, letterMessage
    mov ah, 9
    int 21h
    pop ax
    jmp endprog

checkZeroDiv:
    cmp bp, 3
    jne noErrors
    lea dx, zeroMessage
    mov ah, 9
    int 21h
    pop ax
    jmp endprog

noErrors:
    pop ax
    ret
endp checkNum


proc output
    xor ax, ax
    lea dx, outputString
    mov ah, 9
    int 21h

    lea dx, endl       
    mov ah, 9
    int 21h

    ret
endp output


start:
    mov ax, @data
    mov ds, ax

    xor ax, ax
    call inputStr
    call toNum
	
    mov a, ax
    call checkNum

    xor ax, ax
    call inputStr
    call toNum
		
    mov b, ax
    cmp b, 0
    jne nozero
    mov bp, 3

nozero:
    call checkNum

    ;деление
    xor dx, dx
    mov ax, a
    mov bx, b
    div bx

    lea di, outputString
    call toStr

    call output

endprog:
    mov ax, 4c00h
    int 21h

end start
