.model small
.stack 256
.data
    maxLen db 255
    lenStr db 0 
    string db 256 dup ('$')
    rezStr db 256 dup ('$')
    addressOfMin dw 0
    addressOfMax dw 0
    lengthOfMin dw -1
    lengthOfMax dw 0
.code
LOCALS

ChangeMaxMin proc
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
    mov cl, lenStr
    repne movsb                ; from further to end
    ret
ChangeMaxMin endp

FindMaxMin proc
    push ax
    push bx
    push cx
    push dx
    mov al, ' '
    lea bx, string
    mov addressOfMin, bx
    mov addressOfMax, bx
    cld
    lea di, string
    xor ch,ch
    mov cl, lenStr
@@nextWord:
    repne scasb
    je @@found
    lea di, string
    pop dx
    pop cx
    pop bx
    pop ax
    ret

@@found:
    mov dx, di
    sub dx, bx
    dec dx
    cmp dx, 0
    jng @@next2
    cmp dx, lengthOfMin
    jnc @@next1
    mov lengthOfMin, dx
    mov addressOfMin, bx
@@next1:
    cmp lengthOfMax, dx
    jnc @@next2
    mov lengthOfMax, dx
    mov addressOfMax, bx
@@next2:
    mov bx, di
    jmp @@nextWord
FindMaxMin endp

start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    lea dx, maxLen
    mov ah, 0ah
    int 21h
    
    xor bh, bh
    mov bl, lenStr
    mov string[bx], ' '
    inc lenStr
    mov ah, 02h
    mov dl, 10
    int 21h
    call FindMaxMin    
    
    lea si, string
    lea di, rezStr
    mov ax, addressOfMax 
    mov bx, addressOfMin 
    mov cx, lengthOfMax
    mov dx, lengthOfMin
    ;ax - further from beginning word
    ;bx - closer to beginning word
    ;cx - length of further from beginning word
    ;dx - length of closer to beginning word
    ;si - source string
    ;di - result string
    cmp bx, ax
    jc next
    je ifEqual
    xchg ax, bx
    xchg cx, dx
next:
    call ChangeMaxMin
    jmp output
ifEqual:
    mov al, '$'
    xor ch,ch
    mov cl, lenStr
    repne movsb
output:
    lea dx, rezStr
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