.model small
.stack 100h
.data
	a dw ?
	b dw ?
	c dw ?
	d dw ?
	negFlag dw 0
	buf db 100, 100 dup ('$')
	endline db 13, 10, '$'
	outstr db 7, 7 dup ('$')
	zeroMsg db "Error: dividing by zero", 13, 10, '$'
	largeErrorStr db "Error: Your number is too big", 13, 10, '$'
	letterError db "Error: You've entered some invalid symbols", 13, 10, '$'
	minus db "-$"
.code



proc inputStr
	
	mov negFlag, 0
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
	
	
	mov negFlag, 1
plus:
	inc si

positive:
	ret

endp inputStr


proc strToDW
	xor dx,dx	;сумма

beg:	
	xor ax,ax
	mov al, [si]	;текущее значение в аэль
	inc si			;переход на следующий элемент строки
	cmp al, 13	;если это нулевой байт, то заканчиваем
	je exitStr
	
	cmp al,'9'	;Если это не цифра, то пропускаем
	jg notDigit
	cmp al,'0'      ;Если это не цифра, то пропускаем
	jb notDigit
	
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

notDigit:
	mov bp, 2
	jmp exit

overflow:
	mov bp, 1

exitStr:	
	mov ax,dx
	cmp ax, 32769
	jb notBad	

overflow2:
	mov bp, 1
	jmp exit

notBad:	
	cmp negFlag, 1
	jne maxpos
	neg ax
	jmp exit
	
maxpos:
	cmp ax, 32768
	je overflow2

exit:
	ret
endp strToDW


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

digitToStack:
	xor dx,dx       ;обнудяем dx
	div bx		;делим число на 10
	push dx		;и сохраняем остаток от деления(коэффициенты при степенях 10) в стек
	inc cx		;увеличиваем количество символов в числе
	cmp ax, 0	;преобразовали все число?
	jnz digitToStack	;если нет, то продолжить

stackToStr:
	pop ax		;восстанавливаем остаток от деления
	add al,'0'	;преобразовываем число в ascii символ
	mov [di], al
	inc di			;сохраняем в буфер
	loop stackToStr	;все цифры

	pop bx		;восстанавливаем регистры
	pop dx
	pop cx
	ret
endp printdec


proc checkNum
push ax
xor ax, ax

cmp bp, 1
jne checkErrorSymbol

lea dx, largeErrorStr
mov ah, 9
int 21h
pop ax
jmp endprog


checkErrorSymbol:
cmp bp, 2
jne checkZerodiv
lea dx, letterError
mov ah, 9
int 21h
pop ax
jmp endprog

checkZerodiv:
cmp bp, 3
jne noErrors
lea dx, zeroMsg
mov ah, 9
int 21h
pop ax
jmp endprog


noErrors:
pop ax
ret
endp checkNum



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

proc inputA
	xor ax, ax
	call inputStr
	call strToDW
	mov a, ax
	call checkNum
	ret
endp inputA

proc inputB
	xor ax, ax
	call inputStr
	call strToDW
	mov b, ax
	cmp b, 0
	jne nozero
	mov bp, 3

nozero:
	call checkNum
ret
endp inputB

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

proc err1
	cmp a, -32768
	jne exitErr1
	cmp b, -1
	jne exitErr1
	mov bp, 5
	lea dx, zeroMsg
	mov ah, 9
	int 21h
exitErr1:
	ret
endp err1

start:
	mov ax, @data
	mov ds, ax
	
	call inputA
	call inputB
	call err1
	cmp bp, 5
	je endprog
	call division
	call output

	endprog:
	mov ax, 4c00h
	int 21h

end start