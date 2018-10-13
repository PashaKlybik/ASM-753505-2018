.model small
.stack 256
.data
    buffer db 256 dup(?)
    endline db 13,10,'$'
	;exceptionMessaage db 'Error!', 13, 10, '$'
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
    
    mov ax, 4c00h
    int 21h

divideNumbers proc
    xor dx, dx
    pop cx
    pop bx
    pop ax
    push cx
    xor cx, cx
	cmp bx,0
	je dnexception
    mov cx, 0
    cmp bx, 32767
    jo bxNeg
	
  compareBound:
    cmp ax, 32767
    jo axNeg
	
  checkNegative:
    test cx, 1
    jnz odd ;Если результат отрицательный (1 минус, нечетное)
	
  division:
    div bx
    pop cx
    push ax
    push cx
    ret
  odd:
    push ax
    push dx
    mov dl, 45
    mov ah, 02h
    int 21h
    pop dx
    pop ax
    jmp division
  bxNeg:
    inc cx
    neg bx
    jmp compareBound
  axNeg:
    inc cx
    neg ax
    jmp checkNegative
  dnexception:
    call exitProg
divideNumbers endp
    
enterString proc ; Выход: cx - строка
    mov ah, 01h
    int 21h  
    cmp al, '-'
    je ifNegative
	cmp al, '0'
	jl exception
	cmp al, '9'
	jg exception
    sub al, 30h
    xor ah, ah
    mov bx, 10
    mov cx, ax
    
  ifPositive:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je stop
    
  notEquals:
	cmp al, '0'
	jl exception
	cmp al, '9'
	jg exception
    sub al, 30h
    xor ah, ah
    xchg ax, cx
    mul bx
	cmp ax, 32767
    ja exception
    add cx, ax
	cmp cx, 32767
    ja exception
    jmp ifPositive
    
  ifNegative:
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
    
  lp:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    jne ifNegAndNotEquals
    neg cx
    jmp stop
    
  ifNegAndNotEquals:
	cmp al, '0'
	jl exception
	cmp al, '9'
	jg exception
    sub al, 30h
    xor ah, ah
    xchg ax, cx
    mul bx
	cmp ax, 32768
    ja exception
    add cx, ax
	cmp cx, 32768
    ja exception
    jmp lp
    
  exception:
	call exitProg
    
  stop:
    pop ax
    push cx
    push ax
	jmp ex
    
  ex:
    ret
enterString endp

printNumber proc
    pop bx
    pop ax
    push ax
    push bx
    push di
    lea di,buffer	    
    push di		    
    call convertNumber
    mov byte[di],'$'	
    pop di		    
    call printString	
    pop di
    call printEndline
    call clearBuffer
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

exitProg proc
    call printEndline
    mov ax, 4c00h
    int 21h
    ret
exitProg endp

;backSpace proc
;    push dx
;    
;    xchg ax, cx
;    div bx
;    xchg cx, ax
;    push ax
;    push cx
;    mov ah, 03h     ;Определяет положение курсора, dh = строка, dl = столбец
;    int 10h
;    mov ah, 02h     ;Перемещаем курсор на одну
;    int 10h         ;позицию назад
;    push dx
;    mov ah, 02h     ;Затираем предыдущий символ
;    mov dl, ' '
;    int 21h
;    pop dx
;    mov ah, 02h
;    int 10h
;    
;    pop cx
;    pop ax
;    pop dx
;   ret
;backSpace endp

clearBuffer proc
    mov [buffer], 0h
    mov [buffer+1], 0h
    mov [buffer+2], 0h
    mov [buffer+3], 0h
    mov [buffer+4], 0h
    mov [buffer+5], 0h
    mov [buffer+6], 0h
    ret
clearBuffer endp

end main

