.model small
.386
.stack 256
.data
a dw 13
b dw 21
c dw 45
d dw 17
.code
main:
  mov ax, @data
  mov ds, ax
 mov bx, [a]
 and bx, [b] 
 mov cx, [c]
 mov ax, [c]
 mul cx
 mul cx
 mul cx 
 cmp bx, ax
 je If1 
 jmp Else1 
  If1:
   mov ax, [c]
   mov bx, [d]
   mov dx,0
   div bx 
   xor ah, ah 
   mov bx, [b]
   mov dx,0
   div bx 
   xor ah, ah 
   add ax, [a]
jmp exit
   Else1: 
   mov cx, [c]
   add cx, [b]
   mov ax, [a] 
   mov si, ax
   mul si 
   mul si 
   mov si, ax
   mov ax, [b]
   mov bx, [b] 
   mul bx 
   mul bx 
   add si, ax
   cmp cx, si 
   je If2
   jmp Else2
  If2:
   mov ax, [c]
   add ax, [b] 
   xor ax, [a]
   jmp exit
  Else2: 
   mov ax, [b]
   shr ax, 3
exit:
mov ax, 4c00h
int 21h
end main