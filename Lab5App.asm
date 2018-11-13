.model small
.stack 256h
.data
rows        dw ?
cols        dw ?
array        dw 10*10 dup (?)
finalArray    dw 10*10 dup (0)
checkVar    dw ?
crlf        db 13,10,'$'
msgPress    db 13,10,'Press any key...$'
msgRows        db 'Input count of rows (<=10): $'
msgCols        db 'Input count of columns (<=10): $'
msgEl        db 13,10,'Input elements: ',13,10,'$'
errorMessage     db 'ERROR!','$'

.code
write macro  str
    push ax
    push dx
 
    lea dx,str    
    mov ah,09h
    int 21h
 
    pop dx
    pop ax
endm
 
output proc
    push ax
    push bx
    push cx
    push dx
    xor cx,cx
    xor bx,bx
    mov bx,10
    cmp ax,0
    jns toStack
    
    push ax
    push dx
    mov dl,'-'
    mov ah,02h
    int 21h
    pop dx
    pop ax
    neg ax

    toStack:
        cmp ax, 10 
        jc exit
        xor dx,dx
        div bx
        push dx
        inc cx
    jmp toStack
    exit:        
        push ax
        inc cx
          
    fromStack:        
        pop dx
        add dx, '0'
        mov ah, 02h
        int 21h
    loop fromStack
     
    mov    dx,' '
    mov ah,02h 
    int    21h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
output endp

input proc
    push bx
    push cx
    push si
    push dx
    xor  ax,ax
    xor  bx,bx
    xor  cx,cx
    xor  si,si
    xor  dx,dx
    symbolEntry:
        mov ah, 01h
        int 21h    
        cmp al, 8 
        jz backspace    
        cmp al, 13
        jz exitInput
        cmp al,'-'
        jz minusTrigger
        cmp al, '0'
        jb error
        cmp al, '9'
        ja error
        sub al, '0'
        
        mov cl, al
        mov ax, 10
        mul bx
        call rangeCheck
        mov bx, ax
        add bx, cx
        call rangeCheck
    jmp symbolEntry
     
     minusTrigger:
     cmp bx,0
     jnz error
     cmp si,0
     jnz error
     mov si,1
     jmp symbolEntry
     backspace:
        push ax
        push dx
        mov dl, ' '
        mov ah, 02h
        int 21h
     
        mov dl, 8
        mov ah, 02h
        int 21h
     
        cmp bx, 0
        jnz notMinus
        mov si, 0
        pop dx
        pop ax
        jmp symbolEntry
         
        notMinus:
            mov ax, bx
            cmp ax, 10
            jnc deleteLastDigit
        mov bx, 0
        pop dx
        pop ax
        jmp symbolEntry
        deleteLastDigit:    
            mov dx, 0
            mov bx, 10
            div bx
            mov bx, ax
            pop dx
            pop ax
            jmp symbolEntry
    error:
    write crlf
    lea dx, errorMessage
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h
    
    exitInput:
        mov ax,bx
    cmp si,0
        jz endInput
        neg ax
    endInput:
        pop dx
        pop si
        pop cx
        pop bx
        ret
input endp

rangeCheck proc
    jc error
    cmp si, 0
    jz pozitiveCheck
    cmp ax, 32769
    jnc error
    cmp bx, 32769
    jnc error
    jmp endCheck
    pozitiveCheck:
        cmp ax, 32768
        jnc error
        cmp bx, 32768
        jnc error
    endCheck:        
    ret
rangeCheck ENDP
 
main:
    mov ax,@data
    mov ds,ax
 
    write msgRows
    call input
    mov rows,ax
    write crlf
 
    write msgCols
    call input
    mov cols,ax

;input start matrix
    write msgEl
    mov cx,rows
    xor bx,bx
inputRows:    
    push cx
    mov cx,cols
    mov si,0
inputCols:    
    xor ax,ax
    call input
    mov array[bx][si],ax
    mov finalArray[bx][si],ax
    
    inc si    
    inc si
    loop inputCols
 
    add bx,cols
    add bx,cols
    pop cx
    loop inputRows


    xor bx,bx
    mov cx,rows
outputAMatrixRows:    
    push cx
    mov cx,cols
    mov si,0
    write crlf    
outputAMatrixCols:    
    xor ax,ax
    mov ax,array[bx][si]
    call output    
    inc si
    inc si
    loop outputAMatrixCols
    add bx,cols
    add bx,cols
    pop cx
    loop outputaMatrixRows

;additional check for 1 row and 1 column

    xor bx,bx
    xor di,di
    mov cx,rows
rowsCheck:    
    push cx
    mov cx,cols
    mov si,0    
colsCheck:    
    xor ax,ax
    mov ax,array[bx][si]
    push si
    push bx    
    cmp cx,cols
    je firstColumn 
    cmp di,0
    je firstRow
    jmp endTask
    firstColumn:
        cmp di,0
        je endTask
        sub bx,cols
        sub bx,cols
        cmp ax,array[bx][si]
        jl upperGreater
        jmp upperNotGreater
    upperGreater:
        mov ax,array[bx][si]
    upperNotGreater:
        jmp endTask
    firstRow:
        cmp cx,cols
        je endTask
        dec si
        dec si
        cmp ax,array[bx][si]
        jl leftGreater
        jmp endTaskCheck
    leftGreater:
        mov ax,array[bx][si]
    endTask:
    pop bx
    pop si
    mov finalArray[bx][si],ax    
    inc si
    inc si
    loop colsCheck
    inc di
    add bx,cols
    add bx,cols
    pop cx
    loop rowsCheck


;main algotihm cycle

    xor bx,bx
    xor di,di
    mov cx,rows
algorithmCycleRows:    
    push cx
    mov cx,cols
    mov si,0    
algorithmCycleCols:    
    xor ax,ax
    mov ax,array[bx][si]
    push si
    push bx    
    cmp cx,cols
    je firstColumnOrRow
    cmp di,0
    jne defaultCheck
    firstColumnOrRow:
    pop bx
    pop si
    jmp endTaskAdditional
    defaultCheck:
        sub si,2
        cmp ax,array[bx][si]
        jl check1
        jmp taskCheck1
    check1:
        mov ax,array[bx][si]
    taskCheck1:
        add si,2
        sub bx,cols
        sub bx,cols
        cmp ax,array[bx][si]
        jl check2
        jmp endTaskCheck
        check2:
            mov ax,array[bx][si]
        endTaskCheck:
    pop bx
    pop si
    mov finalArray[bx][si],ax
    endTaskAdditional:    
    add si,2
    loop algorithmCycleCols
    inc di
    add bx,cols
    add bx,cols
    pop cx
    loop algorithmCycleRows


    xor bx,bx
    mov cx,rows
outputBMatrixRows:    
    push cx
    mov cx,cols
    mov si,0
    write crlf    
outputBMatrixCols:    
    xor ax,ax
    mov ax,finalArray[bx][si]
    call output    
    inc si
    inc si
    loop outputBMatrixCols
    add bx,cols
    add bx,cols
    pop cx
    loop outputBMatrixRows
    
    write msgPress
    mov ah,0
    int 16h
    mov ax,4c00h
    int 21h
end main