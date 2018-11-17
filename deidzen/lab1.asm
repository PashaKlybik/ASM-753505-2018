.model small

.stack 256

.data

    a dw 5
    b dw 4
    c dw 7
    d dw 8
.code

main:

    mov ax, @data                       ; пересылаем адрес регистра данных в регистр AX
    mov ds, ax
                          ; установка регистра DS на сегмент данных
    
    mov ax, b
    mul c
    mov cx, ax
    mov ax, a
    mul b
    cmp ax, cx
    jc cmp1
    
    ret1:
    mov cx, ax
    mov ax, c
    mul d
    cmp ax, cx
    jc cmp2
    
    ret2:
    mov cx, ax
    mov ax, a
    mul d
    cmp ax, cx
    jc cmp3

    cmp1:
    mov ax, cx
    jmp ret1

    cmp2:
    mov ax, cx
    jmp ret2
    
    cmp3:
    mov ax, cx
    
    mov ax, 4c00h
    int 21h
end main