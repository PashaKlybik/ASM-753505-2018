;Лабораторная работа 2
;Задание:
;1) написать процедуру для вывода числа размерностью слово из регистра AX на экран
;   на входе число в регистре AX
;   на выходе это число на экране
;   все задействованные регистры должны быть сохранены в процедуре (т.е. все регистры,
;      значения которых каким-либо образом меняются внутри процедуры, должны быть
;      помещены в начале процедуры в стек и извлечены в конце процедуры в правильном порядке)
;2) написать процедуру для ввода числа с клавиатуры в регистр AX
;   на входе пользовательский ввод
;   на выходе введенное число в регистре AX
;   все задействованные регистры должны быть сохранены в процедуре (кроме AX)
;   также должна быть проверка вводимого числа на правильность:
;      нельзя вводить не цифры, нельзя, например, ввести 70000
;   дополнительно можно реализовать обработку клавиши бэкспэйс (удалить один
;      последний введенный символ) и клавиши ескэйп (удалить все число).
;3) в функции main пользователь вводит делимое, затем сразу же осуществляется вывод делимого
;      на экран, затем пользователь вводит делитель, далее осуществляется вывод делителя на экран,
;      затем осуществляется деление и вывод результата деления на экран.




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


writeInt proc
	push ax ;нужно вывести ax
	push bx
	push cx
	push dx

    xor cx, cx
    mov bx, 10
get_digit:
		xor dx, dx
		div bx
		push dx
		inc cx
		test ax, ax
		jnz get_digit
	
    mov ah, 02h
out_digit:
		pop dx
		add dl, '0'
		int 21h
	loop out_digit
	
	pop dx
	pop cx
	pop bx
	pop ax
    ret
writeInt endp


readInt proc
	push bx
	push cx
	push dx

	mov cx, 0 ; в cx будет записываться число
	mov bx, 10
again:
	mov ah, 01h
	int 21h
	
	cmp al, 0Dh ;обработка enter
	jz exit
	
	cmp al, 08h ;обработка backspace
	jnz check_char
		mov ah, 02h
		mov dl, ' '
		int 21h
		mov dl, 8
		int 21h
		xor dx, dx
		mov ax, cx
		div bx
		mov cx, ax
		jmp again
check_char:

	sub al, '0'
	mov ah, 10;
	
	cmp ah, al
	ja digit
	call del_prev
	jmp again
digit:
	push ax
	mov ax, bx
	xor dx, dx
	mul cx
	
	test dx, dx
	jz continue1
		call del_prev
		pop ax
		jmp again
continue1:
	mov dx, cx ;сохраним cx на случай переполнения
	mov cx, ax
	pop ax
	
	add cl, al
	adc ch, 0
	jnc continue2
	mov cx, dx
	call del_prev
	jmp again
continue2:	
	jmp again
exit:
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
	call writeInt
	call writeln
	push ax
	
	call readInt
	call writeInt
	call writeln
	mov bx, ax
	pop ax
	
	test bx, bx
	jnz notzero
		mov ah, 9h
		mov dx, offset divzero
		int 21h
		jmp exitmain
notzero:	
	mov dx, 0
	div bx
	call writeInt
	
	mov ah, 02h
	push dx
	mov dl, ' '
	int 21h
	pop dx
	
	mov ax, dx
	call writeInt
	call writeln
exitmain:
    mov ax, 4c00h
    int 21h
end main