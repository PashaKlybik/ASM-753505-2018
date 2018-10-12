.MODEL SMALL
.STACK 100h

.DATA
	a dw 10
	b dw 11
	c dw 12
	d dw 13
.CODE
START:
    mov ax,@data
	mov ds,ax
	
	mov ax, a		;ax = a
	mov bx, a			;bx = a
	inc bx				;bx = a + 1
	or ax, bx		;ax = a OR (a + 1)
	cmp ax, b
	je first_case
	
	mov ax, a		;ax = a
	and ax, b		;ax = a AND b
	mov bx, c			;bx = c
	or bx, d			;bx = c OR d
	cmp ax, bx
	je second_case
	
	jmp third_case
	
	first_case:	;(ax = a OR (a + 1))	(bx = a + 1)
		mov ax, a	;ax = a
		mul b		;ax = a * b	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		add ax, c	;ax = a * b + c
		div d		;al = (a * b + c) % d ;;;;;;;;;;;;;;;;;;;;;
		jmp finish
	
	second_case:	;(ax = a AND b)		(bx = c OR d)
		mov ax, b	;ax = b
		mov bx, b		;bx = b
		dec bx 			;bx = b - 1
		and ax, bx
		jmp finish
	
	third_case:
		mov ax, c	;ax = c
		div d		;al = c % d ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		cbw			;ax = c % d 
		mov bx, ax		;bx = c % d 
		mov ax, b	;ax = b
		mul a		;ax = b * a ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		add ax, bx
		
    finish:
	mov ah,4ch
    int 21h
END START