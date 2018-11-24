model small; модель памяти
.stack 100h         
.data 


inputstr db 30 dup('$')
buffer db 10 dup('$')
outputstr db 30 dup(' '), '$'

forinputstr db 'Enter your string: ', 13, 10, '$'
foroutputstr db 'Yoyr changed string:$'


.code ;-------------------------------------------начало сегмента кода

OutStr proc

push ax
push dx

lea dx, foroutputstr
mov ah, 09h
int 21h

lea dx, outputstr
mov ah, 09h
int 21h

pop dx
pop ax

ret
OutStr endp

start: ;------------------------------------------start of prog
MOV AX, @data
MOV DS, AX
;-------------------------------------------------


lea dx, forinputstr
mov ah, 09h
int 21h

lea si, inputstr
mov ah, 01h

entering:
	int 21h

	cmp al, 13
	jz endofentering 

	mov [si], al
	inc si
	jmp entering

endofentering:
	lea si, inputstr
	lea di, buffer

	contin:
		mov al, [si]
		cmp al, 32
		jz probel

		mov [di], al

		inc si
		inc di
		jmp contin

	probel:

		inc si

		mov al, [si]
		cmp al, 32
		jz frombuffer


		lea di, outputstr
		mov al, [si]
		mov [di], al

		inc di





		
		jmp probel

frombuffer:
	;push [di]

	;mov ax, di

call outstr
	
			



;--------------------------------------------------end of prog
MOV AH, 4Ch
INT 21h
end start 