;удалить из строки все повтор€ющиес€ символы
.model small
.stack 256
.data
    string db 250, 250 dup('$')
.code
main:
    mov ax, @data
    mov ds, ax
    mov es, ax    

    lea di, string
    mov dx, di
    mov ah, 0ah
    int 21h
    call nextstr
    inc dx
    call delete
    mov ah, 09h
    int 21h
    call nextstr
            
    mov ax, 4c00h
    int 21h

delete proc
    push cx
    push bx
    push ax
    xor bx, bx
    mov si, dx
    mov di, dx
checkSimbol:
    mov al, [si]
    mov cx, bx
    repne scasb
    je alike
    mov di, dx
    add di, bx
    mov [di], al
    inc bx
alike:
    inc si
    cmp byte ptr [si], '$'
    je finish
    mov di, dx
    jmp checkSimbol
finish:
    mov byte ptr [di], '$'
    pop ax
    pop bx
    pop cx
    ret
delete endp

nextstr proc
    push ax
    push dx
    mov ah, 02h
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret
nextstr endp
 
end main
