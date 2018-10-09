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

change proc
    push cx
    mov cx, bx                ; до первого слова
    sub cx, si
    cld
    rep movsb                ; до первого слова
    pop cx
    push cx
    mov si, ax
    rep movsb                ; вставляем второе слово
    mov cx, ax
    sub cx, bx
    sub cx, dx
    mov si, bx
    add si, dx
    rep movsb                ; от первого до второго
    mov cx, dx
    mov si, bx
    rep movsb                ; вставляем первое слово
    mov si, ax
    mov al, '$'
    pop cx
    add si, cx
    mov cx, len
    repne movsb                ; от второго до конца
    ret
change endp

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
    jnc nextf1
    mov minl, dx
    mov mina, bx
nextf1:
    cmp maxl, dx
    jnc nextf2
    mov maxl, dx
    mov maxa, bx
nextf2:
    mov bx, di
    jmp nextw
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
    
    lea si, string
    lea di, rezstr
    mov ax, maxa ;ax - второе слово
    mov bx, mina ;bx - первое слово
                 ;сх - длина второго слова
                 ; dx - длина первого слова
                 ;si - указатель на строку источник
                 ; di - указатель на результирующую строку
    mov cx, maxl
    mov dx, minl
    cmp bx, ax
    jc next
    je ifeq
    xchg ax, bx
    xchg cx, dx
next:
    call change
    jmp output
ifeq:
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