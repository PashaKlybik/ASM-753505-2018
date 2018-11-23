.model small
.stack 100h
.data
    a dw ?
    b dw ?

    buf db 100, 100 dup ('$')
    endline db 13, 10, '$'
    outstr db 6, 6 dup ('$')
    zeroMsg db "Error: dividing by zero", 13, 10, '$'
    largeErrorStr db "Error: Your number is too big", 13, 10, '$'
    letterError db "Error: You've entered some invalid symbols", 13, 10, '$'
.code



proc inputStr

    lea dx, buf                ;считать строку в buf  
    mov ah, 10
    int 21h

    lea dx, endline            ;переход на новую строку
    mov ah, 9
    int 21h

    lea si, buf    
    inc si
    inc si

    ret
endp inputStr


proc str2dw
    
    xor dx,dx    ;сумма

divStr:
    xor ax,ax
    mov al, [si]    ;текущее значение в аэль
    inc si            ;переход на следующий элемент строки
    cmp al, 13        ;если это enter, то заканчиваем
    je exit
    
    cmp al,'9'    ;Если это не цифра, то пропускаем
    jg notNum
    cmp al,'0'      ;Если это не цифра, то пропускаем
    jb notNum
    
    sub ax,'0'    ;получаем цифровое значение
    
    shl dx,1    ;умножаем сумму на 10
    add ax, dx
    jc overflow
    
    shl dx, 2
    add dx, ax    ;прибавляем текущее значение
    jc overflow

    jmp divStr

notNum:
    mov bp, 2
    jmp exit

overflow:
    mov bp, 1

exit:    
    mov ax,dx
    
    ret
endp str2dw


proc printdec

    push cx    ;сохраняем регистры
    push dx
    push bx

    mov bx,10    ;основание системы
    xor cx,cx    ;в сх будет количество цифр в десятичном числе

digitToStack:    
    xor dx,dx       ;обнудяем dx
    div bx        ;делим число на  10
    push dx        ;и сохраняем остаток от деления(коэффициенты при степенях 10) в стек
    inc cx        ;увеличиваем количество символов в числе
    cmp ax, 0    ;преобразовали все число?
    jne digitToStack    ;если нет, то продолжить
stackToStr:    
    pop ax        ;восстанавливаем остаток от деления
    add al,'0'    ;преобразовываем число в ascii символ
    mov [di], al
    inc di            ;сохраняем в буфер
    loop stackToStr        ;все цифры

    pop bx        ;восстанавливаем регистры
    pop dx
    pop cx
    
    ret
endp printdec


proc checkNum

    push ax
    xor ax, ax
    
    cmp bp, 1                ;переполнение                            
    jne checkOtherSymbols
    
    lea dx, largeErrorStr
    mov ah, 9
    int 21h
    pop ax
    jmp endprog


checkOtherSymbols:

    cmp bp, 2
    jne checkZeroDiv
    lea dx, letterError
    mov ah, 9
    int 21h
    pop ax
    jmp endprog

checkZeroDiv:

    cmp bp, 3
    jne noErrors
    lea dx, zeroMsg
    mov ah, 9
    int 21h
    pop ax
    jmp endprog

noErrors:

    pop ax
    ret
endp checkNum


proc output
    xor ax, ax
    lea dx, outstr
    mov ah, 9
    int 21h

    lea dx, endline            ;переход на новую строку
    mov ah, 9
    int 21h

    ret
endp output


start:
    mov ax, @data
    mov ds, ax

    xor ax, ax
    call inputStr
    call str2dw
    mov a, ax
    call checkNum

    xor ax, ax
    call inputStr
    call str2dw
    mov b, ax
    cmp b, 0
    jne nozero
    mov bp, 3

nozero:
    call checkNum

    ;деление
    xor dx, dx
    mov ax, a
    mov bx, b
    div bx

    lea di, outstr
    call printdec

    call output

endprog:
    mov ax, 4c00h
    int 21h

end start