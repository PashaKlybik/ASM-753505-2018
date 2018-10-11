.model small
.stack 100h
.data
	a dw ?
	b dw ?
	c dw ?
	d dw ?
	flag dw 0
	buf db 7, 7 dup ('$')
	endline db 13, 10, '$'
	outstr db 7, 7 dup ('$')
	zero_msg db "Error: dividing by zero", 13, 10, '$'
	large_error_str db "Error: Your number is too big", 13, 10, '$'
	letter_error db "Error: You've entered some invalid symbols", 13, 10, '$'
	minus db "-$"
.code



proc input_str
	
	mov flag, 0
	lea dx, buf				
	mov ah, 10
	int 21h

	lea dx, endline			;переход на новую строку
	mov ah, 9
	int 21h

	lea si, buf
	inc si
	inc si
	
	cmp [si], byte ptr '-'
	jne neg1
	mov flag, 1
	inc si

neg1:
	ret

endp input_str


proc str2dw
	xor dx,dx	;сумма

beg:	
	xor ax,ax
	mov al, [si]	;текущее значение в аэль
	inc si			;переход на следующий элемент строки
	cmp al, 13	;если это нулевой байт, то заканчиваем
	jz exit
	
	cmp al,'9'	;Если это не цифра, то пропускаем
	jnbe err1
	cmp al,'0'      ;Если это не цифра, то пропускаем
	jb err1
	
	sub ax,'0'	;получаем цифровое значение
	
	shl dx,1	;умножаем сумму на 10
	jc err2
	add ax, dx
	shl dx, 2
	jc err2
	add dx, ax	;прибавляем текущее значение
	jc err2
	
	jmp beg

err1:
	mov bp, 2
	jmp exit

err2:
	mov bp, 1

exit:	
	mov ax,dx
	cmp ax, 32769
	jb norm	

nenorm:
	mov bp, 1
	jmp exit1

norm:	
	cmp flag, 1
	jne maxpos
	neg ax
	jmp exit1
	
maxpos:
	cmp ax, 32768
	je nenorm

exit1:
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

m1:
	xor dx,dx       ;обнудяем dx
	div bx		;делим число на степени 10
	push dx		;и сохраняем остаток от деления(коэффициенты при степенях) в стек
	inc cx		;увеличиваем количество символов в числе
	cmp ax, 0	;преобразовали все число?
	jnz m1	;если нет, то продолжить

m2:
	pop ax		;восстанавливаем остаток от деления
	add al,'0'	;преобразовываем число в ascii символ
	mov [di], al
	inc di			;сохраняем в буфер
	loop m2		;все цифры
	pop bx		;восстанавливаем регистры
	pop dx
	pop cx
	ret
endp printdec


proc check_num
push ax
xor ax, ax
cmp bp, 1
jne check_2
lea dx, large_error_str
mov ah, 9
int 21h
pop ax
jmp endprog


check_2:
cmp bp, 2
jne check_3
lea dx, letter_error
mov ah, 9
int 21h
pop ax
jmp endprog

check_3:
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

cmp cx, 1
jne pos4

push ax
xor ax, ax
mov ah, 9
lea dx, minus
int 21h
pop ax

pos4:
xor ax, ax
lea dx, outstr
mov ah, 9
int 21h

	lea dx, endline			;переход на новую строку
	mov ah, 9
	int 21h
ret
endp output


start:
	mov ax, @data
	mov ds, ax
	
	;ввод а
	xor ax, ax
	call input_str
	call str2dw
	mov a, ax
	call check_num

	;ввод b
	xor ax, ax
	call input_str
	call str2dw
	mov b, ax
	cmp b, 0
	jne nozero
	mov bp, 3

nozero:
	call check_num
	
	
	;деление
	xor dx, dx
	mov ax, a
	mov bx, b
	or ax, ax
	jns positive1
	not dx
	positive1:
	idiv bx


	;вывод
	xor cx, cx
	lea di, outstr
	call printdec

	call output

	endprog:
	mov ax, 4c00h
	int 21h

end start