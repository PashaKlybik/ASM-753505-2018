.model small
.stack 256
.data
.386

is_Empty dw 1     
is_Negative dw 0
Amount dw 0     
divider dw 2
ostatok dw 0
Counter dw 0
No_more_sign dw 0
First_input dw 1
forbid_input dw 0

strYouNumber db 13,10,'Your number :  $'
strEnterYourNumber db 13,10,'Enter your number :  $'
strTask1 db 13,10,'-----Task 1------$'
strTask2 db 13,10,'-----Task 2------$'
strTask3 db 13,10,'-----Task 3------$'
strDividend db 13,10,'Enter the dividend :  $'
strDivider db 13,10,'Enter the divider :  $'
strResult db 13,10,'Result :  $'
strRemainder db 13,10,'Remainder :  $'
strDividingOnNull db 13,10,'Dividing on 0!!!$'
strNull db 13,10,'$'

result_sign dw 0


.code
main:
    
    mov ax, @data
    mov ds, ax
    
    ;-------Task_1--------
    lea dx, strTask1
    mov ah, 09h
    int 21h
    
    mov ax, -8390
    
    push ax
        lea dx, strYouNumber
        mov ah, 09h
        int 21h
    pop ax
    call Show_AX
    
    ;-------Task_2---------
    call clear_regs
    xor cx, cx
    
    lea dx, strTask2
    mov ah, 09h
    int 21h
    
    lea dx, strEnterYourNumber
    int 21h
    
    call readInput
    mov bx, ax
    
    lea dx, strYouNumber
    mov ah, 09h
    int 21h
    
    mov ax, bx
    call Show_AX
    
    ;-------Task_3--------
    call clear_regs
    xor cx, cx
    
    lea dx, strTask3
    mov ah, 09h
    int 21h
    
    lea dx, strDividend
    mov ah, 09h
    int 21h
    
    call readInput
    mov cx, ax
    lea dx, strYouNumber
    mov ah, 09h
    int 21h
    mov ax, cx
    call Show_AX
    or cx, cx
    jns konchilis_imena_dlya_metok
    
    inc result_sign
    neg cx
    
    konchilis_imena_dlya_metok:
    lea dx, strDivider
    mov ah, 09h
    int 21h
    
    call readInput
    cmp ax, 0
    jz konchilis_imena_dlya_metok
    mov bx, ax
    lea dx, strYouNumber
    mov ah, 09h
    int 21h
    mov ax, bx
    call Show_AX
    or bx, bx
    jns snova_net_imen
    
    inc result_sign
    neg bx
    
    snova_net_imen:
    xor dx, dx
    mov ax, cx
    div bx
    
    mov bx, dx
    mov cx, ax
    xor dx, dx
    mov ax, result_sign
    div divider
    cmp dx, 1
    jnz ya_ustal_sorry
    
    neg cx
    neg bx
    
    ya_ustal_sorry:
    lea dx, strResult
    mov ah, 09h
    int 21h
    
    mov ax, cx
    call Show_AX
    
    lea dx, strRemainder
    mov ah, 09h
    int 21h
    
    mov ax, bx
    call Show_AX
    
    lea dx, strNull
    mov ah, 09h
    int 21h
    
    call clear_regs              
    xor cx, cx
    mov ax, 4C00h                      
    int 21h
    
    readInput proc  
        push bx
        push cx
        push dx
        call clear_regs
        mov cx, 0
        call clear_flags
        mov Amount, 0
        mov Counter, 0
        
        StartInput:
            call clear_regs
            
            mov ah, 08h
            int 21h
            
            cmp al, 13
            jz end_input
            
            cmp al, 8
            jz backspace
            
            cmp al, 27
            jz escape
            
            cmp forbid_input, 1
            jnz AAAA
            
            jmp StartInput
            
            AAAA:
            cmp al, '-'
            jz negative
            
            cmp al, '+'
            jz positive
            
            cmp al, '9'
            ja StartInput
            
            cmp al, '0'
            jb StartInput
            
            
            cmp is_Negative, 1                        
            jnz not_negative
            
            sub ax, '0'
            mov ah, 0
            mov cx, 0
            
            cmp First_input, 1
            jnz go_input_1
            
            mov First_input, 0
            mov No_more_sign, 1
            cmp al, 0
            jnz go_input_1
            
            mov forbid_input, 1
            
            go_input_1:
            push ax
                mov ax, Amount
                mov bx, 10
                push dx
                    mul bx
                pop dx
                mov cx, ax
            pop ax
            
            jnc next_1
                
            jmp overflow
            
            next_1:
                add cx, ax
                jnc next_2
                
                jmp overflow
            
            next_2:
                mov bl, al
                mov ax, cx
                mov cx, 0
                mov dx, 0
                div divider
                mov ostatok, dx
                sub cx, ax
                jo overflow
                sub cx, ax
                jo overflow
                sub cx, dx
                jo overflow
                
                mul divider
                add ax, ostatok
                
                mov Amount, ax
                
                inc Counter
                mov is_Empty, 0
                mov dl, bl
                add dl, '0'
                mov ah, 02h
                int 21h
                
                jmp StartInput
            
            not_negative:
                sub ax, '0'
                mov ah, 0
                
                cmp First_input, 1
                jnz go_input_2
                
                mov First_input, 0
                mov No_more_sign, 1
                cmp al, 0
                jnz go_input_2
                
                mov forbid_input, 1
                
                go_input_2:
                mov bl, al
                mov ax, cx
                push bx
                push dx
                    mov bx, 10
                    imul bx
                pop dx
                pop bx
                jo overflow
                
                add ax, bx
                jo overflow
                
                mov cx, ax
                
                inc Counter
                mov is_Empty, 0
                mov dl, bl
                add dl, '0'
                mov ah, 02h
                int 21h
                
                jmp StartInput
            
        positive:
            cmp No_more_sign, 1
            jnz still_entering
            
            jmp StartInput
            
            still_entering:
                mov is_Empty, 0
                
                mov dl, '+'
                mov ah, 02h
                int 21h
                
            mov No_more_sign, 1
            inc Counter
            jmp StartInput
        
        backspace:
            cmp Counter, 0
            jnz vse_ok_idem_dalshe
            
            jmp StartInput
            
            vse_ok_idem_dalshe:
                cmp is_Negative, 1
                jnz no_neg
                
                    dec Counter
                    mov dx, 0
                    mov ax, Amount
                    mov bx, 10
                    div bx
                    mov Amount, ax
                    
                    cmp Counter, 0
                    
                    jnz lolkek
                    
                    mov Amount, 0
                    call clear_flags
                    call clear_regs
                    xor cx, cx
                    
                lolkek:
                    jmp move_next
                
            no_neg:
                dec Counter
                mov ax, cx
                mov bx, 10
                mov dx, 0
                div bx
                mov cx, ax
        
                cmp Counter, 0
                
                jnz lolkek
                
                call clear_flags
                call clear_regs
                xor cx, cx
                
                memkek:
                jmp move_next
                
            move_next:
                mov dl, 8
                mov ah, 02h
                int 21h
                
                mov dl, ' '
                int 21h
                
                mov dl, 8
                int 21h
            
            jmp StartInput
            
        escape:
            mov cx, Counter
            
            cmp Counter, 0
            jz go_start
            again:
                mov dl, 8
                mov ah, 02h
                int 21h
                
                mov dl, ' '
                int 21h
                
                mov dl, 8
                int 21h
            loop again
            
            call clear_flags
            call clear_regs
            xor cx, cx
            mov Counter, 0
            mov Amount, 0
            
            go_start:
            jmp StartInput
            
        negative:
            cmp No_more_sign, 1
            jnz still_entering_1
            
            jmp StartInput
            
            still_entering_1:
                mov is_Negative, 1
                
                mov dl, '-'
                mov ah, 02h
                int 21h
            mov No_more_sign, 1
            inc Counter
            jmp StartInput
        
        overflow:
            jmp StartInput
            
        end_input:
            cmp is_Empty, 1
            jnz check_for_negative
            
            jmp StartInput
            
            check_for_negative:
                cmp is_Negative, 1
                jz push_Amount
                
                mov ax, cx
                pop dx
                pop cx
                pop bx
                ret
                
                push_Amount:
                    mov cx, Amount
                    sub cx, 1
                    neg cx
                    sub cx, 1
                    mov ax, cx
                    pop dx
                    pop cx
                    pop bx
                    ret
    
    readInput endp

    Show_AX proc
            push    ax
            push    bx
            push    cx
            push    dx
            push    di
     
            mov     cx, 10          
            xor     di, di          
     
                                    
                                    
                                    
            or      ax, ax
            jns     @@Conv
            push    ax
            mov     dx, '-'
            mov     ah, 2           
            int     21h
            pop     ax
     
            neg     ax
     
        @@Conv:
            xor     dx, dx
            div     cx              
            add     dl, '0'         
            inc     di
            push    dx              
            or      ax, ax
            jnz     @@Conv
                                    
        @@Show:
            pop     dx             
            mov     ah, 2           
            int     21h
            dec     di              
            jnz     @@Show
     
            pop     di
            pop     dx
            pop     cx
            pop     bx
            pop     ax
            ret
        Show_AX endp

    clear_regs proc
        xor ax, ax
        xor bx, bx
        xor dx, dx
        ret
    clear_regs endp
    
    clear_flags proc
        mov First_input, 1
        mov No_more_sign, 0
        mov is_Negative, 0
        mov is_Empty, 1
        mov forbid_input, 0
        ret
    clear_flags endp

end main