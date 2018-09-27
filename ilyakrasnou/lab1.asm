.model small
.stack 256
.data
    a dw 14
    b dw 58
    c dw 24
    d dw 18
.code
main:
    mov ax, @data
    mov ds, ax
    
    mov ax, a
    inc ax
    or ax, a
    cmp ax, b
    jne neq1

    mov ax, a
    mul b

	xor dx, dx
    add ax, c
    div d
    mov ax, dx
    jmp next

  neq1:
    mov ax, a
    and ax, b
    mov cx, c
    or cx, d
  cmp ax, cx
    jne neq2

    mov ax, b
    dec ax
    and ax, b
    jmp next

  neq2:
    xor dx, dx
    mov ax, c
    div d
    mov bx, dx
    mov ax, a
    mul b
    add ax, bx
	jmp next



    next:
    mov ax, 4c00h
    int 21h
end main
