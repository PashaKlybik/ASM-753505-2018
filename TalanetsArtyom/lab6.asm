	.model tiny
	.code
	org 100h
		
	Start: 	
	JMP installation 

	resident proc 		;DS:DX = адрес строки, заканчивающейся символом '$'
					
		cmp ah, 09h
		je next
		jmp dword ptr cs:[int21Vector]	;переходит по адресу cs:int21Vector, где хранится оригинальное 21 прерывание
		jmp endres
		next:
		lea di,newString		;адрес новой (индекс текущего)
		mov bx,dx						;помещаем в BX адрес первого элемента строки
		dec bx
		_loop:
		inc bx
		mov dl, [bx]
		
		cmp dl, '$'
		je endres
		cmp dl, 'e'
		je _loop
		cmp dl, 'y'
		je _loop
		cmp dl, 'u'
		je _loop
		cmp dl, 'i'
		je _loop
		cmp dl, 'o'
		je _loop
		cmp dl, 'a'
		je _loop
				
		mov [di], dl
		inc di
		
		jmp _loop
		
		endres:	
		mov [di], dl
		mov ah, 09h
		lea dx, newString
		jmp dword ptr cs:[int21Vector]	
		iret						
	resident endp 

		int21Vector dd ?     		; хранится адрес родного обработчика
		newString db 255 dup ('$')
		
	installation: 
		;скопировать адрес предыдущего обработчика в переменную int21Vector
		mov ah, 35h			;AH = 35h, функция DOS: считать адрес обработчика прерывания
		mov al, 21h        	;AL = номер прерывания
		int 21h             ;35 функция 21 прерывания - считать адрес обработчика прерывания	
		mov word ptr int21Vector, bx     ; BX - адрес старого обработчика прерывания
		mov word ptr int21Vector + 2, es ; ES - сегментный адрес старого обработчика прерывания
										 
		;установить новый обработчик
		mov ah, 25h					;AH = 25h, функция DOS : установить обработчик 
		mov al, 21h        			;AL = номер прерывания
		mov dx, offset resident		;DS:DX - адрес нового обработчика
		int 21h     		        ;25 функция 21 прерывания - установить обработчик  

		;оставить программу резидентной 
		mov dx, offset installation ; DX - адрес первого байта за резидентным участком программы 
									;(DX интерпретируется как смещение от PSP (DS/ES при запуске)
		int 27h             ;оставить программу резидентной 

	end Start
