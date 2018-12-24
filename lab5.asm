.model small
.stack 256
.data
    matrix      db  3 dup(3 dup(0))
    determinant dw  0
    openErrorMessage  db  'cannot open file$'
    closeErrorMessage db  'cannot close file$'
    readErrorMessage  db  'cannot read file$'
    writeErrorMessage db  'cannot write file$'
    createErrorMessage db  'cannot create file$'
    input       db  'input.txt',0
    output      db  'output.txt',0
    filechar    db  0    
    filehandle  dw  0	
    number      dw  0
    numberSign  db  1
    matrixSize  db  0
    outnum      db  6 dup('$'),'$'
    
.code

Open proc
    mov ah, 3dh
    xor al, al
    lea dx, input
    int 21h
    jc errorOpen 
    
    mov filehandle, ax
    jmp exitopen
    
errorOpen:
    lea dx, openErrorMessage
    mov ah, 9h
    int 21h
    stc
    
exitOpen:
    ret
Open endp

Create proc
    mov filehandle, 0
    mov ah, 3ch
    xor al, al
    xor cx, cx
    lea dx, output
    int 21h
    jc errorcreate
    
    mov filehandle, ax
    jmp exitcreate
    
errorcreate:
    lea dx, createErrorMessage
    mov ah, 9h
    int 21h
    stc

exitcreate:
    ret
Create endp

Close proc
    mov bx, filehandle
    or bx, bx
    jz exitclose    
    mov ah, 3eh
    int 21h
    jnc exitclose

errorclose:
    lea dx, closeErrorMessage
    mov ah, 9h
    int 21h
    
exitclose:
    ret
Close endp

ReadNumber proc
    mov number, word ptr 0
    mov numbersign, byte ptr 1

readstart:
    mov ah, 3fh
    mov bx, filehandle  
    lea dx, filechar         
    mov cx, 1  
    int 21h
    or ax, ax
    jz fileend
    
    xor ax, ax
    mov al, filechar
    cmp al, 0dh
    je readstart
    
    cmp al, '-'
    jne digit
    mov numbersign, byte ptr -1
    jmp readstart

digit:    
    cmp al, '0'
    jl nextnum
    cmp al, '9'
    jg nextnum
    sub al, '0'
    mov bx, ax
    mov ax, number
    mov dx, 10
    mul dx
    add bx, ax
    mov number, bx
    jmp readstart
    
errorread:
    lea dx, readErrorMessage
    mov ah, 9h
    int 21h
    stc
    jmp fileend

nextnum:
    mov ax, number
    mov bl, numbersign
    xor bh, bh
    mul bl
    mov number, ax
    clc
    jmp exitread    

fileend:
    
exitread:
    ret
ReadNumber endp

WriteFile proc
    mov numbersign, byte ptr 0
    mov ax, determinant
    cmp ax, 0
    jg positiv
    mov numbersign, byte ptr 1
    xor bx, bx
    mov bx, word ptr -1
    mul bx

positiv:
    xor cx,cx 
    mov bx,10 
 
digits:       
    xor dx,dx 
    div bx    
    add dl,'0'
    push dx   
    inc cx    
    test ax,ax
    jnz digits
 
fillstr:
    lea di, outnum
    xor ax, ax
    mov al, numbersign
    or al, al
    jz printnum
    mov [di], byte ptr '-'
    inc di
    
printnum:    
    pop dx     
    mov [di],dl
    inc di     
    loop printnum

    mov ah, 40h
    xor al, al
    mov bx, filehandle
    mov cx, di
    lea dx, outnum
    sub cx, dx
    int 21h
    jnc exitwrite

    lea dx, writeErrorMessage
    mov ah, 9h
    int 21h
    stc    
    
exitwrite:
    ret
WriteFile endp

calc proc
    mov di, 0

    mov al, matrixsize
    xor ah, ah
    cmp ax, 1
    jne size2
    
    mov al, matrix[di]
    xor ah, ah
    mov determinant, ax
    jmp calcexit
    
size2:
    cmp ax, 2
    jne size3
    call calcSize2
    
    jmp calcexit

size3:
    call calcSize3

calcexit:
    ret
calc endp

calcSize2 proc
    xor ax, ax
    xor bx, bx
    mov di, 2
    mov al, matrix[0][0]
    mov bl, matrix[di][1]
    mul bl
    mov determinant, ax

    xor ax, ax
    xor bx, bx
    mov al, matrix[0][1]
    mov bl, matrix[di][0]
    mul bl
    sub determinant, ax

    ret
calcSize2 endp

calcSize3 proc
    xor ax, ax
    xor bx, bx
    mov di, 3
    mov al, matrix[di][1]
    add di, di
    mov bl, matrix[di][2]
    mul bl
    mov dx, ax

    xor ax, ax
    xor bx, bx
    mov di, 3
    mov al, matrix[di][2]
    add di, di
    mov bl, matrix[di][1]
    mul bl
    sub dx, ax
    mov ax, dx
    xor bx, bx
    mov bl, matrix[0][0]
    mul bx
    mov determinant, ax

    xor ax, ax
    xor bx, bx
    mov di, 3
    mov al, matrix[di][0]
    add di, di
    mov bl, matrix[di][2]
    mul bl
    mov dx, ax

    xor ax, ax
    xor bx, bx
    mov di, 3
    mov al, matrix[di][2]
    add di, di
    mov bl, matrix[di][0]
    mul bl
    sub dx, ax
    mov ax, dx
    xor bx, bx
    mov bl, matrix[0][1]
    mul bx
    sub determinant, ax

    xor ax, ax
    xor bx, bx
    mov di, 3
    mov al, matrix[di][0]
    add di, di
    mov bl, matrix[di][1]
    mul bl
    mov dx, ax

    xor ax, ax
    xor bx, bx
    mov di, 3
    mov al, matrix[di][1]
    add di, di
    mov bl, matrix[di][0]
    mul bl
    sub dx, ax
    mov ax, dx
    xor bx, bx
    mov bl, matrix[0][2]
    mul bx
    add determinant, ax
    
    ret
calcSize3 endp

start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call Open
    jc exit
    
    call ReadNumber
    jc closeinputfile
    
    mov cx, number
    mov matrixsize, cl

readline:
    push cx    
    mov cl, matrixsize
    xor ch, ch
    
readnum:
    push cx
    call readnumber
    jc closeinputfile
    
    pop cx
    pop bx
    push bx
    
    mov al, matrixsize  ;calculate index
    xor ah, ah
    sub ax, bx
    mov bl, matrixsize
    mul bl
    mov si, ax  ;row

    mov bl, matrixsize
    xor bh, bh
    sub bx, cx  ;column
    
    mov ax, number
    mov matrix[si][bx], al
    loop readnum

    pop cx
    loop readline

closeinputfile:
    pushf
    call close
    popf
    jc exit

calculate:
    call calc

createfile:
    call create
    jc exit
    
writenum:
    call WriteFile
    
closeoutputfile:
    call close

exit:
    mov     ax,4c00h
    int     21h

end start
