.model small
.stack 256
.data
    a dw 5
    b dw 5
    c dw 0
    d dw 7
.code
main:
    mov ax, @data
    mov ds, ax
         
    mov ax, [a]
    mul [c]        
    mov bx, ax     
    mov ax, [b]
    mul [d]        
    add bx, ax 
    
    mov ax, [a]    
    mul [d]        
    mov cx, ax    
    mov ax, [b]
    mul [c]        
    add cx, ax    
    
    cmp bx, cx
    jnz unequal
    mov ax, [a]
    mul ax
    jmp endCond
unequal:
    mov bx, [a]
    cmp bx, [c]
    jna lessOrEqual
    mov ax, [c]
    and ax, [b]
    jmp endCond
lessOrEqual:
    mov bx, [b]     
    or bx, [c]
    mov ax, [a]
    sub ax, bx
    
endCond:
    mov ax, 4c00h
    int 21h
end main
