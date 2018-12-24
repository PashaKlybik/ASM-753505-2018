.model small
.stack 100h
.data
    a dw 0
    filename db "input.txt"
    n1m1 dw ?
    buf db  100 dup (?)
    matrix dw 100 dup (?)            
    n dw ?                 
    m dw ?                
    matrixResult dw 100 dup (?)    
    strResult db 200 dup (' ')
    endline db 13,10
    handle dw ?
.code


proc task
    lea bx,matrixResult
    xor cx,cx
    mov cx,n1m1
            
    cycle:        
        xor ax,ax
        mov ax, [di]
        cmp ax,a
        jng notGreate
        mov ax,0    
    notGreate:
        mov [bx],ax        
        add bx,2
        add di,2            
    loop cycle            

    ret
endp task


proc fileInput
    push ax
    push bx
    push cx
    push dx
    
    xor dx,dx
    mov ah,3Dh              
    xor al,al               
    lea dx,filename
    xor cx,cx               
    int 21h
    
    mov handle,ax
    
    xor dx,dx
    mov bx,ax
    mov ah,3Fh           
    lea dx,buf
    mov cx,95           
    int 21h
    
    xor bx,bx
    lea si,buf
    add si,ax
    
    inc si
    inc si
    
    mov byte ptr [si],'$'
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    xor ax,ax
    mov ah,3Eh            
    mov bx,handle
    int 21h                
    
    ret    
endp fileInput


proc readMatrix
    xor bp,bp
    xor dx,dx
    
    begin:    
        xor ax,ax
        lodsb

        cmp al,'$'
        jz exit

        cmp al,'-'
        jne division 

        inc bp
        jmp begin

    division:
        cmp al,'9'
        jg notNumber

        cmp al,'0'
        jb notNumber

        sub ax,'0'    
        shl dx,1    
        add ax,dx
        shl dx,2
        add dx,ax    
    jmp begin
    
    notNumber:
        cmp al,' '
        jne newLine
        jmp number
    
    newLine:
        inc si
    
    number:
        mov ax,dx
        cmp bp,1
        jne positiveNumber
        neg ax
    
    positiveNumber:
        mov [di],ax
        xor dx,dx
        inc di
        inc di
        xor bp,bp
    jmp begin
    
    exit:    
    ret
endp readMatrix


proc readANM
    push ax
    mov ax,[di]
    mov a,ax
    inc di
    inc di
    
    mov ax,[di]
    mov n,ax
    inc di
    inc di
    
    mov ax,[di]
    mov m,ax
    inc di
    inc di
    pop ax
    ret    
endp readANM


proc matrixToString
    add si,6
    push cx
    push si
    xor bp,bp
    cmp ax,65535
    jg pos

    neg ax
    inc bp
    pos:
        xor dx,dx
        mov cx,10
        div cx
        mov byte ptr [si],'0'
        add [si],dl

        dec si

        cmp ax,0
        jg pos

        cmp bp,0
        je exit2

        mov byte ptr [si],'-'
        xor bp,bp
    exit2:
    pop si
    inc si
    pop cx
    ret
endp matrixToString


proc output
    push cx
    lea di,matrixResult
    mov cx,n
    
    outputAllMatrix:
        push cx
        mov cx,m
    
        outRow:
            mov ax,[di]
            call matrixToString
            inc di
            inc di
        loop outRow

        mov byte ptr [si],13
        inc si
        mov byte ptr [si],10
        inc si
        pop cx
    loop outputAllMatrix

    mov byte ptr [si],'$'
    pop cx
    ret
endp output


proc printString
    push ax
    mov ah,09h              
    int 21h                 
     pop ax
    ret
endp printString


proc mulNM
    push ax
    push dx
    xor ax,ax
    mov ax,n
    mov dx,m
    mul dx
    mov n1m1,ax
    pop dx
    pop ax
    ret
endp mulNM


start:
    mov ax,@data        
    mov ds,ax       
    mov es,ax
    
    call fileInput

    lea si,buf    
    lea di,matrix        
    call readMatrix
    lea di,matrix
    call readANM
    call mulNM
    call task

    lea bx,matrixResult
    mov ax,[bx]
    lea si,strResult
        
    call output    
    lea dx,strResult  
    call printString

final:        
    mov ax,4c00h
    int 21h
end start 