;if(a^3>b^2)
;  {if(c*3=a/b)
;    ax=a AND b
;   else ax=c}
;else ax=c*d+b

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
	mov cx, ax  
	mov ax, [b]
	mov bx, [b]
	mul bx	

	cmp cx, ax     ;if(a^3>b^2)
	jg Yes         ;if(c*3=a/b)
	jmp No         ;else ax=c*d+b
	 Yes:          
	  mov ax, [c]
	  mov bx, [d]
	  mul bx
	  mov cx, ax
	  mov ax, [a]
	  mov bx, [b]
	  mov dx, 0
	  div bx
	  cmp cx, ax    ;if(c*3=a/b)
	  je Yes1       ;ax=a AND b
	  jmp No1       ;else ax=c

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