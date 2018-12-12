model small
.stack 256
.data
s db  "startgkek$"
mess1 db 0dh,0ah,"Final String:",0dh,0ah,"$"
.code
start:
    mov ax, @data
    mov ds, ax

    lea dx, s
    mov ah, 09h
    int 21h

    mov ah, 4ch
    int 21h

endl proc
    push ax
    push dx
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret
endl endp 
end start