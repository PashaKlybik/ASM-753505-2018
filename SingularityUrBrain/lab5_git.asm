.model small
.stack 256
.data
    coeff dw 10
    flag db 0 ;0 - out of num(for StrToArray)
    fileExceptionMess db 13,10,'Problems with the file',13,10,'$'
    fileNotFoundExceptionMess db 13,10,'File not found',13,10,'$'
    fileReadExceptionMess db 13,10,'FileRead exception',13,10,'$'
    outputFileName db 'output.txt',0
    inputFileName db 'input.txt',0
    handle dw ?
    arrayLength dw 999
    lengthOfResultStr db ?
    buffer db 1000 dup(?)
    result db ?
    array dw 100 dup(?)
    rows dw ?
    cols dw ?
.code
    NumToStr PROC
        push ax
        push cx
        push dx
        xor cx,cx               
     
    divis:                  
        xor dx, dx               
        div [coeff]                  
        add dl,'0'              
        push dx                 
        inc cx                 
        or ax, ax            
    jnz divis       
        mov lengthOfResultStr, cl   
        xor di, di 
    inString:                  
        pop dx                  
        mov result[di], dl             
        inc di                 
    loop inString         
        
        pop dx
        pop cx
        pop ax
        ret
    NumToStr endp
    
    FileWrite PROC
        push ax
        push bx
        push cx
        push dx
        
        mov ah, 3Ch              ;create or rewrite and open
        mov dx, offset outputFileName       
        xor cx, cx               
        int 21h                 
        jc fileException

        mov handle, ax        ;write
        mov ah, 40h
        mov bx, [handle]
        mov dx, offset result            
        xor cx, cx
        mov cl, [lengthOfResultStr]
        int 21h
        cmp al, [lengthOfResultStr]
        jnz fileException

        mov ah, 3eH            ;close
        mov bx, [handle]  
        int 21h
        jnc localExit
    fileException:
        mov dx, offset fileExceptionMess
        call WriteMess
        stc
        jmp exit
    localExit:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    FileWrite endp
    
    FileRead PROC
        push ax
        push bx
        push cx
        push dx
        
        mov ah, 3dH        ;open
        xor al, al
        mov dx, offset inputFileName
        xor cx, cx
        int 21h
        jc fileNotFoundException
        mov [handle], ax
        
        mov bx, ax
        mov ah, 3fH        ;read
        lea dx, buffer
        mov cx, [arrayLength]
        int 21h
        jc fileReadException
        
        lea bx, buffer
        add bx, ax
        inc bx
        mov byte ptr [bx], ' '   ;for StrToArray
        inc bx
        mov byte ptr [bx], '$'   ;end of
        
        mov ah, 3eH              ;close
        mov bx, [handle]  
        int 21h
        jc fileReadException
        jmp localEnd        
    fileNotFoundException:
        mov dx, offset fileNotFoundExceptionMess
        call WriteMess
        stc
        jmp exit
    fileReadException:
        mov dx, offset fileReadExceptionMess
        call WriteMess
        stc
        jmp exit
    localEnd:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    FileRead endp
    
    StrToArray PROC
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        xor ax, ax
        xor bx, bx        
        xor cx, cx
        xor di, di
        xor bp, bp
        
        lea si, buffer
        cld
    rowcol:
        lodsb
        inc [flag]
        cmp al, '$'
        jz exitLocal
        cmp al, '-'
        jz negative
        cmp al, '0'
        jb noNum
        cmp al, '9'
        ja noNum
    continue:
        cmp [flag], 0
        jz outOfNum
        inc cx
        sub al, '0'
        xor ah, ah
        xchg ax, bx
        xor dx, dx
        mul [coeff]
        xchg ax, bx
        add bx, ax
        jmp rowcol
    outOfNum:
        or cx, cx
        jz rowcol
        or bp, bp
        jz positive
        neg bx
    positive:
        mov array[di], bx         ; save bx in array
        inc di
        inc di
        xor bp, bp
        xor bx, bx
        xor cx, cx
        jmp rowcol
    noNum:
        mov [flag], 0
        jmp continue
    negative:
        inc bp
        mov [flag], 1
        jmp rowcol
    exitLocal:
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    StrToArray endp
    
    Sum PROC
        push bx
        push cx
        push si
        
        xor si, si
        mov ax, array[si]
        mov rows, ax
        inc si
        inc si
        mov ax, array[si]
        mov cols, ax
        inc si
        inc si
        xor ax, ax
        xor bx, bx
        mov cx, [rows]  
        external:
            push cx
            mov cx, [cols] 
            internal:
                test bx, 1 ;check oddness
                jz next
                add ax, array[si]
            next:
                inc si
                inc si
                inc bx
            loop internal
            pop cx
            xor bx, bx
        loop external
        
        pop si
        pop cx
        pop bx
        ret
    Sum endp
    
    WriteMess PROC
        push ax
        mov ah, 09h
        int 21h
        pop ax
        ret
    WriteMess endp
      
start:
    mov ax, @data
    mov ds, ax
    
    call FileRead       ;input: inputFileName, output: data in buffer
    call StrToArray   ;input: buffer, output: matrix and deminsion in array, array[0]=rows, array[2]=cols
    call Sum         ;input: array, output: ax = sum
    call NumToStr    ;input: ax = number, output: result = string, lengthOfResultStr = length of number in str invariant
    call FileWrite    ;input: result = data for write, output: outputFileName with result
exit:
    mov ah, 4ch
    int 21h
end start
