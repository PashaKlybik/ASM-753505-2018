.MODEL SMALL
.STACK 100h

.DATA
	ten dw 10
	endl db 13, 10, '$'
	errorInput db "Input error", 13, 10, '$'
	errorDivByZero db "Division by zero", 13, 10, '$'
	buffer   db 6,  256 dup(?)
.CODE

END_LINE:
	push ax
	mov ah, 9
	lea dx, endl
	int 21h
	pop ax	
ret

INPUT:	
	push bx
	push cx
	push dx	
	
	              
    mov ah,0Ah
    lea dx,buffer       ;DX = aдрес буфера
    int 21h     
    xor ch, ch
    mov cl,buffer[1]    ;cl = длина введённой строки
    lea bx, buffer     	;bx = адрес строки
	inc BX
    inc BX
    jcxz input_error    ;Если длина = 0, возвращаем ошибку
    xor ax,ax           ;AX = 0
 
input_loop:
    mov dl,[bx]			;Загрузка в dl очередного символа строки (в dx код символа)
    inc bx              ;Инкремент адреса
    cmp dx,'0'          ;Если код символа меньше кода '0', то 
    jl input_error      ;возвращаем ошибку
    cmp dx,'9'          ;Если код символа больше кода '9', то
    jg input_error      ; возвращаем ошибку
    sub dx,'0'			;в dx цифры
	push dx
	mul ten             ;AX = AX * 10
	jc input_error          ;Если перенос - ошибка
    jo input_error          ;Если переполнение - ошибка
	pop dx
	add ax, dx
	jc input_error          ;Если перенос - ошибка
    jo input_error          ;Если переполнение - ошибка
    loop input_loop         ;Команда цикла
    jmp input_exit          ;Успешное завершение (здесь всегда CF = 0)
 
input_error:
    xor ax,ax  
    mov ah, 9
    lea dx, errorInput
    int 21h      
    jmp END_PROGRAM   
 
input_exit:
	call END_LINE
	pop dx
	pop cx
	pop bx
	
ret

OUTPUT:
	push ax
	push bx
	push cx
	push dx
		
	xor cx, cx
push_digit_to_stack:
    xor dx,dx
    div ten
    push dx		;добавили в стек очередную цифру числа
    inc cx
    test ax, ax		;(логическое И)
    jnz push_digit_to_stack    ;если ax - не ноль, то добавляем следующую цифру
    
    mov ah, 02h
print:
	pop dx			;в dx - цифра, которую необходимо вывести
    add dl, '0'		;символ, выводимы на дисплей
    int 21h
    loop print   
    call END_LINE
    
    pop dx
    pop cx 
    pop bx 
    pop ax  
ret

CHECK_DIV_BY_ZERO:
	push ax
	xor ax, ax  
	cmp bx, ax
	jnz no_error
    mov ah, 9
    lea dx, errorDivByZero
    int 21h      
    jmp END_PROGRAM   
no_error:    
    pop ax
    ret

START:
	
    mov ax,@data
	mov ds,ax
		
	call INPUT      
   	call OUTPUT
	mov bx, ax
	call INPUT      
   	call OUTPUT   	
	xchg ax, bx
	xor dx, dx
	call CHECK_DIV_BY_ZERO
	div bx
	call OUTPUT
	
END_PROGRAM:
    mov ah,4ch
    int 21h
    
    
END START