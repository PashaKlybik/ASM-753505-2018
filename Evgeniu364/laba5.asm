model small
.stack 100h         
.data 			

u dw 10
strmin db "-$"
rows dw 0
cols dw 0
sum dw 0
array dw 50*50 dup(0)
array2 dw 50*50 dup(0)
array3 dw 50*50 dup(0)
msgerr db 13, 10, "repeat please!$"

msgro db 13, 10, "input count of rows: $"
msgco db 13, 10, "input count of colums: $"
msgel db 13, 10, "input elements: ", 13, 10, "$"
msgsu db 13, 10, "max matrix: ",  13, 10, "$"
msgen db 13, 10, "$"
msgma db 13, 10, "your 1 matrix : ", 13, 10, "$"
msgma2 db 13, 10, "your 2 matrix : ", 13, 10, "$"
msgnewline db 13, 10, "$"

repeat db 13, 10,"repeat please!", 13, 10, '$'
temporary dw 0
unusial dw -32768
currentpos dw ?
isnegative dw ?

.code	

inputusint proc	;ввод в аx 
	
	mov temporary, 0
	entersymbus:
		mov ah, 01h
		int 21h
		xor ah, ah
		cmp ax, 13 ;проверка на энтр
		jz end1us
		cmp ax, 48 ;проверка на 0-9
		jc errorus
		cmp ax, 57
		jz continus
		jnc errorus

	continus:
		sub al, 48
		mov ah, 0
		mov bx, ax
		mov ax, temporary
		mul u
		jc errorus
		add ax, bx
		jc errorus
		mov temporary, ax
		jmp entersymbus

	errorus:
		lea dx, repeat
		mov ah, 09h
		int 21h
		mov ax, 0
		mov temporary, ax
		jmp entersymbus

	end1us:

	ret
inputusint endp

proc inputelements
	mov ax, rows
	mul cols ;v ax kol elementov
	mov cx, ax
	qwe:
		call inputint

		push temporary
		pop ax

		mov ax, temporary
		mov [si], ax
		inc si 
		inc si
	loop qwe

	ret
inputelements endp

inputint proc
	push ax
	push bx
	push cx
	push dx
	
	mov temporary, 0
	mov currentpos, 0
	mov isnegative, 0

	entersymb:
		add currentpos, 1

		mov ah, 01h
		int 21h
		xor ah, ah

		cmp ax, 43
		jz plus

		cmp ax, 45
		jz minus	

	usiallint:
		cmp ax, 13 ;проверка на энтр
		jz end1
		cmp ax, 48 ;проверка на 0-9
		jc error
		cmp ax, 58
		jnc error

	contin:
		sub al, 48
		mov ah, 0
		mov bx, ax
		mov ax, temporary
		mul u
		jc error
		add ax, bx
		jc error
		mov temporary, ax
		jmp entersymb

	plus:
		cmp currentpos, 1
		jz positive
		jmp error

	positive:
		mov isnegative, 0
		jmp entersymb

	minus:
		cmp currentpos, 1
		jz negative
		jmp error

	negative:
		mov isnegative, 1
		jmp entersymb

	error:
		mov currentpos, 0
		mov isnegative, 0
		lea dx, repeat
		mov ah, 09h
		int 21h
		mov ax, 0
		mov temporary, ax
		jmp entersymb

	makeneg:
		neg temporary
		jmp end2

	end1:
		cmp isnegative, 1
		jz makeneg

	end2:
		mov cx, temporary
		cmp cx,unusial
		jz error

	pop dx
	pop cx
	pop bx
	pop ax
	ret
inputint endp

proc outputmass

	mov bx, rows
	push bx
	mov bx, cols
	push bx

	outstr:
		mov ax, [si]
		test ax, 1000000000000000b
		jz next
		lea dx, strmin
		push ax
		mov ah, 09h
		int 21h
		pop ax
		neg ax

	next:
		mov dx, 0
		idiv u
		push dx
		mov dx, 0
		inc cx
		cmp ax, 0
		jnz next

	cycle:
		pop dx
		mov dh, 0
		add dl, 48
		mov ah, 02h
		int 21h
		loop cycle

		inc si
		inc si
		pop bx
		dec bx
		cmp bx, 0
		jz zero
		push bx
		mov dl, 9
		mov ah, 2

		int 21h
		jmp outstr

	zero:
		pop bx
		dec bx
		cmp bx, 0
		jz zero2
		push bx
		mov bx, cols
		push bx
		lea dx, msgen
		mov ah, 09h
		int 21h
		jmp outstr

	zero2:

	ret
outputmass endp

main:
	mov ax, @data
	mov ds, ax

	lea dx, msgco
	mov ah, 09h
	int 21h
	call inputusint
	push temporary
	pop cols

	lea dx, msgro
	mov ah, 09h
	int 21h
	call inputusint
	push temporary
	pop rows

	lea dx, msgel
	mov ah, 09h
	int 21h

	lea si, array
	call inputelements

	lea dx, msgel
	mov ah, 09h
	int 21h

	lea si, array2
	call inputelements

	mov ax, rows
	mul cols ;v ax kol elementov
	mov cx, ax

	mov si, offset array
	mov di, offset array2

	cycle54:
		mov ax, [si]
		cmp ax, 32767
		jc p1
		jmp n1

		n1:
			mov ax, [di]
			cmp ax, 32767
			jc n1p2
			jmp n1n2
	
		n1p2:
			jmp add2

		n1n2:
			mov ax, [si]
			cmp ax, [di]
			jc add2
			jmp add1


		p1:
			mov ax, [di]
			cmp ax, 32767
			jc p1p2
			jmp p1n2
		
		p1p2:
			mov ax, [si]
			cmp ax, [di]
			jc add2
			jmp add1

		p1n2:
			jmp add1
		
		add1:
			push [si]
			jmp asd

		add2:
			push [di]
			jmp asd
		
		asd:	
			inc si
			inc si
			inc di
			inc di

	loop cycle54

	mov ax, rows
	mul cols ;v ax kol elementov
	mov cx, ax
	dec cx

	lea di, array3
	cycle228:
		inc di
		inc di
	loop cycle228;чтобы di указывал на ласт элемент цепочки

	mov ax, rows
	mul cols ;v ax kol elementov
	mov cx, ax

	cyclen:
		pop [di]
		dec di 
		dec di
	loop cyclen

	lea dx, msgma
	mov ah, 09h
	int 21h
	lea si, array
	call outputmass

	lea dx, msgma2
	mov ah, 09h
	int 21h
	lea si, array2
	call outputmass

	lea dx, msgsu
	mov ah, 09h
	int 21h
	lea si, array3
	call outputmass

	lea dx, msgnewline 
	mov ah, 09h
	int 21h

	mov ah, 4ch
	int 21h
end main
