.model small
.stack 100h
.data
Message db 'Hello world - string to check!!!$'
.code
Start:
	mov ax, @DATA
	mov ds, ax
	
	mov ah, 09h
	mov dx, offset Message 
	int 21h
		
	mov ah, 07h
	int 21h

	MOV ax, 4C00h
	INT 21h
end Start