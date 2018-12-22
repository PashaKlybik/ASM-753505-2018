

.model small
.stack 100h

.data 
a dw 8
b dw 4
c dw 6
d dw 2

.code

start:

    mov ax, @DATA
    mov ds, ax
    
    mov ax,a 
    mul c
    mov bx,ax
    xor ax,ax

    mov ax,b
    mul d
    mov dx,ax
    xor ax,ax

    add bx,dx
    xor dx,dx

    mov ax,a
    mul d
    mov cx,ax
    xor ax,ax

    mov ax,b
    mul c
    mov dx,ax
    xor ax,ax

    add dx,cx
    xor cx,cx

    cmp bx,dx
    je func1

    xor bx,bx
    xor dx,dx

    mov bx,a
    mov cx,c
    cmp bx,cx
    jg func2

    mov ax,a
    mov bx,b
    mox dx,c

    or bx,dx
    sub ax,bx

    jmp finish

func1:
    
    mov ax,a
    mul a
    
    jmp finish

func2:

    xor bx,bx
    mov bx, d
    and cx,bx
    mov ax,cx
    
    jmp finish

finish:

    xor bx,bx
    xor cx,cx
    xor dx,dx

    mov ah, 04ch
    int 21h

    end start
