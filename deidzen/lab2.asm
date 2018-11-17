.model small
.stack 100h
.data
    ten dw 10
    endline db 13, 10, '$'
    input_dividend db "Input dividend: ", 13, 10, '$'
    dividend db "Dividend: ", 13, 10, '$'
    divider db "Divider: ", 13, 10, '$'
    quotient db "Quotient: ", 13, 10, '$'
    remainder db "Remainder: ", 13, 10, '$'
    input_divider db "Input divider: ", 13, 10, '$'
    large_str db "Error: Your number is too big", 13, 10, '$'
    letter_error db "Error: You've entered some invalid symbols", 13, 10, '$'
    divide_zero db "Error: dividing by zero", 13, 10, '$'
.code

print_symbol proc ; вывод символа
    push ax
    mov ah, 02h
    int 21h
    pop ax
    ret
print_symbol endp

print_string proc ; вывод строки
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret
print_string endp

delete_symbol proc ; удаление символа из строки
    push dx
    mov dl, 8
    call print_symbol
    mov dl, ' '
    call print_symbol
    mov dl, 8
    call print_symbol
    pop dx
    ret
delete_symbol endp

read_num proc ; чтение числа
    push bx
    push cx
    push dx
    xor bx, bx

input_char:
    mov ah, 01h
    inc cx
    int 21h
    cmp al, 8
    je if_backspace
    cmp al, 27
    je if_escape
    cmp al, 13
    je end
    jmp add_digit
    
add_digit: 
    xor ah, ah
    xchg ax, bx
    cmp bl, '0'
    jb invalid
    cmp bl, '9'
    ja invalid
    sub bl, '0'
    mul ten
    jc large_error
    add ax, bx
    jc large_error
    xchg ax, bx
    jmp input_char
    
if_backspace:
    mov dl, ' '
    call print_symbol
    call delete_symbol
    dec cx
    cmp cx, 0
    je input_char
    xor dx, dx
    xchg ax, bx
    div ten
    xchg ax, bx
    dec cx
    jmp input_char
    
if_escape:
    call delete_symbol
    loop if_escape
    xor bx, bx
    jmp input_char
    
invalid:
    push dx
    lea dx, endline
    call print_string
    lea dx, letter_error
    call print_string
    pop dx
    xor bx, bx
    jmp input_char
    
large_error:
    push dx
    lea dx, endline
    call print_string
    lea dx, large_str
    call print_string
    pop dx
    xor bx, bx
    jmp input_char

end:
    mov ax, bx
    pop dx
    pop cx
    pop bx
    ret
read_num endp

print_num proc

    push ax ; заносим в стек регистры, которые будем задействовать
    push bx
    push cx
    push dx                 
    
    mov cx, 5 ; устанавливаем счётчик цифр
    
divproc:
    
    xor dx, dx
    mov bx, 10
    div bx
    
    add dx, '0'
    push dx
loop divproc    
    
    xor bx, bx
    xor cx, cx
    
outproc:
    cmp cx, 5
    je endproc
    inc cx
    
    pop dx
    cmp cx, 5
    je backflag
    
    cmp dx, '0' ; проверка на 0 в начале числа
    jne makeflag
    
    cmp bx, 0
    je outproc
    
    backflag:
    mov ah, 02h
    int 21h
    
jmp outproc

endproc:
    mov ah, 9
    lea dx, endline
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

makeflag:
    cmp bx, 1
    je backflag
    mov bx, 1
    jmp backflag

print_num endp

start:
    mov ax, @data
    mov ds, ax
    
    push dx
    lea dx, input_dividend
    call print_string
    pop dx
    call read_num
    push dx
    lea dx, dividend
    call print_string
    pop dx
    call print_num
    
    mov bx, ax
    push dx
    lea dx, input_divider
    call print_string
    pop dx
    call read_num
    push dx
    lea dx, divider
    call print_string
    pop dx
    call print_num
    
    cmp ax, 0
    jne is_not_zero
    push dx
    lea dx, divide_zero
    call print_string
    pop dx
    jmp exit
    
is_not_zero:
    xchg ax, bx
    xor dx, dx
    div bx
    
    push dx
    lea dx, quotient
    call print_string
    pop dx
    call print_num
    
    mov ax, dx
    lea dx, remainder
    call print_string
    pop dx
    call print_num

exit:
    mov ah, 4ch
    int 21h
end start