.model small
.stack 256
.data
	ten dw 10
	message1 db 'enter the dividend:',13,10,'$'
	message2 db 'enter the divider:',13,10,'$'
	message3 db 'the quotient is:',13,10,'$'
	message4 db 'the remainder is:',13,10,'$'
	errormessage1 db 'You cant divide on null',13,10,'$'
	errorinvalidinputmessage db 'Wrong input. Expected digit!',13,10,'$'
	erroroverflowmessage db 'This number is bigger then 65536!',13,10,'$'
.code
main:

	mov ax, @data
	mov ds, ax
	
	call clearscreen1
dividend:
	lea dx, message1
	call outmessage
	call nextline
	call indecimal
    call outdecimal
	call nextline
	mov cx, ax
divider:
	lea dx, message2
	call outmessage	
	call indecimal
	cmp ax, 0
	je NullDivision ; перемещается на точку NullDivision, при условии того, что значение в регистре будет равно заданному значению 
	call outdecimal
	call nextline
	mov bx, ax
quotient:
	mov dx, 0
	mov bx, ax
	mov ax, cx
	div bx
	push dx
	lea dx, message3
	call outmessage
	pop dx
	call outdecimal
	call nextline
remainder:
	mov ax, dx
	lea dx, message4
	call outmessage
	call outdecimal
	call nextline
	
exit_main:
	mov ax, 4c00h
	int 21h

NullDivision:
	
	lea dx, errormessage1
    call outmessage
	jmp divider
		
outmessage proc
	push ax
	push dx
	
    mov ah, 09h
    int 21h
	
	pop dx
	pop ax
	
	ret
endp outmessage
	
clearscreen1 proc
	push ax
	
	mov ax, 3
	int 10h
	
	pop ax
	
	ret
clearscreen1 endp

nextline proc
	push ax
	push dx
	
	mov     ah, 02h
    mov     dl, 0Dh
    int     21h
    mov     dl, 0Ah
    int     21h

	pop dx
	pop ax
	
	ret
nextline endp
	
outdecimal  proc    near
		push    cx
        push    dx
		mov 	bx, ten
        xor 	cx, cx
		push 	ax
; Очередная цифра получается в младшей тетраде AX после
; сдвига на 4 двоичных разряда, или на один шестнадцатеричный.
@od0:	
		xor		dx,	dx
		div 	bx
		push 	dx
		inc		cx
		cmp		ax, 0
		jnz		@od0

@od1:	pop 	dx
		add     dl, 30h
        mov     ah, 02h
        int     21h
        loop    @od1
		
		pop 	ax
        pop     dx
        pop     cx
        ret
outdecimal  endp


indecimal   proc    near
		push    bx
        push    cx
        push    dx
; Будем накапливать число в CX.
        xor     cx, cx
; Введём очередную цифру, одновременно показав её на экране.
@id0:   mov     ah, 01h
        int     21h
; Теперь надо преобразовать её в число. Надо отобразить
; '0'..'9' (30h..39h) в 0..9, а всё остальное забраковать.
; Ну, что ж, приступим...
; '0'..'9' => 0..9
        sub     al, 30h
; Пользуясь тем, что sub устанавливает флаги так же, как cmp,
; прекращаем ввод, если символ оказался до '0' в таблице ASCII.
; Сюда же, кстати, попадает случай нажатия enter (0Dh).
        jb      short @id3
; Теперь смотрим, если это цифра (0..9), то мы её получили. Можно
; добавлять её к числу.
        cmp     al, 09h
		ja 		short @id3
; Итак, в AL очередная цифра. Надо приписать её справа к
; уже имеющемуся в CL числу. Для этого сдвигаем CL на один шестнадцатеричный
; разряд, и заполняем его введённой шестнадцатеричной цифрой.
@id2:
        mov ah, 0
		mov bx, ax
		mov ax, cx
		mul     ten
		jo		overflow
		add ax, bx
		jo      overflow
		mov cx, ax

; Повторяем, пока не надоест вводить нечто десятичное.
        jmp     short @id0
; Сюда мы попадём, когда введут нецифру. Здесь перейдём на новую строку
@id3:   
		cmp 	al, 0DDh
		jne		short invalidinput
		jmp @id4
		
invalidinput:
		lea dx, errorinvalidinputmessage
		call outmessage
		mov cx, 0h
		jmp short @id0
		
overflow:
		lea dx, erroroverflowmessage
		call outmessage
		mov cx, 0h
		jmp short @id0
		
@id4:
        mov     ax, cx
        pop     dx
        pop     cx
		pop     bx
        ret
	
indecimal   endp
end main