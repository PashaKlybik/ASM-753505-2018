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
  jle fi
   mov ax, b
 fi:
   cmp ax,c
   jle sec
   mov ax,c
sec:
   cmp ax,d
   jle thi
   mov ax,d
thi:
 int 21h
    mov ax, 4c00h
   
    int 21h
    end main 