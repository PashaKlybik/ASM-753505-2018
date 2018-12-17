.model small
.stack 256
.data
.386

a dw 0 
b dw 1 
c dw 0  
d dw 0
checker dw 0
not_a_number dw 0
;MAX_VALUE dw 32768
is_Negative dw 0
result_is_negative dw 0

enter_num  db  13,10,'Enter number:  $'
enter_divident  db  13,10,'Enter divident:  $'
enter_divider  db  13,10,'Enter divider:  $'
num  db  13,10,'Your number.....:  $'
task1 db  13,10,'----- TASK 1 --------$'
task2 db  13,10,'----- TASK 2 --------$'
task3 db  13,10,'----- TASK 3 --------$'
str db  13,10,'---------------------$'
Result db 10, 13,'Result :$'   
strOF db 10, 13,'Overlim. Please, repeat :$'
strCLS db 10, 13,'$'
strCMD db 10, 13,'> $'
strDZ db 10, 13,'Divide by zero. Please, repeat: $'
 
.code
main:
    mov ax, @data
    mov ds, ax

    ; -------------TASK 1----------------
    mov ax, -7
    push ax

    mov   ah, 9           
    mov   dx, offset task1        
    int   21h
    call clear_regs

    mov   ah, 9           
    mov   dx, offset num        
    int   21h
    call clear_regs

    pop ax
    call Show_AX

    ; -------------TASK 2----------------
    mov   ah, 9           
    mov   dx, offset str        
    int   21h
    call clear_regs

    mov   ah, 9           
    mov   dx, offset task2        
    int   21h
    call clear_regs

    mov   ah, 9           
    mov   dx, offset enter_num        
    int   21h
    call clear_regs

    call readInput
    push ax

    mov   ah, 9           
    mov   dx, offset num        
    int   21h
    call clear_regs

    pop ax
    call Show_AX

    ; -------------TASK 3----------------
    mov   ah, 9           
    mov   dx, offset str        
    int   21h
    call clear_regs

    mov   ah, 9           
    mov   dx, offset task3        
    int   21h
    call clear_regs

    ;???? ? ????? ????????
    mov   ah, 9           
    mov   dx, offset enter_divident       
    int   21h
    call clear_regs

    call readInput

    push ax

    mov   ah, 9           
    mov   dx, offset num        
    int   21h
    call clear_regs

    pop ax
    call Show_AX


    ;???????? ?? ???????????????
    cmp is_Negative, 0
    je positive_devidence
    neg ax
    inc result_is_negative

        
    positive_devidence:
        mov a, ax

    ;???? ? ????? ????????
    entering_divider:
        mov   ah, 9           
        mov   dx, offset enter_divider       
        int   21h
        call clear_regs

        call readInput

        push ax

        mov   ah, 9           
        mov   dx, offset num        
        int   21h
        call clear_regs

        pop ax
        call Show_AX


        ;???????? ?? ???????????????
        cmp is_Negative, 0
        je positive_divider
        neg ax
        inc result_is_negative

        positive_divider:
            mov b, ax

        ;???????? ?? 0
        cmp b, 0
        je entering_divider

    ;???????
    divide:
        mov ax, a
        idiv b
        push ax

        mov   ah, 9           
        mov   dx, offset Result       
        int   21h
        call clear_regs

        pop ax

        cmp result_is_negative, 1
        jne result_positive
        neg ax

        result_positive:
        call Show_AX
            mov ah,4Ch
    mov al,00h
    int 21h

    readInput proc
        call clear_regs
        xor cx, cx

        mov not_a_number, 0
        mov checker, 0
        mov is_Negative, 0

        InputBegin:
            call clear_regs

            mov ah, 08h     ;????????? ??????, ??????? ??????????, ?? ?? ??????? ???              
            int 21h

            cmp al, 13      ;?????????? ??? ??????? ? al  (13-??? ??????)       
            jz return

            cmp al, 8             
            jz backspace    

            cmp al, 27             
            jz escape   

            cmp al, '-'
            jz negative

            cmp al, '+'
            jz plus

            cmp al, '9'  
            ja InputBegin     

            cmp al, '0'
            jb InputBegin

            push ax  ; ---  ???????? al   

            sub ax, '0'    ;  - ???????? ? ????????? ???

            mov bl, al
            mov ax, cx  
            mov dx, 10

            mul dx
            jo overlim

            add ax, bx
            jo overlim
            
            mov cx, ax
            pop ax

            ;cmp cx, MAX_VALUE
            ;ja overlim

            mov checker, 1 

            mov ah, 02h 
            mov dl, al            ; ????? ??????? ?? ????? (???????? ? dl) 
            int 21h

            jmp InputBegin
            
        overlim:
            mov cx, 0
            lea dx, strOF
            mov ah, 9
            int 21h
            mov is_Negative, 0
            mov checker, 0
            jmp InputBegin

        plus:
            cmp not_a_number, 1
            je middle

            cmp checker, 0
            jne middle

            mov not_a_number, 1
            mov ah, 02h 
            mov dl, '+'        
            int 21h
            middle:

            jmp InputBegin

        negative:
            cmp not_a_number, 1
            je middle

            cmp checker, 0
            jne negReturn

            mov not_a_number, 1

                mov is_Negative, 1
                mov ah, 02h 
                mov dl, '-'        
                int 21h

            negReturn:

            jmp InputBegin

        escape:
            mov cx, 0
            lea dx, strCMD
            mov ah, 9
            int 21h
            jmp InputBegin

        backspace:
            mov ax, cx
            mov bx, 10
            div bx

            lea dx, strCMD
            
            push ax
                mov ah, 9
                int 21h
            pop ax

            push ax
                cmp is_Negative, 0
                jz positiveBackSpace 
                    mov dl, '-'
                    mov ah, 2
                    int 21h

                positiveBackSpace:
            pop ax

            cmp ax, 0
            jnz notNull
            mov is_Negative, 0
            mov checker, 0

            notNull:

                call Show_AX
                mov cx, ax
            
            jmp InputBegin

        return:
            cmp checker, 0 ; ???????? ?? ?????? ????
            jz InputBegin

            cmp is_Negative, 1
            jnz positive
            neg cx

            positive:

            mov ax, cx
            ret 
    readInput endp

    Show_AX proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10          ; cx - ????????? ??????? ?????????
        xor     di, di          ; di - ???. ???? ? ?????
 
        ; ???? ????? ? ax ?????????????, ??
        ;1) ?????????? '-'
        ;2) ??????? ax ?????????????
        or      ax, ax
        jns     @@Conv
        push    ax
        mov     dx, '-'
        mov     ah, 2           ; ah - ??????? ?????? ??????? ?? ?????
        int     21h
        pop     ax
 
        neg     ax
 
    @@Conv:
        xor     dx, dx
        div     cx              ; dl = num mod 10
        add     dl, '0'         ; ??????? ? ?????????? ??????
        inc     di
        push    dx              ; ?????????? ? ????
        or      ax, ax
        jnz     @@Conv
        ; ??????? ?? ????? ?? ?????
    @@Show:
        pop     dx              ; dl = ????????? ??????
        mov     ah, 2           ; ah - ??????? ?????? ??????? ?? ?????
        int     21h
        dec     di              ; ????????? ???? di<>0
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

end main
