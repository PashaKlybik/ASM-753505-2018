.model small
.stack 256
.data
    buffer db 7 dup(?)
    endline db 13,10,'$'
	exceptionMessaage db 'Error! Exiting program...', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax
    
    call enterString
    call printNumber
    call enterString
    call printNumber
    call divideNumbers
    call printNumber
    
	call exitProgram

divideNumbers proc
    xor dx, dx
    pop cx
    pop bx
    pop ax
	cmp bx,0
	stc
	je divN
	test ax, ax
    div bx
	
  divN:
    push ax
    push cx
    ret
divideNumbers endp
    
enterString proc
    mov ah, 01h
    int 21h
	cmp al, '0'
	jl exception
	cmp al, '9'
	jg exception
    sub al, 30h
    xor ah, ah
    mov bx, 10
    mov cx, ax
	
  loopEnter:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je stop
	cmp al, '0'
	jl exception
	cmp al, '9'
	jg exception
    sub al, 30h
    xor ah, ah
    xchg ax, cx
    mul bx
	jc exception
    add cx, ax
	jz exception
	jc exception
    jmp loopEnter
	
  stop:
    pop ax
    push cx
    push ax
	jmp ex
	
  exception:
	stc
	call printEndline
	mov ah, 9	
    mov dx, offset exceptionMessaage
    int 21h
	call exitProgram
	
  ex:
    ret
enterString endp

printNumber proc
	jc expn
    pop bx
    pop ax
    push ax
    push bx
    push di
    lea di,buffer	    
    push di		    
    call convertNumber
    mov byte[di], '$'	
    pop di		    
    call printString	
    pop di
    call printEndline
    mov [buffer], 0h
    mov [buffer+1], 0h
    mov [buffer+2], 0h
    mov [buffer+3], 0h
    mov [buffer+4], 0h
    mov [buffer+5], 0h
    mov [buffer+6], 0h
	
  expn:
	test ax,ax
    ret
printNumber endp

printEndline proc
    push di
    lea di, endline
    call printString
    pop di
    ret
printEndline endp

printString proc
    push ax
    mov ah, 09h
    xchg dx, di
    int 21h
    xchg dx, di
    pop ax
    ret
printString endp

convertNumber proc
    lea di, buffer
    xor cx, cx
    mov bx, 10
	
  lp1:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz lp1
	
  lp2:
    pop dx
    mov [di], dl
    inc di
    loop lp2
    
    ret   
    
convertNumber endp

exitProgram proc
    mov ax, 4c00h
    int 21h
exitProgram endp

end main

