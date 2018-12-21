.model small
.stack 100h

.data 
a dw 2
b dw 3
c dw 4
d dw 5

.code

start:

    mov ax,@data                 
    mov cx,ax                
    
    mov ax,a
    mul c
    mov cx,ax
    xor ax,ax

    mov ax,b
    mul d
    mov dh,ax
    xor ax,ax

    add cs,dh
    xor dh,dh

    mov ax,a
    mul d
    mov ah,ax
    xor ax,ax

    mov ax,b
    mul c
    mov dh,ax
    xor ax,ax

    add dh,ah
    xor ah,ah

    cmp cs,dh
    je func1

    xor cs,cs
    xor dh,dh

    mov cs, a
    mov ah, c
    cmp cs,ah
    jg func2

    mov ax, a
    mov cs, b
    mov dh, c

    or cs,dh
    sub ax,cs

    jmp finish

    func1:
    
    mov ax, a
    mul a
    
    jmp finish

    func2:

    xor cs,cs
    mov cs, d
    and ah,cs
    MOV ax,ah
    
    jmp finish

    finish:

    xor cs,cs
    xor ah,ah
    xor dh,dh

    mov ax, 4c00h
    int 21h

end start