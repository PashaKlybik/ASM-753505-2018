.MODEL small
.stack 100h
.DATA
aa dw 3
bb dw 4
cc dw 2
dd dw 5

a dw ?
b dw ?
c dw ?
d dw ?
 
 
.CODE
 
start: 
mov ax, @data
mov ds, ax

mov ax,[aa]
mul [bb]
mov [a],ax

mov ax,[bb]
mul [cc]
mov [b],ax

mov ax,[cc]
mul [dd]
mov [c],ax

mov ax,[dd]
mul [aa]
mov [d],ax

mov ax,[a]
cmp ax,[b]
jnl sr1

mov ax,[b]
cmp ax,[c]
jnl sr2

mov ax,[c]
cmp ax,[d]
jnl exit

mov ax,[d]
jmp exit

sr1:
cmp ax,[c]
jnl sr3
mov ax,[c]
cmp ax,[d]
jnl exit
mov ax,[d]
jmp exit

sr2:
cmp ax,[d]
jnl exit
mov ax,[d]
jmp exit

sr3:
cmp ax,[d]
jnl exit
mov ax,[d]
jmp exit



exit:


mov ah, 04Ch
int 21h 
 
END start
