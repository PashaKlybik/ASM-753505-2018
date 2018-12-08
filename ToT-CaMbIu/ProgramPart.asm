model small
.stack 256
.data
s db  0dh,0ah,"startString$"
.code
start:
	mov ax, @data
	mov ds, ax

	lea dx, s+2
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