.model small
.stack 256
.data
    max db 255
    lenstr db 255 
    string db 256 dup ('$')
    rezstr db 256 dup ('$')
    mina dw 0
    maxa dw 0
    minl dw -1
    maxl dw 0
.code

change proc
    push cx
    mov cx, bx
    sub cx, si
    cld
    rep movsb                ; until closer word
    pop cx
    push cx
    mov si, ax
    rep movsb                ; insert further word
    mov cx, ax
    sub cx, bx
    sub cx, dx
    mov si, bx
    add si, dx
    rep movsb                ; from closer to further word
    mov cx, dx
    mov si, bx
    rep movsb                ; insert closer word
    mov si, ax
    mov al, '$'
    pop cx
    add si, cx
    xor ch, ch
    mov cl, lenstr
    repne movsb                ; from further to end
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
    xor ch, ch
    mov cl, lenstr
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
    jng nextf2
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
    inc lenstr
    mov ah, 02h
    mov dl, 10
    int 21h
    call parse    
    
    lea si, string
    lea di, rezstr
    mov ax, maxa 
    mov bx, mina 
    mov cx, maxl
    mov dx, minl
    ;ax - further from beginning word
    ;bx - closer to beginning word
    ;cx - length of further from beginning word
    ;dx - length of closer to beginning word
    ;si - source string
    ;di - result string
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
    xor ch, ch
    mov cl, lenstr
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