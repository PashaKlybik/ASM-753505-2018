.model small
.stack 256
.data
    a dw 4
    b dw 65
    c dw 2 
    d dw 1
.code
main:
mov ax, @data
mov ds, ax

mov ax, [a]
mul ax 
mul ax 
mov cx, ax
mov ax, [b]
mul ax 
mov bx, ax 
cmp cx, bx 
jc label1 

mov ax, [c] 
mov dx, [d] 
mul dx
mov bx, ax 
mov ax, [a] 
mov cx, [b]
div cx 
mov dx, ax 
cmp bx, dx
jz label2
    
mov ax, [c]
jmp labelfinish

label2: 
mov ax, [a] 
mov cx, [b] 
and ax, cx 
jmp labelfinish

label1:
mov ax, [c] 
mov dx,[d] 
mul dx 
add ax,[b] 
jmp labelfinish

labelfinish:
mov ax, 4c00h
int 21h
end main