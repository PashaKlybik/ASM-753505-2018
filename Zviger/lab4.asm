.model small
.stack 100h
.data
bufferSize db 100
stringSize db 1
string db 100 dup ('$')
newLine db 10, 13, '$'
.code
printNewLine proc
	push AX
	push DX
	lea DX, newLine
	mov AH,09h
	int 21h
	pop DX
	pop AX
	ret
printNewLine endp
removeDuplicateCharacters proc
	push AX
	push SI
	push CX
	push DI

	mov AH, 0
	lea SI, string
	mov AL, stringSize
	add SI, AX
	mov AL, 24h
	mov [SI],  AL

	mov CX, 0
	lea SI, string 
	CLD
	nextSymbol:
		LODSB

		cmp AL, 24h
		je exit

		mov DI, SI
		scan:

		mov CH, 0
		mov CL, stringSize
		sub CX, DI
		add CX, 2

		cmp CX, 0
		je nextSymbol

		repne	SCASB
		je found

		jmp nextSymbol

		found:

		push SI
		push DI
		mov SI, DI
		dec DI
		inc CX
		rep MOVSB

		pop DI
		pop SI
		dec stringSize
		dec DI

		jmp scan

	exit:
	pop DI
	pop CX
	pop SI
	pop AX
	ret
removeDuplicateCharacters endp
main:
	mov AX, @data
    mov DS, ax
	mov     es,ax

	mov ah, 0Ah
	lea dx, bufferSize
	int 21h

	call printNewLine

	call removeDuplicateCharacters
	lea DX, string
	mov AH, 09h
	int 21h	

	call printNewLine

	MOV AX, 4c00h
	INT 21h

end main