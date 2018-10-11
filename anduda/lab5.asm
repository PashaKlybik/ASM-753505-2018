.model small
.stack 100h
.data
	num dw 0
	flag1 dw 0
	in_filename db "input.txt"
	n dw ?
	errmsg db "impossible to mult", 13, 10, '$'
	buf db  100 dup (?)
			Matrix_1 dw 100 dup (?)		; Первая матрица
			n1			dw ? 	; Число строк первой матрицы
			m1			dw ?	; Число столбцов первой матрицы
			Matrix_2		dw 100 dup (?)	; Вторая матрица
			n2			dw ?	; Число строк второй матрицы
			m2			dw ?	; Число столбцов второй матрицы
			Matrix_Result	dw 100 dup (?)	; Матрица-результат
	strresult db 200 dup (' ')
	endline db 13, 10
	handle dw ?
	out_filename db "output.txt"


.code

proc matrix_mul

			lea bx, Matrix_Result
			mov dx, n1	

MET1:		mov cx, m2
			push dx
			
MET2:		xor ax, ax
			mov [bx], ax
			push cx
			mov cx, m1
			
MET3:		mov ax, word ptr [di]
			mov dx, word ptr [si]
			imul dx
			
			add [bx], ax		; Запись предварительного результата
			
			add di, 2			; Переход к следующему элементу строки первой матрицы
			
			mov ax, 2
			mov dx, m2
			imul dx
			add si, ax		; Переход к следующему элементу столбца второй матрицы
	
loop MET3
			
			add bx, 2			; Переход к следующему элементу строки матрицы-результата


			sub si, ax
			mov ax, m2
			shl ax, 1
			mov cx, n2
			dec cx
			mul cx
			
			sub si, ax
			inc si
			inc si
			mov cx, m1
			mov ax, 2
			imul cx
			sub di, ax		; Возвращение к началу строки первой матрицы

			pop cx
loop MET2
			
			mov ax, 2
			mov dx, m1
			imul dx
			add di, ax		; Переход к следующей строке первой матрицы

			lea si, Matrix_1
			add si, n ; Переход к началу первого столбца второй матрицы
			
			pop dx
			dec dx
			JNZ MET1
	ret
endp matrix_mul



proc read_from_file
	push ax
	push bx
	push cx
	push dx
	
	xor dx, dx
    mov ah,3Dh              ;Функция DOS 3Dh (открытие файла)
    xor al,al               ;Режим открытия - только чтение
    lea dx, in_filename
    xor cx,cx               ;Нет атрибутов - обычный файл
    int 21h
	
	mov handle, ax
	
	
	xor dx, dx
    mov bx,ax
    mov ah,3Fh           ;Функция DOS 3Fh (чтение из файла)
    lea dx,buf
    mov cx, 95           ;Максимальное кол-во читаемых байтов
    int 21h
	
	
	xor bx, bx
	lea si,buf
    add si, ax
    
	inc si
	inc si
	
	mov byte ptr [si], '$'
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	xor ax, ax
	mov ah,3Eh
    mov bx, handle
	int 21h                
	
	ret	
endp read_from_file


proc read_matrix
	xor bp, bp
	xor dx,dX
	
beg:	
	xor ax,ax
	lodsb

	cmp al, '$'
	jz exit

	cmp al, '-'
	jne @div 

	inc bp
	jmp beg

@div:
	cmp al, '9'
	jg no_num

	cmp al, '0'
	jb no_num

	sub ax,'0'	;получаем цифровое значение
	shl dx,1	;умножаем сумму на 10
	add ax, dx
	shl dx, 2
	add dx, ax	;прибавляем текущее значение
	jmp beg
no_num:
	cmp al,' '
	jne abz
	jmp number
abz:
	inc si
	
number:
	mov ax,dx
	
	cmp bp, 1
	jne posit
	neg ax
	posit:
	mov [di], ax
	xor dx, dx
	inc di
	inc di
	xor bp, bp
	jmp beg
exit:
	ret
endp read_matrix


proc read_digit
	xor ax,ax
	lodsb	;берем cимвол
	sub al,'0'	;получаем цифровое значение
	ret
endp read_digit


proc read_columns_and_strinngs
	call read_digit
	mov n1, ax
	inc si

	call read_digit
	mov m1, ax
	inc si

	call read_digit
	mov n2, ax
	inc si

	call read_digit
	mov m2, ax
	inc si
	inc si

	ret	
endp read_columns_and_strinngs




proc matrix_to_string
	add si, 6
	push cx
	push si
	xor bp, bp

	cmp ax, 0
	jg pos

	neg ax
	inc bp
pos:
	xor dx, dx
	mov cx, 10
	div cx
	mov byte ptr [si], '0'
	add [si], dl

	dec si

	cmp ax, 0
	jg pos

	cmp bp, 0
	je ex

	mov byte ptr [si], '-'
	xor bp, bp
ex:
	pop si
	inc si
	pop cx
	ret
endp matrix_to_string


proc output

	lea di, Matrix_Result
	mov cx, n1
	all_matrix:
	push cx

	mov cx, m2
	out_string:
	mov ax, [di]
	call matrix_to_string
	inc di
	inc di
	loop out_string

	mov byte ptr [si], 13
	inc si
	mov byte ptr [si], 10
	inc si
	pop cx
	loop all_matrix
	;mov byte ptr [si], '$'
	ret
endp output


proc file_output

    mov ah,3Ch              ;Функция DOS 3Ch (создание файла)
    lea dx, out_filename        ;Имя файла
    xor cx,cx               ;Нет атрибутов - обычный файл
    int 21h                 ;Обращение к функции DOS
	mov handle,ax         ;Сохранение дескриптора файла
 
    mov bx,ax               ;Дескриптор файла
    mov ah,40h              ;Функция DOS 40h (запись в файл)
    lea dx, strresult           ;Адрес буфера с данными
    mov cx, 200         ;Размер данных
    int 21h                 ;Обращение к функции DOS
 
close_file:
    mov ah, 3Eh              ;Функция DOS 3Eh (закрытие файла)
    mov bx, handle         ;Дескриптор
    int 21h                 ;Обращение к функции DOS	
	ret
endp file_output



start:
mov ax, @DATA ; настроим DS
    mov DS, ax       ; на реальный сегмент
	mov es, ax
	
	call read_from_file

	lea si, buf	
	call read_columns_and_strinngs
	mov ax, m1
	cmp ax, n2
	jne err1
	xor ax, ax
	lea di, Matrix_1	
	call read_matrix
	
	lea di, Matrix_1
	lea si, Matrix_1
	
	xor ax, ax
	mov ax, n1
	mov dx, m1
	mul dx
	shl ax, 1
	mov n, ax
	add di, ax
	mov si, di
	sub di, ax
	
	call matrix_mul
	
	lea si, strresult
		
	call output	
	call file_output
	jmp final
	
err1:
	xor ax, ax
	xor dx, dx
	mov ah, 9
	lea dx, errmsg
	int 21h
	
final:		
	mov ax, 4c00h
	int 21h
  end start 