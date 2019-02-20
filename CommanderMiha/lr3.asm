.model small
.stack 256
.data
	max_border dw 32767
	min_border dw -32768
	dividendinputmessage db 'enter the dividend:',13,10,'$'
	dividerinputmessage db 'enter the divider:',13,10,'$'
	quotientoutputmessage db 'the quotient is:',13,10,'$'
	remainderoutputmessage db 'the remainder is:',13,10,'$'
	errornulldivisionmessage db 'You cant divide on null. Try again.',13,10,'$'
	errorinvalidinputmessage db 'Wrong input. Expected digit! Try again.',13,10,'$'
	erroroverflowmessage db 'The input number must be in range from -32768 to 32767! Try again.',13,10,'$'

.code
main:

	mov ax, @data
	mov ds, ax

	call clearscreen

dividend:
	lea dx, dividendinputmessage
	call outmessage
	call inpint
	call outpint
	call nextline
	mov bx, ax
divider:
	lea dx, dividerinputmessage
	call outmessage
	call inpint
	cmp ax, 0
	je NullDivision
	call outpint
	call nextline
quotient:
	mov dx, 0
	mov cx, ax
	mov ax, bx
	cwd
	idiv cx
	push dx
	lea	dx, quotientoutputmessage
	call outmessage
	call outpint
	call nextline
remainder:
	pop dx
	mov ax, dx
	lea dx, remainderoutputmessage
	call outmessage
	call outpint
	call nextline
	
exit_main:
	mov ax, 4c00h
	int 21h	

clearscreen proc
	push ax
	
	mov ax, 3
	int 10h
	
	pop ax
	
	ret
clearscreen endp

nextline proc
	push ax
	push dx
	
	mov     ah, 02h
    mov     dl, 0Dh
    int     21h
    mov     dl, 0Ah
    int     21h

	pop dx
	pop ax
	
	ret
nextline endp

outmessage proc
	push ax
	push dx
	
    mov ah, 09h
    int 21h
	
	pop dx
	pop ax
	
	ret
endp outmessage

NullDivision:
	lea dx, errornulldivisionmessage
	call outmessage
	call nextline
	jmp divider

outpint proc    near
        push    cx
        push    dx
        push    bx
        push    ax
        test    ax, ax
; Изменения коснутся только этой части.
; Если число положительное, переходим на вывод плюса.
        jns     short @op0
        mov     ah, 02h
        mov     dl, '-'
        int     21h
        pop     ax
        push    ax
        neg     ax
        jmp     short @op1
@op0:   mov     ah, 02h
        mov     dl, '+'
        int     21h
        pop     ax
        push    ax
; Дальше ничего не менялось.
@op1:   xor     cx, cx
        mov     bx, 10
@op2:   xor     dx, dx
        div     bx
        push    dx
        inc     cx
        test    ax, ax
        jnz     short @op2
        mov     ah, 02h
@op3:   pop     dx
        add     dl, 30h
        int     21h
        loop    @op3
        pop     ax
        pop     bx
        pop     dx
        pop     cx
        ret
outpint endp

inpint  proc    near
        push    cx
        push    dx
        push    bx
        push    si
        xor     si, si
        xor     bx, bx
        xor     cx, cx
@ip:    mov     ah, 01h
        int     21h
; Изменения коснутся только этой части.
; Если первым символом идёт плюс, это ни на что
; не влияет, просто переходим на ввод следующего символа.
        cmp     al, '+'
        je      short @ip0
        cmp     al, '-'
        jne     short @ip1
        inc     si
@ip0:   mov     ah, 01h
        int     21h
@ip1:   cmp     al, 39h
        ja      short @ip2
        sub     al, 30h
        jb      short @ip2
        mov     cl, al
        shl     bx, 1
		jo		overflow
        mov     ax, bx
        shl     ax, 2
		jo		overflow		
        add     bx, ax
		jo		overflow
        add     bx, cx
		jo 		overflow
        jmp     short @ip0
@ip2:   test    si, si
        jz      short @ip3
        neg     bx
@ip3:   mov     ah, 02h
        mov     dl, 0Dh
        int     21h
        mov     dl, 0Ah
        int     21h
        mov     ax, bx
        pop     si
        pop     bx
        pop     dx
        pop     cx
        ret
		
overflow:
		lea dx, erroroverflowmessage
		call outmessage
		call nextline
		xor	ax, ax
		xor bx, bx
		xor cx, cx
		xor si, si
		jmp short @ip
inpint  endp
end main