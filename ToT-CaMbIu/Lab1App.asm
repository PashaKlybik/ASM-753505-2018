;find the largest of 4 numbers and enter in ax
.model small
.stack 256
.data
a dw -1
b dw -2
c dw -3
d dw 2
.code 
main:
mov ax,@data
mov ds,ax
mov ax, [a]
mov bx, [b]
mov cx, [c]
mov dx, [d]
cmp ax,bx
jl flag1
cmp cx,dx
jl flag2
jmp next

flag1:
mov ax,bx

flag2:
mov cx,dx

next:
cmp ax,cx
jl flag3
jmp next2

flag3:
mov ax,cx

next2:
mov ax, 4c00h
int 21h
end main
