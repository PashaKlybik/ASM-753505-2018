.model tiny


.data
    
    max db 100
    len db 0
    string db 100 dup (?)
    endline db 13, 10, '$'
    
.code
org 100h

start:
    
    lea dx, max
    mov ah, 10
    int 21h
    
    lea dx, endline
    mov ah, 09h
    int 21h
    
    lea si, string
    xor bx, bx
    mov bl, len
    mov [bx+si], byte ptr '$' ; в si хранится исходная строка
    mov cx, bx
    xor bx, bx
    
    lea dx, string
    mov ah, 9
    int 21h
    
    lea dx, endline
    mov ah, 09h
    int 21h
    
    mov ax, 4c00h
    int 21h
end start