.model small
.stack 256
.data
    coeff dw 10
.code
main:
    mov ax, @data
    mov ds, ax
    
    call Input
    
    _Exit:
    mov ax, 4c00h
    int 21h
    
    
    Input PROC
        push bx
        push cx
        push dx
        
        xor bx, bx
        xor cx, cx
        xor dx, dx
        
        cycle:
            mov ah, 01h
            int 21h
            cmp al, 0dh ;enter
            jz exit
            cmp al, 08h
            jz backspace
            cmp al, 1Bh
            jz escape
            cmp al, '0'
            jb dels
            cmp al, '9'
            ja dels
            sub al, '0'
            xchg ax, bx
            xor dx, dx      ;чтобы не сохранять dx в стеке при backspace or escape
            mul [coeff]
            jc _error
            xchg ax, bx
            xor ah, ah
            add bx, ax
            jc _error
            inc cx    ; need for backspace
        jmp cycle

        dels:            ;delete a symbol in cmd
            mov ah, 02h
            mov dl, 08h
            int 21h
            mov dl, 0h
            int 21h
            mov dl, 08h
            int 21h
        jmp cycle
                
        backspace:                
            mov ah, 02h        ;чтобы backspace не переводил каретку
            mov dl, 0h
            int 21h
            
            or cx, cx    ;cmp cx, 0
            jz cycle
            
            mov dl, 08h
            int 21h
            
            mov ax, bx
            xor dx, dx
            div [coeff]    ;cut num
            mov bx, ax
            
            dec cx
        jmp cycle
        
        escape:
            xor bx, bx        ;in progr
            inc cx
            del_lopp:            ;in cmd
                mov ah, 02h
                mov dl, 08h
                int 21h
                mov dl, 0h
                int 21h
                mov dl, 08h
                int 21h
            loop del_lopp 
        jmp cycle
            
        _error:
            stc
            jmp _Exit
        exit:
            mov ax, bx
            pop dx
            pop cx
            pop bx
            
        ret
    Input endp    
    
end main
