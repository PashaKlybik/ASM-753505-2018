
.model small
.stack 256
.data
    matrix dw 10*10 dup (0)
    input db "input.txt", 0
    output db "output.txt", 0
    char db ?                     ;buffer char
    rows dw 0
    cols dw 0
    ten dw 10
    sign db 0
    errorMessage db "Error", '$'
    colsMessage db "Enter number of columns:",10,13,'$'
    rowsMessage db "Enter number of rows:",10,13,'$'
    handle dw 0                   ; descriptor of file
    border dw 32768
    newLine db 13, 10, '$'              ; new line
    addressOfMin dw 0                      ; adress of min element
    addressOfMax dw 0                      ; adress of max element
    nullWord db 0                     ; if it isn't number
.code
LOCALS

FileNumInput proc         ;BX - descriptor, si - length of file
    push cx
    push dx
    push di
    mov ax, 0
    mov nullWord, al
    mov sign, al
    ;first input
    mov ah, 3fh
    lea dx, char
    mov cx, 1
    int 21h
    jc @@emergencyExit
    dec si
    cmp si, 0
    je @@emergencyExit 
    mov al, char
    xor cx, cx
    cmp al, '-'
    je @@setsign
    cmp al, ' '
    je @@nullNumber
    cmp al, 10
    je @@nullNumber
    cmp al, 13
    je @@nullNumber
    cmp al, 9
    je @@nullNumber
@@nextStep1:
    sub al, '0'
    xor ah, ah
    mov cx, ax
    jmp @@input
@@setsign:
    inc sign
@@input:
    push cx
    mov ah, 3fh
    lea dx, char
    mov cx, 1
    int 21h
    jc @@emergencyExit
    dec si
    cmp si, 0
    je @@emergencyExit 
    pop cx
    mov al, char
    cmp al, ' '
    je @@exit
    cmp al, 10
    je @@exit
    cmp al, 13
    je @@exit
    cmp al, 9
    je @@exit
@@nextStep2:
    sub al, '0'
    xor ah, ah
    mov di, ax
    mov ax, cx
    mul ten
    add ax, di
    mov cx, ax
    jmp @@input

@@emergencyExit:
    mov ah,3Eh
    int 21h
    jmp caseErr

@@nullNumber:
    inc nullWord
    jmp @@exit
@@exit:
    cmp sign, 1
    jc @@exitNext
    neg cx
@@exitNext:
    mov ax, 0
    mov sign, al
    mov ax, cx
    pop di
    pop dx
    pop cx
    ret
FileNumInput endp

CslNumInput proc
    push bx
    push cx
    push dx
    xor bx, bx
  @@input:
    mov ah, 01h
    int 21h
    cmp al, 13
    je @@exit
    cmp al, 8
    je @@backspace
    cmp al, '0'
    jc @@errChar
    cmp al, '9'+1
    jnc @@errChar
    sub al, '0'
    xor ch, ch
    mov cl, al
    mov ax, bx
    mul ten
    add ax, cx
    cmp ax, 10   ;max dimensionality
    ja @@errChar
    mov bx, ax
    jmp @@input

@@backspace:
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    int 21h
    mov ax, bx
    xor dx, dx
    div ten
    mov bx, ax
    jmp @@input

@@errChar:
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 8
    int 21h
    jmp @@input
    
@@exit:
    mov ax, bx
    pop dx
    pop cx
    pop bx
    ret
CslNumInput endp

CslNumOutput proc
    push cx
    push dx
    xor cx, cx
    cmp ax, border
    jnc @@showSign
@@divLoop:
    xor dx, dx
    div ten
    push dx
    inc cx
    cmp ax, 0
    jne @@divLoop
@@output:
    pop dx
    add dx, '0'
    mov ah, 02h
    int 21h
    loop @@output
    pop dx
    pop cx
    ret
@@showSign:
    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax
    neg ax
    jmp @@divLoop
CslNumOutput endp

FileNumOutput proc
    push bx
    push cx
    push dx
    xor cx, cx
    cmp ax, border
    jnc @@showSign
@@divLoop:
    xor dx, dx
    div ten
    push dx
    inc cx
    cmp ax, 0
    jne @@divLoop
@@output:
    pop dx
    push cx
    add dx, '0'
    mov ah, 40h
    mov char, dl
    lea dx, char
    mov cx, 1
    int 21h
    pop cx
    loop @@output
    pop dx
    pop cx
    pop bx
    ret
@@showSign:
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
    jmp @@divLoop
FileNumOutput endp

FileOutput proc
    push ax
    push cx
    push dx
    mov si, 0
    mov cx, rows     
@@external:
    push cx
    mov cx, cols
    @@internal:
        mov ax,matrix[si]    
        call FileNumOutput
        push cx
        mov dl, 9
        mov char, dl
        lea dx, char
        mov cx, 1
        mov ah, 40h
        int 21h
        pop cx
    @@next:
        inc si
        inc si
        loop @@internal
    lea dx, newLine
    mov cx, 2
    mov ah, 40h
    int 21h
    pop cx
    loop @@external
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
@@external:
    push cx        
    mov cx, cols
@@internal:
        mov ax,matrix[si]    
        call CslNumOutput
        mov dl, 9
        mov al, 2
        int 21h
    @@next:
        inc si 
        inc si        
        loop @@internal
    mov dl, 10
    mov al, 2
    int 21h
    mov dl, 13
    int 21h
    pop cx 
    loop @@external
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
    push di
    mov al, 2     ;считаем и записываем длину в si
    xor cx, cx
    xor dx, dx
    mov ah, 42h
    int 21h
    jc @@caseErr
    cmp dx, 0
    jne @@caseErr
    mov si, ax
    mov al, 0     ; возвращаем указатель в начало файла
    xor cx, cx
    mov ah, 42h
    int 21h
    jc @@caseErr
    mov ax, rows
    mul cols
    shl ax, 1
    mov cx, ax
    mov di, 0
elOfMatrix:
    call FileNumInput
    cmp nullWord, 0
    jne elOfMatrix
    mov matrix[di], ax
    inc di
    inc di
    cmp di, cx
    jc elOfMatrix
    pop di
    pop dx
    pop cx
    pop ax
    ret
@@caseErr:
    jmp caseErr
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
    mov addressOfMax, bx
    mov cx, 0     
    @@maxExternal:
        mov dx, cols
        sub dx, cx
        dec dx
        cmp dx, 0
        jl maxFound
        shl dx, 1
        xor di, di
    @@maxInternal:
            cmp dx, di
            jc @@maxExtNext
            cmp ax, matrix[bx][di]
            jnl @@maxIntNext
            mov ax, matrix[bx][di]
            mov addressOfMax, bx
            add addressOfMax, di
        @@maxIntNext:
            inc di 
            inc di        
            jmp @@maxInternal
    @@maxExtNext:
        add bx, cols
        add bx, cols
        inc cx
        cmp cx, rows
        jc @@maxExternal
maxFound:
    mov si, rows
    dec si
    shl si, 2
    mov ax, matrix[si]
    xor bx, bx
    mov bx, cols
    shl bx, 1
    mov cx, 1
    @@minExternal:
        mov di, cols
        sub di, cx
        cmp di, 0
        jnl @@notNeg
        xor di, di
    @@notNeg:
        shl di, 1
        mov si, cols  
        dec si
        shl si, 1
    @@minInternal:
            cmp si, di
            jl @@minExtNext
            cmp ax, matrix[bx][si]
            jng @@minIntNext
            mov ax, matrix[bx][si]
            mov addressOfMin, bx
            add addressOfMin, si
        @@minIntNext:
            dec si
            dec si
            jmp @@minInternal
    @@minExtNext:
        add bx, cols
        add bx, cols
        inc cx
        cmp cx, rows
        jc @@minExternal
    mov si, addressOfMin
    mov ax, matrix[si]
    mov di, addressOfMax
    mov bx, matrix[di]
    mov matrix[di], ax
    mov matrix[si], bx
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
    lea dx, rowsMessage
    int 21h
    call CslNumInput
    mov rows, ax
    
    mov ah, 09h
    lea dx, colsMessage
    int 21h
    call CslNumInput
    mov cols, ax
    
    cmp cols, 0
    je exit
    cmp rows, 0
    je exit
    
    xor al, al
    mov ah, 3dh
    lea dx, input
    xor cx, cx
    int 21h
    jc caseErr
    mov handle, ax
    mov bx, ax
    
    call FileInput
    call CslOutput
    
    mov ah,3Eh
    mov bx,[handle]
    int 21h
    jc exit
    
    cmp rows, 1
    jng admission
    call ChangeMaxMin
admission:
    lea dx, newLine
    mov ah, 09h
    int 21h
    call CslOutput
    
    mov al, 1
    mov ah, 6ch
    lea si, output
    xor cx, cx
    mov dx, 12h
    int 21h
    jc caseErr
    mov handle, ax
    mov bx, ax
    
    call FileOutput
    
    mov ah,3Eh
    mov bx,[handle]
    int 21h
    jnc exit
    
caseErr:
    lea dx, errorMessage
    mov ah, 09h
    int 21h
exit:
    mov ah, 01h
    int 21h
    mov ax, 4c00h
    int 21h
end start