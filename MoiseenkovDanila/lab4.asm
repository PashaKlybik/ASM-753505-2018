model small
stack 256

.data
	source db 254, 254 dup (0)
	sourceLength db 0
	vowels db 'aeiouy'
	vowelsLength db 6
	spaces db ' ,.!?:;'
	spacesLength db 7
	welcome db 'Input text:', '$'
	message db 'Words with two consecutive vowels:', '$'
.code
println proc
	push ax
	push dx
	mov ah, 02h
	mov dl, 10
	int 21h
	pop dx
	pop ax
	ret
println endp

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

isVowel proc
	push cx
	push di
	mov di, offset vowels
	
	xor cx, cx
	mov cl, vowelsLength
	mov ah, 0
	cld
	repnz scasb
	
	jnz isVowelexit
		mov ah, 1
	isVowelExit:
	pop di
	pop cx
	
	ret
isVowel endp

isSpace proc
	push cx
	push di
	mov di, offset spaces
	
	xor cx, cx
	mov cl, spacesLength
	mov ah, 0
	cld
	repnz scasb
	
	jnz isSpaceExit
		mov ah, 1
	isSpaceExit:
	pop di
	pop cx
	
	ret
isSpace endp

printWord proc
	push si
	push ax
	push cx
	
	mov ah, 02h
	printNextChar:
		lodsb
		mov dl, al
		int 21h
	loop printNextChar
	
	pop cx
	pop ax
	pop si
	ret
printWord endp

printWordsWithTwoVowels proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	xor bx, bx ; bl длина текущего слова, bh количество глассных подряд dh == 1, значит слово надо выводить
	xor dx, dx

	xor cx, cx
	mov cl, sourceLength
	lea si, source
	cld
	next_char:
		lodsb ; в al текущий символ, в si указатель на следующий
		call isSpace
		cmp ah, 1
		
		jz space
		char:
			inc bl
			
			call isVowel
			cmp ah, 1
			jnz notVowel
				inc bh
				cmp bh, 2
				jnz skip1
					mov dh, 1
				skip1:
				jmp end_loop
			notVowel:
				xor bh, bh
			jmp end_loop
		space:
			cmp dh, 1
			jb skip2
				push si
				push cx
					xor cx, cx
					mov cl, bl
					mov bx, cx
					dec si
					sub si, bx
					call printWord
					call println
				pop cx
				pop si
			skip2:
				xor bx, bx
				xor dx, dx
		end_loop:
	loop next_char
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
printWordsWithTwoVowels endp

readString proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ah, 0ah
	lea dx, source
	int 21h

	xor bx, bx
	mov bl, [source + 1] ;bl длина строки
	lea di, [source + bx]
	lea di, [di + 2]
	
	mov al, ' '
	mov [di], al
	
	inc bx
	
	mov cx, bx
	lea di, [source]
	lea si, [source + 2]
	cld
	
	rep movsb
	
	mov sourceLength, bl
	
	call println
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
readString endp

printString proc
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
printString endp


main:
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	mov dx, offset welcome
	call printString
	call println
	
	call readString
	
	call println
	
	mov dx, offset message
	call printString
	call println
	
	call printWordsWithTwoVowels
	
	end_main:
	mov ax, 4c00h
	int 21h
end main