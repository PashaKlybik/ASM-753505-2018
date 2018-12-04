.model small
.386
.stack 256
.data
    max db 100
        len db ?
        string db 100 dup('$')
.code

;функция новой строки
newline PROC
        push AX
        push DX
         mov AH, 02h
        mov DL, 13
        int 21h
        mov DL, 10
        int 21h
         pop DX
    pop AX
ret
newline ENDP

;удаление пробелов
delete proc
        push cx
        push bx
        push ax
    
    lea si, string
    lea di, string
    
cycle:
    ;перебираем пока не встретим пробел либо конец строки
    cmp byte ptr [si], ' '
    je Space
    cmp byte ptr [si], '$'
    je exit
    
    lodsb
    mov [di], al

    inc di
    jmp cycle

Space:
    ;проверяем является ли след. символ пробелом , если да , то пропускаем его
    cmp byte ptr [si+1], ' '
    je Skip
    
    lodsb
    mov [di], al
    inc di
    jmp cycle
Skip:
    inc si
    jmp cycle
    
exit:
    lodsb
    mov [di], al
    lea di, string
        pop ax
        pop bx
    pop cx
ret
delete ENDP



main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    ;ввод строки
    lea dx, max
    mov ah, 0aH
    int 21h
    
    ;удаление пробелов
    call newline
    call delete
    lea dx, string

    ;вывод
    mov ah, 09h
    int 21h
    call newline

    mov ax, 4c00h
    int 21h
end main    
