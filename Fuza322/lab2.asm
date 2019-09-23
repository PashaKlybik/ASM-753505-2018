.model small
.stack 256
.data
	errorMessage db 'ERROR!','$'	
.code

main proc
   mov ax,@data
   mov ds,ax
call INPUT
mov  bx,ax
call INPUT
cmp  ax,0
jne  NEXT
lea  dx, errorMessage
mov  ah,09h
int 21h
mov ax, 4C00h
int 21h

NEXT:
xor  dx,dx
xchg ax,bx
div  bx
call OUTPUT
call NewLine
mov  ax,dx
call OUTPUT
mov ax, 4C00h
int 21h
main endp

OUTPUT proc
	push ax
 	push bx
 	push cx
 	push dx
 	xor  cx,cx
 	mov bx,10
 	
 	InToTheStack:
 		cmp ax, 10 
 		jc EXIT
 		xor dx,dx
 		div bx
 		push dx
 		inc cx
 	jmp InToTheStack
 	EXIT:		
 		push ax
 		inc cx
 	
 	FromTheStack:		
 		pop dx
 		add dx, '0'
 		mov ah, 02h
 		int 21h
 	loop FromTheStack
 	pop dx
 	pop cx
 	pop bx
 	pop ax
	ret
OUTPUT endp


INPUT proc
 	push bx
 	push cx
 	push dx
 	xor  ax,ax
 	xor  bx,bx
 	xor  cx,cx
 	xor  dx,dx
  	WriteSymbol:
 		mov ah, 01h
 		int 21h		
		cmp al, 8
 		jz BackspaceClick
 		cmp al, 13
 		jz FinishInput
 		cmp al, '0'
        	jb ERROR
        	cmp al, '9'
        	ja ERROR
		sub al, '0'
		
 		mov cl, al
 		mov ax, 10
 		mul bx
 		jc ERROR
 		mov bx,ax
 		add bx, cx
 		jc ERROR
	jmp WriteSymbol
 	
 	ERROR:
 	call NewLine
 	lea dx, errorMessage
     	mov ah, 09h
   	int 21h
 	mov ax, 4c00h
    	int 21h
  	BackspaceClick:
		push ax
 		push dx
 	
 		mov dl, ' '
 		mov ah, 02h
 		int 21h
 		
 		mov dl, 8
 		mov ah, 02h
 		int 21h
 		
 		mov ax, bx
 		cmp ax, 10
 		jnc Continue
		
		xor bx,bx
 		pop dx
 		pop ax
 		jmp WriteSymbol
	
 	Continue:	
 		xor dx,dx
 		mov bx, 10
 		div bx
 		mov bx, ax
 		
 		pop dx
 		pop ax
     	jmp  WriteSymbol
 				
 	FinishInput:
 		mov ax, bx
 		pop dx
 		pop cx
 		pop bx
		ret
INPUT endp

NewLine proc
	push ax
	push dx
 	mov ah, 02h
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h
  	pop dx
	pop ax
	ret
NewLine endp

end main
