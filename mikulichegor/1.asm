.model small
 .stack 256
.data
  
  a dw 100
  b dw -93
  c dw -57
  d dw 55
.code
 main:
  
  mov ax, a
  cmp ax, b
  jge first
   mov ax, b
 first:
   cmp ax,c
   jge second
   mov ax,c
second:
   cmp ax,d
   jge third
   mov ax,d
third:
 int 21h
    mov ax, 4c00h
   
    int 21h
    end main 
