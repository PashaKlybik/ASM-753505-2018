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
    jnae else1 ;if b > a

    mov max, ax ;else if b < a or b == a
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
        jnae else2 ;if c > max

    mov ax, min ;check if c < min
    cmp ax, c
    jae if3 ;if c < min move c in min
    jnae else3 ;if c > min than do nothing

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
        jc else4 ;if d > max

    mov ax, min
    cmp ax, d
    jae if5 ;if d < min move d in min
    jnae toend ;if d > min than do nothing
    
    else4:
        mov ax, d
        mov max, ax
        jmp toend
    if5:
        mov ax, d
        mov min, ax
    toend:
        mov ax, max
        sub ax, min
    mov ax, 4c00h
    int 21h
end main
