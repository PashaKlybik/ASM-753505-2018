.model tiny
.stack 256
.data
    _str    db  13 dup(?)
.code
    
org 100h

main:
    mov ax, @data    
    mov ds, ax
    lea dx, _str
    mov bx, dx
    mov al, 11
    mov [bx], al
    mov ah, 0ah
    int 21h
    mov dl, 0ah
    mov ah, 2
    int 21h
    call    output
    mov ah, 4ch
    int 21h
 
output  proc    near
    mov ah, 40h
    mov bx, 1
    mov ch, 0
    mov cl, [_str +1]
    lea dx, _str +2
    int 21h
    ret
output  endp
end main