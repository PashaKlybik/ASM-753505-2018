;В каждом из заданий переменные a, b, c, d определяются в сегменте данных и имеют размерность слово. 
;Необходимо выполнить над ними заданные арифметические и логические операции, а результат поместить в регистр AX.
;Вариант 10. Написать программу, которая помещает в регистр AX наименьшее из 4 чисел.
.model small
.stack 256
.data
	a dw 0
	b dw -3
	c dw 1
	d dw 2
.code

main:
	mov ax, @data
	mov ds, ax
	
	mov ax, a
	mov bx, b
	
	cmp ax, bx
	jg swapAB
	jmp j1
swapAB:
	mov ax, bx
j1:
	mov bx, c
	cmp ax, bx
	jg swapAC
	jmp j2
swapAC:
	mov ax, bx
j2:
	mov bx, d
	cmp ax, bx
	jg swapAD
	jmp exit
swapAD:
	mov ax, bx
    
exit:
	mov ax, 4c00h
	int 21h
end main