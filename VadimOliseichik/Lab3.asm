.model small 
.stack 256 
.data 
a db 0 
b dw 0 
c dw 0 
d dw 0 
e dw 0 
i dw 0 
sl dw 0 
reservation dw 0
slll dw 0

Message1 db "Invalid input,please try again$" 
Message2 db "Invalid input,the number is greater than the number -32768 or +32767, please try again$" 
Message3 db "You can not divide by zero$" 
Message6 db "The minus was already or is not in its place$"
.code 

    WRITENUMBER PROC 
    push ax
    push bx 
    push cx 
    mov ax,0 
    mov bx,0 
    mov cx,10
    mov sl,0
    mov slll,0
    mov b, 0 
    mov i, 0

    write: 
    inc slll
    mov ah, 01h 
    int 21h 
    mov bl,13 
    cmp al,bl 
    jnz checking2 
    jmp WriteExit

    checking1: 
    cmp slll,1 
    jz allgood
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    lea dx, Message6 
    mov ah, 09h 
    int 21h 
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    mov ax,0 
    mov bx,0 
    mov cx,10 
    mov b, 0
    mov sl,0
    mov slll,0
    jmp write
    allgood:
    mov sl,1
    jmp write

    checking2: 
    cmp al,45 
    jne label_else
    jz checking1
    label_else:
    cmp al,48 
    jnc checking3 
    jmp Error1 

    checking3: 
    mov bl,57 
    cmp bl,al 
    jnc checking4 
    jmp Error1 

    checking4: 
    mov cx,i 
    inc cx
    mov i,cx
    sub al, 48 
    mov a,al 
    mov bl,1 
    mul bl 
    mov c,ax 
    mov ax,b 
    mov cx,10 
    mul cx
    jc Error2 
    add ax,c 
    jc Error2
    jnc checking5 
    mov b,ax
    jmp write

    checking5: 
    push cx
    mov cx, 32768 
    cmp cx, ax
    pop cx
    jz checking6 
    jnc checking7
    jmp Error2 

    checking6: 
    push cx
    mov cx, sl 
    cmp cx, 1 
    pop cx
    jz checking7
    jmp Error2 

    checking7: 
    mov b,ax
    jmp write

    Error1: 
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    lea dx, Message1 
    mov ah, 09h 
    int 21h 
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    mov ax,0 
    mov bx,0 
    mov cx,10 
    mov b, 0 
    mov sl,0
    mov slll,0
    jmp write

    Error2: 
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    lea dx, Message2 
    mov ah, 09h 
    int 21h 
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    mov ax,0 
    mov bx,0 
    mov cx,10 
    mov sl,0
    mov slll,0
    mov b, 0 
    jmp write

    label1:
    mov ax,b
    neg ax 
    mov b,ax
    jmp labs

    WriteExit: 
    cmp sl,1
    jz label1
    labs:
    pop cx
    pop ax
    pop bx
    ret 
    WRITENUMBER ENDP 

    CONCLUSIONNUMBER PROC 
    push ax
    push bx
    push cx
    push dx 
    mov reservation,ax
    mov dx,0 
    mov bx,0 
    mov cx,0 
    mov cx,10
    shl ax,1 
    jc labl 
    mov ax,reservation
    conclusion: 
    mov dx,0
    mov cx,10
    div cx
    push ax
    push dx 
    inc bx
    cmp ax,0 
    jz conclusionexit
    mov dx,0 
    jmp conclusion
    
    labl: 
    mov ax,reservation
    push ax 
    mov dl,45
    mov ah,02h
    int 21h 
    pop ax 
    neg ax
    jmp conclusion
     
    conclusionexit: 
    mov cx,bx
    cycle: 
    pop dx 
    pop ax
    add dx, 48 
    mov ah, 02h 
    int 21h 
    loop cycle
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    pop ax
    pop bx
    pop cx
    pop dx
    ret  
    CONCLUSIONNUMBER ENDP
    
main: 
mov ax, @data 
    mov ds, ax 
    call WRITENUMBER 
    mov ax,b 
    mov d, ax
    call CONCLUSIONNUMBER 
    call WRITENUMBER 
    mov ax,b 
    mov e, ax
    call CONCLUSIONNUMBER 
    mov ax, d 
    mov bx, e 
    cmp bx, 0 
    jz ZERODelete
    cwd
    idiv bx
    call CONCLUSIONNUMBER 
    jmp exit 
    
    ZERODelete: 
    mov dl, 10 
    mov ah, 02h 
    int 21h 
    mov dl, 13 
    mov ah, 02h 
    int 21h 
    lea dx, Message3 
    mov ah, 09h 
    int 21h 
    exit: 
    
mov ax, 4c00h 
int 21h 
end main