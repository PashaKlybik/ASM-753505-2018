;Найти максимум между a, b, c, d и отнять от него минимум между этими числами.
.model small
.stack 256
.data
    a dw 20
    b dw 10
    c dw 10
    d dw 2
    max dw ?
    min dw ?
.code
main:
    mov ax, @data
    mov ds, ax   
    mov ax, a
    cmp ax, b
    jnc if0
    jc else1
    if0:
        mov max, ax
        mov ax, b
        mov min, ax
        jmp next1
    else1:
        mov ax, b
        mov max, ax
        mov ax, a
        mov min, ax
    next1:
        mov ax, max
        cmp ax, c
        jnc if01
        jc else2
    if01:
        mov ax, min
        cmp ax, c
        jnc if3
        jc else3
    else2:
        mov ax, c
        mov max, ax
        jmp next2
    else3:
        jmp next2
    if3:
        mov ax, c
        mov min, ax
        jmp next2
    next2:
        mov ax, max
        cmp ax, d
        jnc if4
        jc else4
    if4:
        mov ax, min
        cmp ax, d
        jnc if5
        jc else5
    else4:
        mov ax, d
        mov max, ax
        jmp toend
    if5:
        mov ax, d
        mov min, ax
        jmp toend
    else5:
        jmp toend
    toend:
        mov ax, max
        sub ax, min
    mov ax, 4c00h
    int 21h
end main
