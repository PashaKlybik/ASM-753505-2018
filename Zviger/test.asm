.model small
.stack 256
.data
	kek db "abcd dasdasd dasgdtngnfhyjfywqeqwraef$"
.code
main:
    mov ax, @data
    mov ds, ax
    
    mov ah, 09h
    lea dx, kek
    int 21h
    
    exit:
    mov ax, 4c00h
    int 21h
end main