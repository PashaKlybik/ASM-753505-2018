.model small
.stack 256
.data
    matrix dw 20*20 dup (0)
    input db "input.txt", 0
    output db "output.txt", 0
    char db ?
    rows dw 4
    cols dw 4
    ten dw 10
    sign db 0
    errmes db "Error", '$'
    colsmes db "Enter number of columns:",10,13,'$'
    rowsmes db "Enter number of rows:",10,13,'$'
    handle dw 0
    border dw 32768
    nl db 13, 10, '$'
    mina dw 400
    maxa dw 400
    nullf db 0
.code

setsignf:
    inc sign
    jmp Inputf

FInput proc         ;BX - descriptor
    push cx
    push dx
    push di
    xor dx, dx
    mov ax, 0
    mov nullf, al
    mov sign, al
FirstInputf:
    mov ah, 3fh
    lea dx, char
    mov cx, 1
    int 21h
    jc nullnum
    mov al, char
    xor cx, cx
    cmp al, '-'
    je setsignf
    cmp al, ' '
    je nullnum
    cmp al, 10
    je nullnum
    cmp al, 13
    je nullnum
    cmp al, 9
    je nullnum
nextstep1f:
    sub al, '0'
    xor ah, ah
    mov cx, ax
    jmp Inputf
Inputf:
    push cx
    mov ah, 3fh
    lea dx, char
    mov cx, 1
    int 21h
    jc exitf
    pop cx
    mov al, char
    cmp al, ' '
    je exitf
    cmp al, 10
    je exitf
    cmp al, 13
    je exitf
    cmp al, 9
    je exitf
nextstep2f:
    sub al, '0'
    xor ah, ah
    mov di, ax
    mov ax, cx
    xor dx, dx
    mul ten
    add ax, di
    mov cx, ax
    jmp Inputf

reversef:
    neg cx
    jmp nextinf
nullnum:
    inc nullf
    jmp nextinf
exitf:
    cmp sign, 1
    jnc reversef
nextinf:
    mov ax, 0
    mov sign, al
    mov ax, cx
    pop di
    pop dx
    pop cx
    ret
FInput endp

MyInput proc
    push bx
    push cx
    push dx
    xor bx, bx
  Inputc:
    mov ah, 01h
    int 21h
    cmp al, 13
    je exit
    cmp al, 8
    je backspace
    cmp al, '0'
    jc ErrChar
    cmp al, '9'+1
    jnc ErrChar
    sub al, '0'
    xor ch, ch
    mov cl, al
    mov ax, bx
    xor dx, dx
    mul ten
    add ax, cx
    cmp ax, 11
    jnc ErrChar
    mov bx, ax
    jmp Inputc

backspace:
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    mov ah, 02h
    int 21h
    mov ax, bx
    xor dx, dx
    div ten
    mov bx, ax
    jmp Inputc

ErrChar:
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    mov ah, 02h
    int 21h
    jmp Inputc
    
    exit:
    mov ax, bx
    pop dx
    pop cx
    pop bx
    ret
MyInput endp

MyOutput proc
    push bx
    push cx
    push dx
    xor bx, bx
    cmp ax, border
    jnc showsign
DivCycle:
    xor dx, dx
    div ten
    push dx
    inc bx
    mov cx, ax
    inc cx
    loop DivCycle
    mov cx, bx
Outputc:
    pop dx
    add dx, '0'
    mov ah, 02h
    int 21h
    loop Outputc
    pop dx
    pop cx
    pop bx
    ret
showsign:
    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax
    neg ax
    jmp DivCycle
MyOutput endp

FOutput proc
    push bx
    push cx
    push dx
    xor cx, cx
    cmp ax, border
    jnc fshowsign
FDivCycle:
    xor dx, dx
    div ten
    push dx
    inc cx
    cmp ax, 0
    jne FDivCycle
FOutputc:
    pop dx
    push cx
    add dx, '0'
    mov ah, 40h
    mov char, dl
    lea dx, char
    mov cx, 1
    int 21h
    pop cx
    loop FOutputc
    pop dx
    pop cx
    pop bx
    ret
fshowsign:
    push ax
    push cx
    mov ah, 40h
    mov dl, '-'
    mov char, dl
    lea dx, char
    mov cx, 1
    int 21h
    pop cx
    pop ax
    neg ax
    jmp FDivCycle
FOutput endp

FileOutput proc
    push ax
    push cx
    push dx
    mov si, 0
    mov cx, rows     
externalf:
        push cx

        mov cx, cols
    internalf:
            mov ax,matrix[si]    
            call FOutput
            push cx
            mov dl, 9
            mov char, dl
            lea dx, char
            mov cx, 1
            mov ah, 40h
            int 21h
            pop cx
        nextf:
            inc si
            inc si
            loop internalf
        push cx
        lea dx, nl
        mov cx, 2
        mov ah, 40h
        int 21h
        pop cx

        pop cx
        loop externalf
endoutputf:
    pop dx
    pop cx
    pop ax
    ret
FileOutput endp

CslOutput proc
    push ax
    push cx
    push dx
    push si
    mov si, 0
    mov cx, rows     
external:
        push cx
        
        mov cx, cols
    internal:
            mov ax,matrix[si]    
            call MyOutput
            mov dl, 9
            mov al, 2
            int 21h
        next:
            inc si 
            inc si        
            loop internal
        mov dl, 10
        mov al, 2
        int 21h
        mov dl, 13
        int 21h

        pop cx 
        loop external
endoutput:
    pop si
    pop dx
    pop cx
    pop ax
    ret
CslOutput endp

FileInput proc
    push ax
    push cx
    push dx
    push si
    mov ax, rows
    mul cols
    shl ax, 1
    mov cx, ax
    mov si, 0
elofmatrix:
    call FInput
    cmp nullf, 0
    jne elofmatrix
    mov matrix[si], ax
    mov ax, matrix[si]
    inc si
    inc si
   
    cmp si, cx
    jc elofmatrix

    pop si
    pop dx
    pop cx
    pop ax
    ret
FileInput endp

ChangeMaxMin proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    xor bx, bx
    mov ax, matrix[bx]
    mov maxa, bx
    mov cx, 0     
maxexternal:
        mov dx, cols
        sub dx, cx
        dec dx
        ;add dx, cols
        cmp dx, 0
        jl maxend
        shl dx, 1
        xor di, di
    maxinternal:
            cmp dx, di
            jc maxexnext
            cmp ax, matrix[bx][di]
            jnl maxnext
            mov ax, matrix[bx][di]
            mov maxa, bx
            add maxa, di
        maxnext:
            inc di 
            inc di        
            jmp maxinternal
    maxexnext:
        add bx, cols
        add bx, cols

        inc cx
        cmp cx, rows
        jc maxexternal
maxend:
    mov si, rows
    dec si
    shl si, 2
    mov ax, matrix[si]
    xor bx, bx
    mov bx, cols
    shl bx, 1
    mov cx, 1
    minexternal:
        mov di, cols
        sub di, cx ;
        ;add di, cols
        cmp di, 0
        jnl mingreqz
        xor di, di
    mingreqz:
        shl di, 1
        mov si, cols     ;;
        dec si
        shl si, 1 ;;
    mininternal:
            cmp si, di ;;
            jl minexnext
            cmp ax, matrix[bx][si] ;;
            jng minnext
            mov ax, matrix[bx][si] ;;
            mov mina, bx
            add mina, si ;;
        minnext:
            dec si        ;;
            dec si        ;;
            jmp mininternal
    minexnext:
        add bx, cols
        add bx, cols

        inc cx
        cmp cx, rows
        jc minexternal
minend:
    mov si, mina
    mov ax, matrix[si]
    mov di, maxa
    mov bx, matrix[di]
    mov matrix[di], ax
    mov matrix[si], bx
minfinal:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ChangeMaxMin endp

start:
    mov ax, @data
    mov ds, ax
    
    mov ah, 09h
    lea dx, rowsmes
    int 21h
    call MyInput
    mov rows, ax
    
    mov ah, 09h
    lea dx, colsmes
    int 21h
    call MyInput
    mov cols, ax
    
    cmp cols, 0
    je toend
    cmp rows, 0
    je toend
    
    xor al, al
    mov ah, 3dh
    lea dx, input
    xor cx, cx
    int 21h
    jc caseerr
    mov handle, ax
    mov bx, ax
    
    call FileInput
    call CslOutput
    
    mov ah,3Eh
    mov bx,[handle]
    int 21h
    jc toend
    
    cmp rows, 1
    jng admission
    call ChangeMaxMin
admission:
    lea dx, nl
    mov ah, 09h
    int 21h
    call CslOutput
    
    mov al, 1
    mov ah, 3dh
    lea dx, output
    xor cx, cx
    int 21h
    jc caseerr
    mov handle, ax
    mov bx, ax
    
    call FileOutput
    
    mov ah,3Eh
    mov bx,[handle]
    int 21h
    jnc toend
    
caseerr:
    lea dx, errmes
    mov ah, 09h
    int 21h
toend:
    mov ah, 01h
    int 21h
    mov ax, 4c00h
    int 21h
end start