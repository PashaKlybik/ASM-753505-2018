model small
.stack 256
.data
    ;for files
    mesNotFountFile db "File hasn't been found", 10, '$'
    mesReadException db "Read file exception", 10, '$'
    mesCloseException db "Close file exception", 10, '$'
    mesCreateException db "Create/rewrite file exception", 10, '$'
	manyNumbers db "Exception. Too many numbers", 10, '$'
	notNumber db "Error parse to int", 10, '$'
	mesDiscordancyElementCount db "Count element discord sizes", 10, '$'
    mesWriteException db "Write file exception", 10, '$'
    mesErrorInputNegative db "ERROR. Size of matrix must be positive", 13, 10, '$'
    mesErrorSize db "ERROR. Size of matrix must be <= 100", 13, 10, '$'
    mesIncorrectValue db "ERROR. Incorrect value", 10, '$'
    
    outputFile db "output.txt", 0
    inputFile db "input.txt", 0
    newline db 13, 10, '$'
    
    outBuffer db 1000 dup ('$')
	outBufferSize dw 0
    maxBufferSize dw 1000
    bufferSize dw (?)
    buffer db 1002 dup (?)
    M dw 0
    N dw 0
    maxArraySize dw 100
    arraySize dw 0
    array dw 100 dup ('$$')
    
    ;for input/outputInteger integers
    minus dw ?
    number dw ? ; push pop slower
	firstDigit db 0
    maxPositive dw 32767
    maxNegative dw 32768
    ten dw 10
.code

readBuffer proc
	mov ax, 3D00h	;открытие
	lea dx, inputFile
	int 21h
	jc OpenFileError
	
	mov bx, ax		;чтение в буфер. bx определитель файла, dx указатель на буфер
	mov cx, maxBufferSize
	lea dx, buffer
	mov ah, 3Fh
	int 21h
	jc ReadError
	
	mov BufferSize, ax
	push bx
	lea bx, buffer
	add bx, ax
	mov byte ptr[bx], '$'
	pop bx
	
	mov ah, 3Eh
	int 21h
	jnc readBufferExit
	lea dx, mesCloseException
	mov ah, 09h
	int 21h
	jmp readBufferExit
	
	ReadError:
		mov ah, 09h
		lea dx, mesReadException
		int 21h
		jmp readBufferExit
		
	OpenFileError:
		mov ah, 09h
		lea dx, mesNotFountFile
		int 21h
		
	readBufferExit:
		
	ret
readBuffer endp

ReadIntFromBuffer proc ;чтение по адресу si в bh количество считанных байт, в ax число
	push cx
	push dx
	xor cx, cx
	xor bx, bx ; ;--bh - длина считанной строки, bl - флаг знака минуса
	mov firstDigit, 0
	nextChar:
		lodsb 
		cmp al, '$'
		jz endLoop
		cmp firstDigit, 0
		jnz SeparatorNotAllowed
			cmp al, 10
			jz nextChar
			cmp al, 13
			jz nextChar
			cmp al, 20h
			jz NextChar
		SeparatorNotAllowed:
			cmp al, 10
			jz endLoop
			cmp al, 13
			jz endLoop
			cmp al, 20h
			jz endLoop
		
		mov firstDigit, 1
		inc bh
		cmp al, '-'
		jnz checkDigit
			cmp bh, 1
			jnz ParseIntError
				mov bl, 1
				jmp nextChar
		checkDigit:
			sub al, '0'
			cmp al, 10
			jb addDigit
				jmp ParseIntError
		
		addDigit:
			push cx
			push ax
			
			mov ax, 10
			xor dx, dx
			mul cx
			
			jnc notOverflow1
				pop ax
				pop cx
				jmp ParseIntError
				
		notOverflow1:
			mov dx, 8000h
			add dl, bl
			cmp dx, ax
			ja NotOverflow2
				pop ax
				pop cx
				jmp ParseIntError
		notOverflow2:
			mov cx, ax
			pop ax
			add cl, al
			adc ch, 0
			cmp dx, cx
			ja notOverflow3
				pop cx
				jmp ParseIntError
		notOverflow3:
			pop dx
	jmp nextChar
	
	ParseIntError:
		mov ah, 09h
		mov dx, offset notNumber
		int 21h
		jmp exit
	
	endLoop:	
	
	test bl, 1
	jz fill_ax
		cmp bh, 1
		jz ParseIntError
		neg cx
	fill_ax:
	mov ax, cx
	mov bl, bh
	xor bh, bh
	dec si
	
	pop dx
	pop cx
	ret
ReadIntFromBuffer endp

ParseInts proc
	push ax
	push bx
	push si
	push di
	lea si, buffer
	mov di, 0
	xor bx, bx
	again:
		call ReadIntFromBuffer
		cmp bx, 0
		jz FinishParse
		mov array[di], ax
		lea di, [di + 2]
		cmp di, MaxArraySize
	jna again
	
	ParseError:
		mov ah, 09h
		mov dx, offset manyNumbers
		int 21h
		jmp exit
		
	FinishParse:
		shr di, 1
		mov arraySize, di
	pop di
	pop si
	pop bx
	pop ax
	ret
ParseInts endp

GetSizes proc
	mov ax, word ptr array[0]
	cmp word ptr array[0], 0
	jng nonPositiveSize
	cmp word ptr array[2], 0
	jng nonPositiveSize
	jmp FillSize
	nonPositiveSize:
		mov ah, 09h
		mov dx, offset mesErrorInputNegative
		int 21h
		jmp exit
	FillSize:
		mov ax, word ptr array[0]
		mov N, ax
		mov ax, word ptr array[2]
		mov M, ax
		
		;проверка на совпадение количества чисел
		mov ax, N
		mul M
		add ax, 2
		cmp ax, arraySize
		jz skip
			mov ah, 09h
			mov dx, offset mesDiscordancyElementCount
			int 21h
			jmp exit
	skip:
	ret
GetSizes endp

ShiftRow proc
	push ax
	push bx
	push cx
	push si
	mov bx, si
	add si, M
	add si, M
	sub si, 2
	mov cx, M
	dec cx
	change:
		push word ptr[bx]
		mov ax, word ptr [si]
		mov word ptr [bx], ax
		pop word ptr[si]
		sub si, 2
	loop change
	pop si
	pop cx
	pop bx
	pop ax
	ret
ShiftRow endp

MatrixTransform proc
	lea si, [array + 4]
	add si, M
	add si, M
	mov cx, 1 ; номер строки
	cmp cx, N
	nextRow:
		cmp cx, N
		jae MatrixTransformExit
		
		push cx
		shift:
			call ShiftRow
		loop shift
		pop cx
	
		inc cx
		add si, M ;перевод указателя на новую строку
		add si, M ;
		cmp cx, N
	jmp nextRow
	MatrixTransformExit:
	ret
MatrixTransform endp

printInt proc
	push ax
	push bx
	push cx
	push dx

	xor cx, cx
	mov bx, 10
	
	cmp ax, 0
	jns s_get_digit
		push ax
		mov al, '-'
		stosb
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
	
s_out_digit:
		pop ax
		add al, '0'
		stosb
	loop s_out_digit
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
printInt endp

printMatrixInBuffer proc
	mov cx, N
	lea si, [array + 4]
	mov ax, [si]
	mov di, offset outBuffer
	cld
	newRow:
		push cx
			mov cx, M
			newColumn:
				mov ax, word ptr [si]
				add si, 2
				call printInt
				mov al, ' '
				stosb
			loop newColumn
		pop cx
		mov al, 13
		stosb
		mov al, 10
		stosb
	loop newRow
	sub di, offset outBuffer
	mov outBufferSize, di
	ret
printMatrixInBuffer endp

WriteBuffer proc
	mov ah, 3Ch
	lea dx, outputFile
	xor cx, cx
	int 21h
	jc createFileException
	
	mov bx, ax
	mov ah, 40h
	mov cx, outBufferSize
	mov dx, offset outBuffer
	int 21h
	
	cmp ax, cx
	jnz writeFileException
	
	mov ah, 3Eh
	int 21h
	jnc fileWriteExit
	lea dx, mesCloseException
	mov ah, 09h
	int 21h
	jmp exit
	
	writeFileException:
		mov ah, 09h
		lea dx, mesWriteException
		int 21h
		jmp exit
	createFileException:
		mov ah, 09h
		lea dx, mesCreateException
		int 21h
		jmp exit
	fileWriteExit:
	ret
WriteBuffer endp
    
main:
    mov ax, @data
    mov ds, ax
	mov es, ax
    
    call ReadBuffer
	
	;mov ah, 09h
	;mov dx, offset buffer
	;int 21h
	
	call ParseInts
	
	call GetSizes
	
	call MatrixTransform
	
	call printMatrixInBuffer
	
	;mov ah, 09h
	;mov dx, offset outBuffer
	;int 21h
	
	call WriteBuffer
	
exit:
    mov ax, 4c00h
    int 21h
end main
