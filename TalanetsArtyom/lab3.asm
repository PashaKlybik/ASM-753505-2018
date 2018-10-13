.MODEL SMALL
.STACK 100h

.DATA
	ten dw 10
	endl db 13, 10, '$'
	errorInput db "Input error", 13, 10, '$'
	errorDivByZero db "Division by zero", 13, 10, '$'
	buffer   db 7,  256 dup(?)
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
	push di 			;di = 1 <=> число отрицательное
	   
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
 
	;Проверка первого символа на знак '-'
	mov dl,[bx]			;Загрузка в dl первого символа строки (в dx код символа)    
	xor di, di
    cmp dx, '-'
    jnz input_loop		;если первый знак не '-', то переходим по метке
	;если первый знак '-'
    inc bx				;Инкремент адреса
    dec cx				;Декремент счетчика
    cmp cx, 0			;если больше знаков нет (введен только '-')
    jz input_error 		;возвращаем ошибку
    mov di, 1			;di = 1 <=> число отрицательное
	
 
input_loop:
    mov dl,[bx]			;Загрузка в dl очередного символа строки (в dx код символа)
    inc bx              ;Инкремент адреса
    cmp dx,'0'          ;Если код символа меньше кода '0', то 
    jl input_error      ;возвращаем ошибку
    cmp dx,'9'          ;Если код символа больше кода '9', то
    jg input_error      ;возвращаем ошибку
    sub dx,'0'			;в dx цифры
	push dx
	mul ten             ;AX = AX * 10
	jc input_error      ;Если перенос - ошибка
    jo input_error      ;Если переполнение - ошибка
	pop dx
	add ax, dx
	jc input_error      ;Если перенос - ошибка
    jo input_error      ;Если переполнение - ошибка
    loop input_loop     ;Команда цикла
    jmp input_exit      ;Успешное завершение (здесь всегда CF = 0)
 
input_error:
    xor ax,ax  
    mov ah, 9
    lea dx, errorInput
    int 21h      
    jmp END_PROGRAM   
 
input_exit:
	call END_LINE
	cmp di, 1
	jnz input_is_positive
	neg ax
	
input_is_positive:
	pop di
	pop dx
	pop cx
	pop bx
	ret

OUTPUT:
	push ax
	push bx
	push cx
	push dx		
	push di 			;di = 1 <=> число отрицательное
	
	xor cx, cx
	xor di, di
	
	or ax, ax
	jns push_digit_to_stack
	mov di, 1
	neg ax
	
push_digit_to_stack:
    xor dx,dx
    div ten
    push dx						;добавили в стек очередную цифру числа
    inc cx
    test ax, ax					;(логическое И)
    jnz push_digit_to_stack 	;если ax - не ноль, то добавляем следующую цифру
       
    mov ah, 02h
    cmp di, 1
    jnz print
    mov dx, '-'
    int 21h
print:
	pop dx			;в dx - цифра, которую необходимо вывести
    add dl, '0'		;символ, выводимы на дисплей
    int 21h
    loop print   
    call END_LINE
    
    pop di 	
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
    
SIGNED_DIVISION:	;деление со знаком, 
					;вход: AX - делимое, BX - делитель
					;выход: AX - частное
	push dx	
	xor dx, dx		;dx = 0 <=> делимое положительное
	or ax, ax		;проверяем знак делимого
	jns division	;если делимое положительное, оставляем  dx = 0
	sub dx, 1		;если делимое отрицательно, то dx=1..1 
	division:		
	call CHECK_DIV_BY_ZERO
	idiv bx	
	pop dx
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
	
	call SIGNED_DIVISION
		
	call OUTPUT
	
END_PROGRAM:
    mov ah,4ch
    int 21h
    
    
END START