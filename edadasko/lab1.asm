.model small
.stack 256
.data
	a dw 6
	b dw 3
	c dw 2
	d dw 4
.code

;1 var 
;if (a ^ 3 > b ^ 2)
  ;if( c * d = a / b)
        ;AX = a AND b
   ;else
        ;AX = c
;else
    ;AX = с * d + b
		
main:
	mov ax, @data
	mov ds, ax
    
	mov ax, a 
	mov bx, a 
	mul bx 
	mul bx 
	mov cx, ax ; cx = a ^ 3
	mov ax, b 
	mov bx, b 
	mul bx ; ax = b ^ 2
	cmp cx, ax ; cx > ax -> CF = 0; ZF = 0
	
	JBE else1 ; JBE -> CF == 1 || ZF == 1	

	mov ax, c
	mov bx, d
	mul bx
	mov cx, ax ; cx = c * d
	
	mov ax, a
	mov bx, b 
	div bx   ; ax = a / b
	
	cmp ax, cx
	JNZ else2 ; JNZ -> ZF == 0
	
	mov ax, a
	AND ax, bx ; ax = a AND b
	JMP exit 

	else1:
	mov ax, c
	mov bx, d
	mul bx
	add ax, b ; ax = с * d + b
	JMP exit 
	
	else2:
	mov ax, c ; ax = c

	exit:
	mov ax, 4c00h
	int 21h
	
end main