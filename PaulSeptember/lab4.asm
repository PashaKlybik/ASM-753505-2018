.model small
.stack 100h
.data
	buffer db 255,0,256 dup (?)
	endline db 13,10,'$'
	spaces db '?! ,.'
.code

printString proc
    push ax
    mov ah,09h
    int 21h 
    pop ax
    ret
printString endp


printSymbol proc
    push ax
    mov ah,02h
    int 21h 
    pop ax
    ret
printSymbol endp


endl proc
    push dx
    lea dx,endline
    call printString
    pop dx
    ret
endl endp


isSpace proc
	push di
	push cx
	lea di,spaces
	mov cx,5
	repne scasb
	pop cx
	pop di
	ret
isSpace endp


find proc 
	push ax
	xor ax,ax
	mov di,offset buffer	
	add di,2
	mov si,di

	loopRight:
		cmp byte ptr[si],'$'
		je exit	
		mov al,byte ptr[si]
		call isSpace		
		je endOfWord

		inc si
	jmp loopRight

	endOfWord:
		push si
		push di
		cmp si,di
		je printSpace
		dec si
		wordCheck:
			;jmp nePalindrom   ;Just crutch
			sub si,di
			cmp si,1
			jb palindrom
			add si,di
			mov dl,byte ptr [si]
			mov dh,byte ptr [di]
			cmp dl,dh
			jne nePalindrom
			inc di
			dec si
		jmp wordCheck	

		palindrom:
			pop di
			pop si
			mov cx,si
			sub cx,di
			mov al,byte ptr[di]
			call printWord
			mov di,si
		jmp loopRight
			
		nePalindrom:
			pop di
			pop si
		again:	
			mov di,si
		jmp loopRight

		printSpace:
			pop di
			pop si
			mov dl,byte ptr[di]
			call printSymbol
			inc si
			inc di
		jmp loopRight
	exit:
	pop ax
	ret
find endp


stringInput proc 
    push ax
    push di
    push dx
    lea dx,buffer
    mov ah, 0Ah
    int 21h
    lea di,buffer
    xor ch,ch
    mov cl,buffer[1]
    add di,cx
    add di,2
    mov byte ptr [di],' '
    inc di
    mov byte ptr [di],'$'
    pop dx
    pop di
    pop ax
    ret
stringInput endp


printWord proc
        push ax
        push cx
        push dx
	push si
        sub si, cx
        mov ah, 02h
        output_loop:
            mov dl, byte ptr [si]
            int 21h
            inc si
        loop output_loop 
	pop si     
        pop dx
        pop cx
        pop ax
        ret
printWord endp


start:
	mov ax,@data
	mov ds,ax
	mov es,ax
	call stringInput
	call endl
	call find

	mov ax,4c00h
	int 21h
end start