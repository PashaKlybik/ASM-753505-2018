.model small
.stack 256
.data
   crlf db 13,10,'$'
   inWord db 0
   isDublicate db 0
   emptyStrMess db 'String is empty!',13,10,'$'
   buff db 255 dup('$')           ;255=254+1('$')
   string db 254, 256 dup('$')    ;256=254+2(lim,len), 254=255-1(\r)
.code
    WriteMess proc
        push ax
        mov ah, 09h
        int 21h
        pop ax
        ret
    WriteMess endp
    
    DeleteEqWords1 proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        
        xor bx, bx
        mov bl, [string+1]                    ;lenth of the string
        mov byte ptr[string+bx+2], '$'
        mov di, offset string
        cmp byte ptr [string+1], 0
        jnz noEmptyStr
        jmp emptyStrException
    noEmptyStr:
        xor cx, cx
        mov cl, [di+1]  
        inc cl            ;first byte = lim
        inc cl          ;second byte = len
        mov al, ' '
        repnz scasb        ;until symbol!=' '
        mov ax, di         
        dec ax            ;ax = ptr (dfsfr' ds) in string
        sub bx, cx        ;length of the first word
        dec bx             ;third byte = ' '
        mov cx, bx
        mov di, offset buff
        mov si, offset string
        inc si
        inc si
        rep movsb                ;write the first word in the buff
        add bx, offset buff      ;bx = ptr (dfsfr' ds) in buff(for write)
        mov si, ax
    cycle:
        lodsb
        cmp al, ' '
        jnz noSpace
        mov byte ptr[bx],' '
        lodsb
        dec si
        cmp al, ' '
        jnz cycle
        inc bx
        jmp cycle    
    noSpace:
        cmp al, '$'
        jz localEnd     ;need in correct!
        
    cycleWord: 
        dec si             ;lost symbol on load
        call WordLen
        mov cx, ax        ;cx = length of word
        mov di, offset buff
        xchg di, si 
        mov isDublicate, 0
    buffCompare:
        lodsb
        cmp al, ' '
        jz buffCompare   
        cmp al, '$'
        jz cycleEndCheck
        dec si     
        call WordLen ;ax=strlen
        cmp ax, cx
        jz EqualLen
        add si, ax
    jmp buffCompare
    
    EqualLen:            
        push di 
        push si
        push cx
        inc cx
        repz cmpsb ;;;;;;; inc cx 
        or cx, cx
        pop cx
        pop si
        pop di
        jz equal
        mov isDublicate, 0
        add si, ax
        jmp buffCompare
    equal:
        inc isDublicate
        add di, cx
    cycleEndCheck:
        cmp isDublicate, 0
        jnz cycleEnd
        xchg si, di
        dec di
        rep movsb
        mov bx, di
        jmp cycle
    cycleEnd:
        xchg di, si
    jmp cycle
    
    emptyStrException:
        mov dx, offset emptyStrMess
        call WriteMess
        stc
    localEnd:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    DeleteEqWords1 endp
    
    WordLen proc
        push cx
        xor cx, cx
        mov cl, [string+1]
        inc cx
        
        push cx
        push si
        countLen:
            lodsb
            cmp al, ' '
            jz outCount
            cmp al, '$'
            jz outCount
        loop countLen
        outCount:
        pop si
        pop ax
        
        sub ax, cx
        pop cx
        ret
    WordLen endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    mov dx, offset string
    mov ah, 0Ah
    int 21h
    mov dx, offset crlf
    call WriteMess
    call DeleteEqWords1
    mov dx, offset buff
    call WriteMess
    mov dx, offset crlf
    call WriteMess
    mov ah, 4ch
    int 21h
end main
