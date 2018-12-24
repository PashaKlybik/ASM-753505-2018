.MODEL SMALL 
.STACK 100h 

.DATA 
a dw 5
b dw 4 
c dw 4 
d Dw 10 

.CODE 
START:
	 
mov ax,@data 
mov ds,ax 

mov ax, a 
dec AX 
AND Ax, a 
cmp ax, b 		; 1 if(a & a - 1 == b) 
JE a1 		 
JNE a2
 			 
a1: 			   
MOV ax, c 		 
ADD ax, b 		 
cmp d, AX 		; 2 if (d > (c + b)) 
JA b1 		 
JBE b2 		
 
b1: 			 
mov ax, c 
mov bx, c 
DIV d 
add ax, dx
jmp END 

a2: 			 
MOV ax, c 
XOR ax, d
jmp END

b2: 
mov bx, b 
INC bx 
mov ax, b 
OR ax, bx 

END:
mov ax, 4c00h
int 21h
END START