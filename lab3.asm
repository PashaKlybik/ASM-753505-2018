.model small
.stack 100h
.data
	a dw ?
	b dw ?
	c dw ?
	d dw ?
	neg_flag dw 0
	buf db 100, 100 dup ('$')
	endline db 13, 10, '$'
	outstr db 7, 7 dup ('$')
	zero_msg db "Error: dividing by zero", 13, 10, '$'
	large_error_str db "Error: Your number is too big", 13, 10, '$'
	letter_error db "Error: You've entered some invalid symbols", 13, 10, '$'
	minus db "-$"
.code



proc input_str
	
	mov neg_flag, 0
	lea dx, buf				
	mov ah, 10
	int 21h

	lea dx, endline			;переход на новую строку
	mov ah, 9
	int 21h

	lea si, buf				;пропускаем две первые ячейки где хранятся размеры массива
	inc si
	inc si
	
	cmp [si], byte ptr '+'
	je plus
	
	cmp [si], byte ptr '-'		
	jne positive
	
	
	mov neg_flag, 1
plus:
	inc si

positive:
	ret

endp input_str


proc str2dw
	xor dx,dx	;сумма

beg:	
	xor ax,ax
	mov al, [si]	;текущее значение в аэль
	inc si			;переход на следующий элемент строки
	cmp al, 13	;если это нулевой байт, то заканчиваем
	je exit_str
	
	cmp al,'9'	;Если это не цифра, то пропускаем
	jg not_digit
	cmp al,'0'      ;Если это не цифра, то пропускаем
	jb not_digit
	
	sub ax,'0'	;получаем цифровое значение
	
	shl dx,1	;умножаем сумму на 10
	jc overflow
	add ax, dx
	jc overflow
	shl dx, 2
	jc overflow
	add dx, ax	;прибавляем текущее значение
	jc overflow
	
	jmp beg

not_digit:
	mov bp, 2
	jmp exit

overflow:
	mov bp, 1

exit_str:	
	mov ax,dx
	cmp ax, 32769
	jb not_bad	

overflow2:
	mov bp, 1
	jmp exit

not_bad:	
	cmp neg_flag, 1
	jne maxpos
	neg ax
	jmp exit
	
maxpos:
	cmp ax, 32768
	je overflow2

exit:
	ret
endp str2dw


proc printdec

	or ax, ax
	jns pos

	neg ax
	mov cx, 1
	
pos:
	push cx	;сохраняем регистры
	push dx
	push bx
	mov bx,10	;основание системы
	xor cx,cx	;в сх будет количество цифр в десятичном числе

dig_to_stack:
	xor dx,dx       ;обнудяем dx
	div bx		;делим число на 10
	push dx		;и сохраняем остаток от деления(коэффициенты при степенях 10) в стек
	inc cx		;увеличиваем количество символов в числе
	cmp ax, 0	;преобразовали все число?
	jnz dig_to_stack	;если нет, то продолжить

stack_to_str:
	pop ax		;восстанавливаем остаток от деления
	add al,'0'	;преобразовываем число в ascii символ
	mov [di], al
	inc di			;сохраняем в буфер
	loop stack_to_str	;все цифры

	pop bx		;восстанавливаем регистры
	pop dx
	pop cx
	ret
endp printdec


proc check_num
push ax
xor ax, ax

cmp bp, 1
jne check_error_symbol

lea dx, large_error_str
mov ah, 9
int 21h
pop ax
jmp endprog


check_error_symbol:
cmp bp, 2
jne check_zerodiv
lea dx, letter_error
mov ah, 9
int 21h
pop ax
jmp endprog

check_zerodiv:
cmp bp, 3
jne no_errors
lea dx, zero_msg
mov ah, 9
int 21h
pop ax
jmp endprog


no_errors:
pop ax
ret
endp check_num



proc output

xor cx, cx
lea di, outstr
call printdec


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
lea dx, outstr
mov ah, 9
int 21h

lea dx, endline			;переход на новую строку
mov ah, 9
int 21h

ret
endp output

proc input_A
	xor ax, ax
	call input_str
	call str2dw
	mov a, ax
	call check_num
	ret
endp input_A

proc input_B
	xor ax, ax
	call input_str
	call str2dw
	mov b, ax
	cmp b, 0
	jne nozero
	mov bp, 3

nozero:
	call check_num
ret
endp input_B

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

start:
	mov ax, @data
	mov ds, ax
	
	call input_A
	call input_B
	call division
	call output

	endprog:
	mov ax, 4c00h
	int 21h

end start