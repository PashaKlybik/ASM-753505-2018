.model small
.stack 256
.data
    max db 255
    lenstr db 0 
    string db 256 dup ('$')
    rezstr db 256 dup ('$')
    len dw 256
    mina dw 0
    maxa dw 0
    minl dw -1
    maxl dw 0
.code
;Вариант 16
;Поменять местами наибольшее и наименьшее по длине слово.

parse proc
    push ax
    push bx
    push cx
    push dx
    mov al, ' '
    lea bx, string
    mov mina, bx
    mov maxa, bx
    cld
    lea di, string
    mov cx, len
nextw:
    repne scasb
    je found
    lea di, string
    pop dx
    pop cx
    pop bx
    pop ax
    ret

found:
    mov dx, di
    sub dx, bx
    dec dx
    cmp dx, 0
    je nextf2
    cmp dx, minl
    jc setmin
nextf1:
    cmp maxl, dx
    jc setmax
nextf2:
    mov bx, di
    jmp nextw

setmin:
    mov minl, dx
    mov mina, bx
    jmp nextf1
setmax:
    mov maxl, dx
    mov maxa, bx
    jmp nextf2
parse endp

start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    lea dx, max
    mov ah, 0ah
    int 21h
    
    xor bh, bh
    mov bl, lenstr
    mov string[bx], ' '
    inc bx
    mov len, bx
    mov ah, 02h
    mov dl, 10
    int 21h
    call parse    
    
    mov ax, mina
    sub ax, di
    mov bx, maxa
    sub bx, di
    cmp ax, bx
    jnc groreq
    mov cx, ax                ; min < max
    cld
    lea si, string
    lea di, rezstr
    rep movsb                ; до мин слова
    mov cx, maxl
    mov si, maxa
    rep movsb                ; вставляем макс слово
    mov cx, bx
    sub cx, ax
    sub cx, minl
    mov si, mina
    add si, minl
    rep movsb                ; от мин до макс
    mov cx, minl
    mov si, mina
    rep movsb                ; вставляем мин слово
    mov cx, len
    mov al, '$'
    mov si, maxa
    add si, maxl
    repne movsb                ; от макс до конца
    jmp output
groreq:
    cmp ax, bx
    je ifeq
    mov cx, bx
    cld
    lea si, string
    lea di, rezstr
    rep movsb                ; до макс слова
    mov cx, minl
    mov si, mina
    rep movsb                ; вставляем мин слово
    mov cx, ax
    sub cx, bx
    sub cx, maxl
    mov si, maxa
    add si, maxl
    rep movsb                ; от макс до мин
    mov cx, maxl
    mov si, maxa
    rep movsb                ; вставляем макс слово
    mov cx, len
    mov al, '$'
    mov si, mina
    add si, minl
    repne movsb                ; от мин до конца
    jmp output
ifeq:
    lea si, string
    lea di, rezstr
    mov al, '$'
    mov cx, len
    repne movsb
output:
    lea dx, rezstr
    mov ah, 09h
    int 21h
    mov ah, 02h
    mov dl, 10
    int 21h
    mov ah, 01h
    int 21h

    mov ax, 4c00h
    int 21h
end start