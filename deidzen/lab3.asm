.model small
.stack 100h
.data
    ten dw 10
    endline db 13, 10, '$'
    minus db 0
    input_dividend db "Input dividend: ", 13, 10, '$'
    dividend db "Dividend: ", 13, 10, '$'
    divider db "Divider: ", 13, 10, '$'
    quotient db "Quotient: ", 13, 10, '$'
    remainder db "Remainder: ", 13, 10, '$'
    input_divider db "Input divider: ", 13, 10, '$'
    large_str db "Error: Your number is too big", 13, 10, '$'
    letter_error db "Error: You've entered some invalid symbols", 13, 10, '$'
    divide_zero db "Error: dividing by zero", 13, 10, '$'
    string db 10 dup(?)
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

print_endline proc
    push dx
    lea dx, endline
    call print_string
    pop dx
    ret
print_endline endp

delete_last_symbol proc ; удаление последнего символа из строки
    push dx
    mov dl, 8
    call print_symbol
    mov dl, ' '
    call print_symbol
    mov dl, 8
    call print_symbol
    pop dx
    ret
delete_last_symbol endp

read_num proc ; чтение числа
    push bx
    push cx
    push dx
    xor bx, bx
    xor cx, cx
    mov byte ptr minus, 0

input_char:
    mov ah, 01h
    inc cx
    int 21h
    cmp al, 8
    je if_backspace
    cmp al, 27
    je if_escape
    cmp al, 13
    je check_negative
    cmp al, '-'
    je if_minus
    jmp add_digit
    
if_minus:
    cmp cx, 1
    ja invalid
    mov byte ptr minus, 1
    jmp input_char
    
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
    call delete_last_symbol
    dec cx
    cmp cx, 0
    je input_char
    cmp cx, 1
    je delete_first_symbol
    xor dx, dx
    xchg ax, bx
    div ten
    xchg ax, bx
    dec cx
    jmp input_char
delete_first_symbol:
    xor bx, bx
    mov minus, 0
    dec cx
    jmp input_char
    
if_escape:
    call delete_last_symbol
    loop if_escape
    xor bx, bx
    mov byte ptr minus, 0
    jmp input_char
    
check_negative:
    mov ax, bx
    cmp byte ptr minus, 1
    jne compare_with_maximum
    cmp ax, 32768
    ja large_error_no_endline
    neg ax
    jmp end_read_num
compare_with_maximum:
    cmp ax, 32767
    ja large_error_no_endline
    jmp end_read_num

invalid:
    call print_endline
    push dx
    lea dx, letter_error
    call print_string
    pop dx
    xor bx, bx
    xor cx, cx
    mov byte ptr minus, 0
    jmp input_char
    
large_error:
    call print_endline
large_error_no_endline:
    push dx
    lea dx, large_str
    call print_string
    pop dx
    xor bx, bx
    xor cx, cx
    mov byte ptr minus, 0
    jmp input_char

end_read_num:
    pop dx
    pop cx
    pop bx
    ret
read_num endp

print_num proc

    push ax ; заносим в стек регистры, которые будем задействовать
    push cx
    push dx
    push di                 
    xor cx, cx
    
    cmp ax, 0 
    jge convert_number_to_char ; если число отрицательное, выводим в консоль минус
    mov dl, '-'
    call print_symbol
    neg ax
        
convert_number_to_char:
    inc cx
    xor dx, dx
    div ten
    add dx, '0'
    push dx
    test ax, ax
    jnz convert_number_to_char
    
    lea di, string
    
put_char_in_string:
    pop dx
    mov [di], dl
    inc di
    loop put_char_in_string
    mov byte ptr[di], '$'
    
    lea dx, string
    call print_string
    call print_endline
    
    pop di
    pop dx
    pop cx
    pop ax
    ret

print_num endp

start:
    mov ax, @data
    mov ds, ax
    
    push dx
    lea dx, input_dividend ; Ввод и вывод делимого
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
    lea dx, input_divider ; ввод и вывод делителя
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
    cwd
    idiv bx
    
    cmp dx, 0
    jge remainder_is_positive
    
    cmp bx, 0
    jg divisor_is_positive
    neg bx
    add dx, bx
    inc ax
    jmp remainder_is_positive
divisor_is_positive:
    add dx, bx
    dec ax
    
remainder_is_positive:
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