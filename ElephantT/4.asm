.model small
.stack 100
.386
.data	;сегмент данных 
	cnt db 0
	ten dw 10
	max db 250
	ent db 13,10,'$' 
	maxPos dw 0
	minPos dw 0
	maxLength db 0
	minLength db 99
	maxValue dw 0
	maxLetter db ?
	string db 250, 252 dup('$')
	letters db 26, 27 dup('$')
	s db "The number of occurrences of the letter ", '$'
	s1 db "The most common letter ", '$'
.code

putdigit macro
	local lput1
	local lput2
	local exx
 
	push 	ax
	push	cx
	push 	-1	;сохраним признак конца числа
	mov 	cx,10	;делить будем на 10
lput1:	xor 	dx,dx	;чистим регистр dx
	mov 	ah,0                   
	div 	cl	;Делим 
	mov 	dl,ah	
	push 	dx	;Сохраним цифру
	cmp	al,0	;Остался 0? 
	jne	lput1	;нет -> продолжим
	mov	ah,2h
lput2:	pop	dx	;Восстановим цифру
	cmp	dx,-1	;Дошли до конца -> выход 
	je	exx
	add	dl,'0'	;Преобразуем число в цифру
	int	21h	;Выведем цифру на экран
	jmp	lput2	;И продолжим
exx:
	mov	dl,' ' 
	int	21h
	pop	cx
	pop 	ax
endm

NewLine PROC	;процедура для перехода на новую строку в выводе

  push  ax	;сохранение регистров
  push  dx
  xor ax, ax
  xor dx, dx

  lea   dx,ent  ;непосредственно вывод
  mov   ah,09h  
  int   21h
 
  pop   dx
  pop   ax

  ret
NewLine ENDP


input PROC	;ввод строки
	mov ah, 0ah
    lea dx, string
    int 21h 
    
  
	ret
input ENDP
	
start:
    mov ax, @data
    mov ds, ax
    
 	call input ;ввод строки

 	call NewLine  ;переход на новую


 	xor ax, ax
 	mov cl, max ;max - переменная для длины введённой строки
 	lea si, string	;указываем на начало введённой строки
 	mov maxPos, si ;записываем в позицию макс слова 1ое слово 
 	inc si
 	inc si ;переходим на байт, где хранится первая буква
 	push si
 	mov bx, 0
 	cld ; очистка флага направления - определяем порядок обхода строки слева направо

   cycle:	;обход строки
 	 LODSB   ;получаем очередной символ
 	 cmp al, ' '	;если пробел, значит конец слова 
 	 jne another ; если нет то идём читать дальше
 	 jmp ok ;если да, то идём проверять было ли очередное слово максимальным
 	another:
 	 cmp al, 13 ;если конец строки, то уходим
 	 jne next; если не конец, то читаем дальше

 	 ok: 
 	 xor dx, dx 
 	 mov dx, si ;запоминаем текущую позицию в слове
 	 pop si ; достаёт позицию макс слова
 
 	 xor bx, bx
 	 mov bl, maxLength 
 	 cmp bl, cnt ; проверяем больше ли максимальная длина длины последнего слова
 	 jge next1 ; если больше то, идём искать дальше
 	 mov bl, cnt ;иначе записываем новый максимум
 	 mov maxPos, si ;и запоминаем позицию макс слова
 	 mov maxLength, bl
 	next1:  
 	 mov bl, 0
 	 mov cnt, bl ;обнуляем счётчик длины
 	 mov si, dx ;возвращаем текущую позицию в обходе строки
 	 push si ; запоминаем позицию следующего слова
 	loop cycle
 	next:
 	 inc cnt ;если мы не встретили конец строки или пробел, то тут увеличиваем счётчик длины слова
   loop cycle 
   	pop si

   xor ax, ax 					;далее точно такой же цикл, только для поиска минимального слова
 	mov cl, max
 	lea si, string
 	inc si
 	inc si
 	push si
 	mov bl, 0
 	mov cnt, bl
 	cld

   cycle1:	
 	 LODSB
 	 cmp al, ' '	 
 	 jne another1
 	 jmp ok1
 	another1:
 	 cmp al, 13
 	 jne next2

 	 ok1:
 	 xor dx, dx
 	 mov dx, si
 	 pop si

 	 xor bx, bx
 	 mov bl, minLength
 	 cmp bl, cnt
 	 jl next11 ;проверяем меньше ли минимальная длина длины последнего слова
 	 mov bl, cnt
 	 mov minPos, si
 	 mov minLength, bl
 	next11:  
 	 mov bl, 0
 	 mov cnt, bl
 	 mov si, dx
 	 push si
 	loop cycle1
 	next2:
 	 inc cnt
   loop cycle1
   	pop si


  

    xor ax, ax
    mov si, maxPos ;записываем начало макс слова
  
    mov cl, maxLength
    cycle3:	;выводим макс слово на экран
 	 LODSB
	 mov dl, al 
	 mov ah, 02h
	 int 21h
   loop cycle3

   	mov dl, ' '
   	mov ah, 02h
   	int 21h

	xor ax, ax ;выводим длину макс слова на экран
 	mov al, maxLength
 	putdigit

   	call NewLine 

 	

 	xor ax, ax
    mov si, minPos	;записываем начало мин слова
  
    mov cl, minLength
    cycle4:		;выводим мин слово на экран
 	 LODSB
	 mov dl, al 
	 mov ah, 02h
	 int 21h
   loop cycle4

   	mov dl, ' '
   	mov ah, 02h
   	int 21h

 	xor ax, ax	;выводим длину мин слова на экран
 	mov al, minLength
 	putdigit
 	
   all:	;конец
 	mov al, 0
    mov ah, 4ch
    int 21h
end start