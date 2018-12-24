model small
.stack 100h  
.data
    amula dw 0
    bmulc dw 0
    cmulb dw 0
    ddivb dw 0
    cmulaminb dw 0
    aorb dw 0
    result dw 0
     a dw 21
    b dw 3
    c dw 147
    d dw 41
 .code	
start:
    mov ax, @data
    mov DS, ax				
    mov ax, a
    mul a
    mov amula, ax 
    mov ax, b
    mul c
    mov  bmulc,ax
    mov ax, c
    mul b
    mov  cmulb, ax 
    mov ax, d
    div b
    mov ddivb, ax
    mov ax, c
    mul a
    sub ax, b
    mov cmulaminb, ax
    mov ax, a
    or ax, b
    mov aorb, ax
    mov ax, amula
    mov bx, bmulc
    cmp ax, bx
    jnz Neravno1
    jz Ravno1
 Neravno1:
    mov ax, cmulaminb
    mov result, ax
    jmp Endofprogram
Ravno1:
    mov ax, cmulb
    mov bx, ddivb
    cmp ax, bx
    jz Ravno2
    jnz Neravno2
 Ravno2:
    mov ax, aorb
    mov result, ax
    jmp Endofprogram
 Neravno2:
    mov ax, c
    mov result, ax
    jmp Endofprogram
 Endofprogram:
    mov ax, result						
    mov ah, 4Ch
    int 21h
end start 
