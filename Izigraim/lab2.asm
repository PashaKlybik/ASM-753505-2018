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
MAX_VALUE dw 32768
is_Negative dw 0
result_is_negative dw 0
ten dw 10

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
messageLongInput db 10, 13, "Error: too long number.", 10, 13, '$'
 
.code
main:
    mov ax, @data
    mov ds, ax

    ; -------------TASK 1----------------
    mov ax, 12345
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

    cmp is_Negative, 0
    je positive_devidence
    neg ax
    inc result_is_negative

    positive_devidence:
        mov a, ax

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

        cmp is_Negative, 0
        je positive_divider
        neg ax
        inc result_is_negative

        positive_divider:
            mov b, ax

        cmp b, 0
        je entering_divider

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
            
    push bx
    push cx
    push dx
    push si
    
    xor bx,bx
    xor si,si
InputBegin:

    mov ah, 08h         ;read simbol, but not show it
    int 21h
    
    cmp al, 13          ; Enter.
    jz FinishInput
    
    cmp al, 8           ; Backspace.
    jz Backspace
    
    cmp al, 27         ; Escape.
    JZ Escape
    
    cmp al, '9'  
    ja InputBegin     

    cmp al, '0'
    jb InputBegin
    
    mov ah, 02h 
    mov dl, al            ; show simbol on display
    int 21h
    
    sub al, '0'        
    
    xor ch,ch
    mov cl,al          
    mov ax,bx          
    mul ten
    cmp dx, 0           ; if dx!=0, number is more than 16 bit
    jnz Overlim
    add ax, cx
    jc Overlim
    mov bx, ax
    inc si
    jmp InputBegin
    
Backspace:
    mov ax, bx
    xor dx, dx
    div ten
    mov bx, ax
    lea dx, strCMD
    push ax
    
    mov ah, 9
    int 21h
    pop ax
    call Show_AX
    JMP InputBegin
    
Escape:
    mov cx, si
    xor si, si
    xor bx, bx
    inc cx
ClearLoop:
    mov dl, 8       ; move left on 1 position(if we can do it)
    mov ah, 02h
    int 21h
    call Delete
    loop ClearLoop
    jmp InputBegin
    
Overlim:
    mov bx,0
    mov   ah, 9           
    mov   dx, offset strOF        
    int   21h
    jmp InputBegin
    
FinishInput:
    mov ax, bx
    pop si
    pop dx
    pop cx
    pop bx
    ret
    
    readInput endp

    Delete PROC         ;show ' ' and move it on 1 position left  
    push ax        
    push dx 
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    mov ah, 02h
    int 21h

    pop dx
    pop ax 
    ret
Delete ENDP

    
    Show_AX proc
    
    push ax
    push bx
    push cx
    push dx
    
    xor cx,cx
    mov bx,10
    
DivCycle:
    xor dx,dx
    div bx
    push dx         ; v stek kladem poslednee chislo
    inc cx
    cmp ax, 0
    jnz DivCycle
    
OutputCycle:
    pop dx          ; CX raz vipolnyaem cikl
    add dl, '0'    
    mov ah, 02h
    int 21h
    loop OutputCycle
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
    Show_AX endp

    clear_regs proc
        xor ax, ax
        xor bx, bx
        xor dx, dx

        ret
    clear_regs endp         

end main
