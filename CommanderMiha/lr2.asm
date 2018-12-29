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
	
; outhex  proc    near
        ; push    cx
        ; push    dx
        ; mov     cx, 4
; ; Очередная цифра получается в младшей тетраде AX после
; ; сдвига на 4 двоичных разряда, или на один шестнадцатеричный.
; @oh0:   rol     ax, 4
        ; mov     dl, al
        ; and     dl, 0Fh
; ; Далее, смотрим, выводить её цифрой или буквой. Если цифрой, то число надо
; ; увеличить на 30h, чтобы из 0..9 сделать 30h..39h - коды '0'..'9'.
; ; Если же буквой, то из 10..15 надо сделать 41h..46h - коды 'A'..'F',
; ; то есть число увеличить на 37h.
        ; cmp     dl, 9
        ; jbe     short @oh1
        ; add     dl, 7
; @oh1:   add     dl, 30h
; ; Итак, получили код символа в DL. Теперь его надо вывести функцией 2, но
; ; запись 2 в AH испортит исходное число.
        ; push    ax
        ; mov     ah, 02h
        ; int     21h
        ; pop     ax
; ; И так четыре раза, так как в AX четыре шестнадцатеричные цифры.
        ; loop    @oh0
        ; pop     dx
        ; pop     cx
        ; ret
; outhex  endp

; inhex   proc    near
        ; push    cx
        ; push    dx
; ; Будем накапливать число в CX.
        ; xor     cx, cx
; ; Введём очередную цифру, одновременно показав её на экране.
; @ih0:   mov     ah, 01h
        ; int     21h
; ; Теперь надо преобразовать её в число. Надо отобразить
; ; '0'..'9' (30h..39h) в 0..9, 'A'..'F' (41h..46h) и
; ; 'a'..'f' (61h..66h) в 10..15, а всё остальное забраковать.
; ; Ну, что ж, приступим...
; ; '0'..'9', 'A'..'F', 'a'..'f' => 0..9, 11h..16h, 31h..36h
        ; sub     al, 30h
; ; Пользуясь тем, что sub устанавливает флаги так же, как cmp,
; ; прекращаем ввод, если символ оказался до '0' в таблице ASCII.
; ; Сюда же, кстати, попадает случай нажатия enter (0Dh).
        ; jb      short @ih3
; ; Теперь смотрим, если это цифра (0..9), то мы её получили. Можно
; ; добавлять её к числу.
        ; cmp     al, 09h
        ; jbe     short @ih2
; ; Если же нет, то переводим 11h..16h, 31h..36h в 0..5, 20h..25h.
        ; sub     al, 11h
; ; Если исходный символ был между '9' и 'A', прекращаем ввод.
        ; jb      short @ih3
; ; Если он попал в 'A'..'F', перешедший в 0..5, то, чтобы получить
; ; введённую шестнадцатеричную цифру, осталось прибавить к DL десять.
        ; cmp     al, 5
        ; jbe     short @ih1
; ; Если до сих пор не успокоились, то переводим 20h..25h в 0..5.
; ; Если выскочили за ноль, то введённый символ нужно забраковать.
        ; sub     al, 20h
        ; jb      short @ih3
; ; Если получили нечто слишком большое, тоже сдаёмся.
        ; cmp     al, 5
        ; ja      short @ih3
; ; Иначе исходный символ попал в 'a'..'f', отобразился в 0..5, и теперь,
; ; если мы прибавим к этому десять, получим введённую шестнадцатеричную цифру.
; @ih1:   add     al, 10
; ; Итак, в AL очередная цифра. Надо приписать её справа к
; ; уже имеющемуся в CL числу. Для этого сдвигаем CL на один шестнадцатеричный
; ; разряд, и заполняем его введённой шестнадцатеричной цифрой.
; @ih2:   shl     cx, 4
        ; or      cl, al
; ; Повторяем, пока не надоест вводить нечто шестнадцатеричное.
        ; jmp     short @ih0
; ; Сюда мы попадём, когда введут нецифру. Здесь перейдём на новую строку
; @ih3:   mov     ah, 02h
        ; mov     dl, 0Dh
        ; int     21h
        ; mov     dl, 0Ah
        ; int     21h
; ; и запишем результат в AX.
		; cmp cx, 0FFFFh
		; ja overfull

        ; mov     ax, cx
        ; pop     dx
        ; pop     cx
        ; ret
		
; overfull:
	; mov cx, 0
	; jmp @ih0
	
; inhex   endp

outdecimal  proc    near
        push    cx
        push    dx
        mov     cx, 4
; Очередная цифра получается в младшей тетраде AX после
; сдвига на 4 двоичных разряда, или на один шестнадцатеричный.
@od0:   rol     ax, 4
		push 	ax
        mov     dl, al
		pop 	ax
        and     dl, 0fh
; Далее, смотрим, выводить её цифрой или буквой. Если цифрой, то число надо
; увеличить на 30h, чтобы из 0..9 сделать 30h..39h - коды '0'..'9'.
; то есть число увеличить на 37h.
        cmp     dl, 9
        jbe     short @od1
		add     dl, 7
@od1:   add     dl, 30h
; Итак, получили код символа в DL. Теперь его надо вывести функцией 2, но
; запись 2 в AH испортит исходное число.
        push    ax
        mov     ah, 02h
        int     21h
        pop     ax
; И так четыре раза, так как в AX четыре шестнадцатеричные цифры.
        loop    @od0
		
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