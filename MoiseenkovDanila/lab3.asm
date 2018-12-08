;Лабораторная работа 3                  
;Задание:
;1) написать процедуру для вывода знакового числа размерностью слово из регистра AX на экран
;   на входе число в регистре AX
;   на выходе это число на экране
;   все задействованные регистры должны быть сохранены в процедуре
;2) написать процедуру для ввода знакового числа с клавиатуры в регистр AX
;   на входе пользовательский ввод, минус может быть только как первый символ
;   на выходе введенное число в регистре AX
;   все задействованные регистры должны быть сохранены в процедуре (кроме AX)
;   также должна быть проверка вводимого числа на правильность:
;      нельзя вводить не цифры, минус может быть только первым символом,
;      проверка на допустимые значения [-32768;32767]
;   дополнительно можно реализовать обработку клавиши бэкспэйс (удалить один
;      последний введенный символ) и клавиши ескэйп (удалить все число).
;3) в функции main действия, аналогичные предыдущей лабораторной работе, но для знаковых чисел.

.model small
.stack 256
.data
divzero db "Error. Division by zero", 13, 10, '$'
.code

writeln proc
	push dx
	push ax
	
	mov ah, 02h
	mov dx, 13
	int 21h
	mov dx, 10
	int 21h
	
	pop ax
	pop dx
	ret
writeln endp


del_prev proc
	push ax
	push dx
	mov ah, 02h
	mov dl, 8
	int 21h
	mov dl, ' '
	int 21h
	mov dl, 8
	int 21h
	pop dx
	pop ax
	ret
del_prev endp


writeSignedInt proc
	push ax
	push bx
	push cx
	push dx

	xor cx, cx
	mov bx, 10
	
	cmp ax, 0
	jns s_get_digit
		push ax
		mov ah, 02h
		mov dl, '-'
		int 21h
		pop ax
		not ax
		inc ax
s_get_digit:
	xor dx, dx
	div bx
	push dx
	inc cx
	
	test ax, ax
	jnz s_get_digit
	
	mov ah, 02h
s_out_digit:
		pop dx
		add dl, '0'
		int 21h
	loop s_out_digit
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
writeSignedInt endp


writeUnsignedInt proc
	push ax
	push bx
	push cx
	push dx

	xor cx, cx
	mov bx, 10
u_get_digit:
	xor dx, dx
	div bx
	push dx
	inc cx
	
	test ax, ax
	jnz u_get_digit
	
	mov ah, 02h
u_out_digit:
		pop dx
		add dl, '0'
		int 21h
	loop u_out_digit
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
writeUnsignedInt endp


readInt proc
	push bx
	push cx
	push dx

	xor cx, cx ;--считываемое число
	xor bx, bx ;--bh - длина считанной строки, bl - флаг знака минуса
inputChar:
	inc bh
	mov ah, 01h
	int 21h
	
	cmp al, 0Dh ; обработка enter
	jnz continueInput
		jmp exit_ReadInt
	
continueInput:
	cmp al, 08h ; обработка backspace
	jnz check_char
		mov ah, 02h
		mov dl, ' '
		int 21h
		mov dl, 8
		int 21h
	
		sub bh, 2
		adc bh, 0
	
		cmp bl, 1
		jnz erase_digit
			cmp bh, 0
			jnz erase_digit
			mov bx, 0
			jmp inputChar
			
erase_digit:
	mov ax, cx
	mov cx, 10
	xor dx, dx
	div cx
	mov cx, ax
	jmp inputChar
	
check_char:
	cmp al, '-'
	jnz check_isdigit
		cmp bh, 1
		jnz delete
			mov bl, 1
			jmp inputChar
check_isdigit:
	
	sub al, '0'
	
	cmp al, 10
	jb add_digit
delete:
	call del_prev
	sub bh, 1
	adc bh, 0
	jmp inputChar
add_digit:
	push cx ;сохраняем считываемое число
	push ax ;сохраняем считанную цифру
	
	mov ax, 10
	xor dx, dx
	mul cx
	
	jnc notOverflow1
	pop ax
	pop cx
	jmp delete
notOverflow1:
	mov dx, 8000h
	add dl, bl ;в dx теперь максимальное возможное значение модуля числа
	cmp dx, ax
	ja notOverflow2
		pop ax
		pop cx
		jmp delete
notOverflow2:
	mov cx, ax
	pop ax
	add cl, al
	adc ch, 0
	cmp dx, cx
		ja nowOverflow3
		pop cx
		jmp delete
nowOverflow3:	
	pop dx ; вынимаем ненужный cx
	jmp inputChar
exit_ReadInt:
	test bl, 1
	jz fill_ax
		dec cx
		not cx
fill_ax:
	mov ax, cx;
	
	pop dx
	pop cx
	pop bx
	ret
readInt endp


main:
	mov ax, @data
	mov ds, ax
	
	call readInt
	call writeSignedInt
	call writeln
	push ax
	
	call readInt
	call writeSignedInt
	call writeln
	mov bx, ax
	pop ax
	
	test bx, bx
	jnz BXnotzero
		mov ah, 9h
		mov dx, offset divzero
		int 21h
		jmp exitmain
BXnotzero:	
	cwd
	cmp ax, 8000h
	jnz signed_output
		cmp bx, -1
		jnz signed_output
			call writeUnsignedInt
			mov ah, 02h
			mov dl, ' '
			int 21h
			mov dl, '0'
			int 21h
			call writeln
			jmp exitmain
			
signed_output:
	idiv bx
	cmp dx, 0 ;проверка на отрицательный остаток
	jns output
		mov cx, -1 ; коэффициент для изменения частного при отрицательном остатке
		cmp bx, 0 ; определяем знак делителя
		jns correct ;при положительном делителе переходим к корректировке
			neg bx  ;при отрицательном делителе коэффициенты cx и bx берутся противоположными
			neg cx
correct:
	add dx, bx ;получаем остаток в стандартной форме
	add ax, cx ;корректируем частное в зависимости от корректировки остатка
output:
	call writeSignedInt
	
	mov ah, 02h
	push dx
	mov dl, ' '
	int 21h
	pop dx
	
	mov ax, dx
	call writeSignedInt
	call writeln
	
exitmain:
	mov ax, 4c00h
	int 21h
end main







mov ax, b7h