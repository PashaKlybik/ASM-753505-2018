.model small
.stack 256
.data
    a dw 3
    b dw 13
    c dw 14
    d dw 17
.code
main:
	mov ax, @data
	mov ds, ax
    
	mov ax, [a]
	mov bx, [a]
	mul bx
	mul bx
	mov cx, ax  ; 1chast
	mov ax, [b]
	mov bx, [b]
	mul bx	

	cmp cx, ax
	jg Yes
	jmp No
	 Yes:
	  mov ax, [c]
	  mov bx, [d]
	  mul bx
	  mov cx, ax
	  mov ax, [a]
	  mov bx, [b]
	  mov dx, 0
	  div bx
	  ;xor ah, ah
	  cmp cx, ax
	  je Yes1
	  jmp No1

	  Yes1:
	   mov ax, [a]
	   mov bx, [b]
	   and ax, bx
	   jmp fin
	

	  No1:
	   mov ax, [c]
	   jmp fin 
	
	  
	 No:
	  mov ax, [c]
	  mov bx, [d]
	  mul bx
	  add ax, [b]
	  jmp fin
         
  	fin:
	mov ax, 4c00h
	int 21h
	end main