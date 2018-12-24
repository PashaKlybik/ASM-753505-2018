.model small
.386
.stack 256
.data
a dw 3
b dw 2
c dw 33
d dw 3
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
 je Yes 
 jmp No 
  Yes:
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
jmp fin
  No: 
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
   je Yes2
   jmp No2
  Yes2:
   mov ax, [c]
   add ax, [b] 
   xor ax, [a]
   jmp fin
  No2: 
   mov ax, [b]
   shr ax, 3
fin:
mov ax, 4c00h
int 21h
end main