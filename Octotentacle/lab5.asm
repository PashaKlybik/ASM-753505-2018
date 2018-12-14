.model small
.stack 100h
.data
    InFileName db "input.txt"
    FileString db  100 dup (?)
    Matrix dw 100 dup (?)    
    n1 dw ?     
    m1 dw ?
    nextind dw 0
    StringResult db 200 dup (' ')
    EndLine db 13, 10
    handle dw ?
    OutFileName db "output.txt"
.code

proc GetLeftInd
    push ax
    push bx
    push dx
    mov dx, 0
    mov ax, bx
    div m1
    cmp dx, 0
    je notL
    dec bx
    notL:
    mov nextind, bx
    pop dx
    pop bx
    pop ax
    ret
GetLeftInd endp
    
proc GetUpInd
    push ax
    push bx
    push dx
    cmp bx, m1
    jb notU
    sub bx, m1
    notU:
    mov nextind, bx
    pop dx
    pop bx
    pop ax
    ret
GetUpInd endp

proc UpdateMatrix
    push ax
    push bx
    push cx
    push dx
    push si
    lea si, Matrix
    mov ax, n1
    mov bx, m1
    mul bx
    mov cx, ax
    mov bx, 0
    cycle:
    call GetLeftInd
    mov ax, nextind
    mov dx, 2
    mul dx
    push bx
    mov bx, ax
    mov dx, word ptr [Matrix + bx]
    pop bx
    mov nextind, dx
    mov dx, [si]
    cmp nextind, dx
    jb noUpd1
    mov dx, nextind
    mov [si], dx
    noUpd1:
    call GetUpInd
    mov ax, nextind
    mov dx, 2
    mul dx
    push bx
    mov bx, ax
    mov dx, word ptr [Matrix + bx]
    pop bx
    mov nextind, dx
    mov dx, [si]
    cmp nextind, dx
    jb noUpd2
    mov dx, nextind
    mov [si], dx
    noUpd2:
    inc bx
    inc si
    inc si
    loop cycle
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
UpdateMatrix endp

proc ReadFromFile
    push ax
    push bx
    push cx
    push dx
    
    xor dx, dx
    mov ah,3Dh            
    xor al,al               
    lea dx, InFileName
    xor cx,cx              
    int 21h    
    mov handle, ax
    xor dx, dx
    mov bx, ax
    mov ah, 3Fh          
    lea dx, FileString
    mov cx, 95         
    int 21h
    xor bx, bx
    lea si,FileString    
    add si, ax  
    inc si
    inc si    
    mov byte ptr [si], '$'    
    xor ax, ax
    mov ah,3Eh   
    mov bx, handle
    int 21h                
    pop dx
    pop cx
    pop bx
    pop ax    
    lea si, FileString    
    ret    
endp ReadFromFile


proc StringToMatrix
    xor ax, ax
    xor bp, bp
    xor dx,dX
    lea di, Matrix    
begin:    
    xor ax,ax
    lodsb
    cmp al, '$'
    jz endOfString
    cmp al, '-'
    jne toNumber 
    inc bp
    jmp begin
toNumber:
    cmp al, '9'
    jg notNumber
    cmp al, '0'
    jb notNumber
    sub ax,'0'    
    shl dx,1    
    add ax, dx
    shl dx, 2
    add dx, ax   
    jmp begin
    notNumber:
    cmp al,' '
    jne newStringSymbol
    jmp number
newStringSymbol:
    inc si
number:
    mov ax,dx
    cmp bp, 1
    jne positiveNumber
    neg ax
    positiveNumber:
    mov [di], ax
    xor dx, dx
    inc di
    inc di
    xor bp, bp
    jmp begin
endOfString:
    ret
endp StringToMatrix


proc ReadDigit
    xor ax,ax
    lodsb    
    sub al,'0'    
    ret
endp ReadDigit


proc ReadSize
    call ReadDigit
    mov n1, ax
    inc si
    call ReadDigit
    mov m1, ax
    inc si
    inc si
    ret    
endp ReadSize


proc NumberToString
    add si, 6
    push cx
    push si
    xor bp, bp
    cmp ax, 0
    jg positive
    neg ax
    inc bp
positive:
    xor dx, dx
    mov cx, 10
    div cx
    mov byte ptr [si], '0'
    add [si], dl
    dec si
    cmp ax, 0
    jg positive
    cmp bp, 0
    je exitProc
    mov byte ptr [si], '-'
    xor bp, bp
exitProc:
    pop si
    inc si
    pop cx
    ret
endp NumberToString


proc MatrixToString
    lea si, StringResult
    lea di, Matrix
    mov cx, n1
allMatrix1:
    push cx
    mov cx, m1
outString:
    mov ax, [di]
    call NumberToString
    inc di
    inc di
    loop outString
    mov byte ptr [si], 13
    inc si
    mov byte ptr [si], 10
    inc si
    pop cx
    loop allMatrix1
    ret
endp MatrixToString


proc WriteInFile
    mov ah,3Ch              
    lea dx, OutFileName        
    xor cx,cx               
    int 21h                 
    mov handle,ax         
    mov bx,ax               
    mov ah,40h              
    lea dx, StringResult      
    mov cx, 200     
    int 21h                
    mov ah, 3Eh            
    mov bx, handle        
    int 21h                
    ret
endp WriteInFile


start:
mov ax, @data 
    mov ds, ax       
    mov es, ax    
    call ReadFromFile
    call ReadSize    
    call StringToMatrix
    call UpdateMatrix    
    call MatrixToString    
    call WriteInFile    
    mov ax, 4c00h
    int 21h
  end start