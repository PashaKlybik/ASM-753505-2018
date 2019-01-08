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
    jc ax_less_bc
    
    to_2nd_compare:
    mov cx, ax
    mov ax, c
    mul d
    cmp ax, cx
    jc ax_less_cd
    
    to_3rd_compare:
    mov cx, ax
    mov ax, a
    mul d
    cmp ax, cx
    jc ax_less_ad

    to_end:
    
    mov ax, 4c00h
    int 21h
    
    ax_less_bc:
    mov ax, cx
    jmp to_2nd_compare

    ax_less_cd:
    mov ax, cx
    jmp to_3rd_compare
    
    ax_less_ad:
    mov ax, cx
    jmp to_end
end main