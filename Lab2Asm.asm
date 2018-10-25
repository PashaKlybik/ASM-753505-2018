.model small
.stack 100h
.data
	ten dw 10
	errorMessage db 'ERROR!','$'
	result      db      'Result', '$'
	residual    db      'Residual', '$'
.code

main proc
mov ax,@data
mov ds,ax

call input
mov  bx,ax
call input
xor  dx,dx
xchg ax,bx

div  bx
call show_ax
call endl
mov  ax,dx

call show_ax

mov     ax,     4C00h
int     21h
main endp

Show_AX proc
	push ax
 	push bx
 	push cx
 	push dx
 	mov cx, 0
 	mov bx,10
 	
 	;output with the help of stack
 	toStack:
 		cmp ax, 10 
 		jc exit
 		xor dx,dx
 		div bx
 		push dx
 		inc cx
 	jmp toStack
 	exit:		
 		push ax
 		inc cx
 	
 	;output digits from stack 	
 	fromStack:		
 		pop dx
 		add dx, '0'
 		mov ah, 02h
 		int 21h
 	loop fromStack
 	
 	pop dx
 	pop cx
 	pop bx
 	pop ax
ret
Show_AX endp

endl proc
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
endl endp

input proc
 	push bx
 	push cx
 	push dx
 	mov ax, 0
 	mov bx, 0
 	mov cx, 0
 	mov dx, 0

 	symbolEntry:
 		mov ah, 01h
 		int 21h		
		cmp al, 8
 		jz backspace
 		cmp al, 13
 		jz exitInput

		cmp     al, '0'
        	jb      error
        	cmp     al, '9'
        	ja      error
		sub al, '0'
		
 		mov cl, al
 		mov ax, 10
 		mul bx
 		jc error ;overflow
 		mov bx,ax
 		add bx, cx
 		jc error
	jmp symbolEntry
 	
 	error:
 	call endl
 	lea dx, errorMessage
     	mov ah, 09h
   	int 21h
 	mov ax, 4c00h
    	int 21h

 	backspace:
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
 		jnc continue
	
	;delete last digit
 	continue:	
 		mov dx, 0
 		mov bx, 10
 		div bx
 		mov bx, ax
 		
 		pop dx
 		pop ax
     	jmp  symbolEntry
 				
 	exitInput:
 		mov ax, bx
 		pop dx
 		pop cx
 		pop bx
ret
input endp
end main