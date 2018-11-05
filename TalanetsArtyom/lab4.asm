.MODEL SMALL
.STACK 100h

.DATA
    ten dw 10
    endl db 13, 10, '$'
    errorInput db "Input error", 13, 10, '$'
    stringIsValid db "String is valid", 13, 10, '$'
    stringIsNotValid db "String is not valid", 13, 10, '$'
    inputString   db 254,  256 dup(?)
.CODE

END_LINE:
    push ax
    mov ah, 9
    lea dx, endl
    int 21h
    pop ax	
ret

INPUT_STRING:	
    push ax
    push cx
    push dx	
	   
    mov ah,0Ah
    lea dx,inputString       ;DX = aдрес буфера
    int 21h     
    xor ch, ch
    mov cl,inputString[1]    ;cl = длина введённой строки
    jcxz input_error    	 ;Если длина = 0, возвращаем ошибку
    call END_LINE
	
    pop dx
    pop cx
    pop ax
    ret  
	
input_error:
    xor ax,ax  
    mov ah, 9
    lea dx, errorInput
    int 21h      
    jmp END_PROGRAM 

CHECK_STRING:
    push ax		;символ
    push bx		;адрес символа
    push cx		;счетчик символов
    push dx		;счетчик открытых скобок
	      
    xor dx, dx
    xor ch, ch
    mov cl,inputString[1]    ;cl = длина введённой строки
    inc cx   
    lea si, inputString
    inc si
    inc si
check_next_symbol:	    
    dec cx
    jcxz end_of_lines			;Если были рассмотрены все символы, то строка корректна
    lods inputString
    inc bx      	     	   	;Инкремент адреса
    cmp al,'('      	    	;Если очередной символ это '('
    jz bracket_is_open  		;переходим к следующему символу
    cmp al,')'   		       	;Если очередной символ это ')'
    jz bracket_closed   	    ;переходим к следующему символу
    jmp string_is_not_valid		;Если символ не '(' и не ')', то строка не корректна
	
bracket_is_open:
    inc dx						;увеличиваем количество открытых скобок
    jmp check_next_symbol

bracket_closed:
    cmp dx, 0					
    jz string_is_not_valid		;если открытых скобок нет, то строка не корректна
    dec dx						;уменьшаем количество открытых скобок
    jmp check_next_symbol		
	
end_of_lines:
    cmp dx, 0					
    jz string_is_valid			;если открытых и закрытых скобок одинаковое количество, то строка корректна
    jmp string_is_not_valid		;если открытых и закрытых скобок разное количество, то строка н корректна
	

string_is_valid:
    mov ah, 9
    lea dx, stringIsValid
    int 21h      
    jmp check_exit 

string_is_not_valid:
    mov ah, 9
    lea dx, stringIsNotValid
    int 21h      
    jmp check_exit  
 
check_exit:
    call END_LINE
    pop dx
    pop cx
    pop bx
    pop ax
    ret

   
START:
    mov ax,@data
    mov ds,ax
	
    call INPUT_STRING
    call CHECK_STRING
	
END_PROGRAM:
    mov ah,4ch
    int 21h
    
    
END START