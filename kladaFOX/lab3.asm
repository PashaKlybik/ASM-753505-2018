.model small
.stack 100h
.data
	a				dw 	?
	b 				dw 	?
	c 				dw 	?
	d 				dw 	?
	negFlag 		dw 	0
	inputString		db 	100, 100 dup ('$')
	endl 			db 	13, 10, '$'
	outputString 	db 	7, 7 dup ('$')
	zeroMessage		db 	"Error: dividing by zero", 13, 10, '$'
	largeMessage 	db 	"Error: Your number is too big", 13, 10, '$'
	letterMessage 	db 	"Error: You've entered some invalid symbols", 13, 10, '$'
	minus 			db 	"-$"
.code



proc inputStr
	
	mov negFlag, 0
	lea dx, inputString				
	mov ah, 10
	int 21h

	lea dx, endl			
	mov ah, 9
	int 21h

	lea si, inputString				
	inc si
	inc si
	
	cmp [si], byte ptr '+'
	je plus
	
	cmp [si], byte ptr '-'		
	jne positive
	
	
	mov negFlag, 1
plus:
	inc si

positive:
	ret

endp inputStr


proc toNum
	xor dx,dx
	xor cx,cx
	mov dx,1

toReg:	
	xor ax, ax
    mov bl, [si]    
    inc si           
    cmp bl, 13	
	je exitStr	
	
	cmp bl,'9'		
	jg notNum
	cmp bl,'0'      
	jb notNum
	
	sub bl,'0'		
	
	mov ax, cx 
	imul dx
	jc overflow
	mov dx, 10
	add ax, bx
	mov cx, ax
	jmp toReg

overflow:
	mov bp, 1

notNum:
	mov bp, 2
	jmp exit

exitStr:	
	mov ax, cx		
	cmp ax, 32769	
	jb notBad	
overflow2:
	mov bp, 1
	jmp exit

notBad:	
	cmp negFlag, 1	
	jne maxpos
	neg ax
	jmp exit
	
maxpos:					
	cmp ax, 32768
	je overflow2

exit:
	ret
endp toNum


proc toStr

	or ax, ax	;проверка на отрицательность	
	jns pos

	neg ax
	mov cx, 1
	
pos:
	push cx	
	push dx
	push bx
	
	mov bx,10	
	xor cx,cx	

digitToStack:
	xor dx,dx  
	div bx		
	push dx		
	inc cx		
	cmp ax, 0	
	jne digitToStack	

stackToStr:
	pop ax		
	add al,'0'	
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

	cmp bp, 1
	jne checkErrorSymbol

	lea dx, largeMessage
	mov ah, 9
	int 21h
	pop ax
	jmp endprog


checkErrorSymbol:
	cmp bp, 2
	jne checkZerodiv
	lea dx, letterMessage
	mov ah, 9
	int 21h
	pop ax
	jmp endprog

checkZerodiv:
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

	xor cx, cx
	lea di, outputString
	call toStr


	cmp cx, 1
	jne positive2

	push ax
	xor ax, ax
	mov ah, 9
	lea dx, minus
	int 21h
	pop ax

positive2:
	xor ax, ax
	lea dx, outputString
	mov ah, 9
	int 21h

	lea dx, endl				
	mov ah, 9
	int 21h

	ret
endp output

proc inputA
	xor ax, ax
	call inputStr
	call toNum
	mov a, ax
	call checkNum
	ret
endp inputA

proc inputB
	xor ax, ax
	call inputStr
	call toNum
	mov b, ax
	cmp b, 0
	jne nozero
	mov bp, 3

nozero:
	call checkNum
	ret
endp inputB

proc division
	xor dx, dx
	mov ax, a
	mov bx, b
	or ax, ax
	jns positive1
	not dx
	positive1:
	idiv bx
	ret
endp division

proc err1
	cmp a, -32768
	jne exitErr1
	cmp b, -1
	jne exitErr1
	mov bp, 5
	lea dx, zeroMessage
	mov ah, 9
	int 21h
exitErr1:
	ret
endp err1

start:
	mov ax, @data
	mov ds, ax
	
	call inputA
	call inputB
	call err1
	cmp bp, 5
	je endprog
	call division
	call output

	endprog:
	mov ax, 4c00h
	int 21h

end start