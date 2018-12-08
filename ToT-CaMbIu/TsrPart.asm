.MODEL  TINY
.DATA
.CODE
        ORG 80h
cmd_len db ?
cmd_line db ?
        ORG     100h

vOldInt label   word
Begin   proc    near
        jmp     init
Begin   endp
        ORG     104h

intRout proc
    cmp     ah, 09h
    je      @0
    jmp     dword ptr cs:[vOldInt]
@0:
    pushf
    push ax
    push bx
    push cx                                   
    push dx
    push di
    push si
    push ds
    push es
    
    push cs
    pop  ds
    push cs
    pop  es  
    
    xor ax,ax
    xor si,si
    xor di,di
    xor dx,dx             
    
    call addSymbolStr
    
    call mainAlgorithm

    mov si, offset finalString
    add si,2
    mov dl, [si]
    cmp dl, '$'
    je exit
cycle:
    mov ah,02h
    int 21h
    inc si
    mov dl,[si]
    cmp dl, '$'
    je exit
    jmp cycle
exit:
    pop es
    pop ds
    pop si
    pop di
    pop dx
    pop cx                                            
    pop bx
    pop ax
    popf
    iret
intRout endp

checkLength proc
    push ax
    push bx
    push si
    push di
    push cx
    push dx
    xor ax,ax
    xor bx,bx
    xor cx,cx
    mov al,finalString[1]
    mov bl,str3[1]
    cmp bl,al
    ja changeFinalString
    jmp final
    changeFinalString:
    mov si,offset str3
    mov di,offset finalString
    mov cl,str3[1]
    add cl,2
    rep movsb
    final:
    pop dx
    pop cx
    pop di
    pop si
    pop bx
    pop ax
checkLength endp

find proc 
push bx
push dx
push cx
push di
push si
xor dx,dx
mov cl,str3[1]
mov si,2
mov di,2
xor ax,ax
loop3: 
    mov bh,str1[si]    
    mov bl,str3[di]
    inc si
    inc di
    cmp bh,bl
    jne l1
    loop loop3
    jmp l2

l1:        
    inc ax
    mov si,ax
    mov cl,str3[1]
    mov di,2
    xor bx,bx
    mov bl,str1[1]
    cmp ax,bx
    jl loop3
    jmp l3

l2:        
    mov ax,0
    jmp l4

l3:        
    mov ax,1

l4:        
pop si
pop di
pop cx
pop dx
pop bx
ret
find endp

mainAlgorithm proc
push ax
push bx
push cx
push dx
push si
push di
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
xor si,si
xor di,di
mov cl,str2[1]
mov di,0
mainBrute:
    push cx
    xor cx,cx
    mov si,offset str2+2
    add si,di
    mov cl,str2[1]
    sub cx,di
    inc di
    push di
    xor bx,bx
    mov bx,cx
    cld
    strLoop:
        lodsb
        push bx
        mov dl,al
        mov bx,offset addSymbol+2
        mov [bx],dl    
        pop bx
        push di
        push si
        push ax
        push cx
        xor ax,ax
        xor di,di
        xor si,si
        mov ax,bx
        sub ax,cx
        mov di, offset str3+2
        add di, ax
        mov si, offset addSymbol+2
        mov cx,1
        rep movsb 
        push bx
        xor bx,bx
        mov dl,al
        add dl,1
        mov bx,offset str3+1
        mov [bx],dl
        pop bx
        call find
        cmp ax,1
        je notTrue
        call checkLength
        notTrue:
        pop cx
        pop ax
        pop si
        pop di
    loop strLoop
    push cx
    push di
    push ax
    push bx
    xor cx,cx
    mov di, offset str3+2;delete string
    mov cl, str3[1]
    mov al,'$'
    rep stosb    
    mov bx,offset str3+1
    mov byte ptr [bx],0
    pop bx
    pop ax
    pop di
    pop cx
    pop di
    pop cx
loop mainBrute
pop di
pop si
pop dx
pop cx
pop bx
pop ax
mainAlgorithm endp

addSymbolStr proc
    xor cx,cx
    mov cl,str1[1]
    add cl,2
    mov bx,offset str1
    add bx,cx
    mov byte ptr [bx],' '
    xor cx,cx
    mov cl,str1[1]
    add cl,1
    mov str1[1],cl
addSymbolStr endp

endl proc
    push ax
    push dx
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret
endl endp 

flag dw 15687
str1 db 0dh,0ah,"lolkek$"
str2 db 0dh,0ah,"progkekch$"
str3 db 10, ?, 9 dup ('$')
addSymbol db 10, ?, 9 dup ('$')
addSymbolNotCycle db 10, ?, 9 dup('$')
finalString db 10,?,9 dup ('$')

init    proc    
        mov     ax, 3521h
        int     21h

        cmp     byte ptr cmd_line[1], 'i'
        je      install
        cmp     byte ptr cmd_line[1], 'd'
        je      uninstall
        jmp     error

install:

        cmp     es:flag, 19864
        je      installed

        mov     flag, 19864

        mov     [vOldInt], bx
        mov     [vOldInt+2], es
 
        mov     dx, offset intRout
        mov     ax, 2521h
        int     21h
 
        mov     dx, offset init
        int     27h

uninstall:
        cmp     es:flag, 19864
        jne     uninstall_error

        mov     dx, es:vOldInt
        mov     ds, es:vOldInt+2
        mov     ax, 2521h
        int     21h

        mov     ax, 4ch
        int     21h

installed:
        mov     dx, offset installed_str
        mov     ah, 09h
        int     21h

        mov     ah, 4ch
        int     21h

error:
        mov     dx, offset error_str
        mov     ah, 09h
        int     21h

        mov     ah, 4ch
        int     21h
uninstall_error:
        mov     dx, offset uninstall_error_str
        mov     ah, 09h
        int     21h

        mov     ah, 4ch
        int     21h        
init    ENDP

installed_str db "Already installed!$"
error_str db "Error! Use 'i' to install, 'd' to delete!$"
uninstall_error_str db "Error! Nothing to delete!$"
        end     Begin