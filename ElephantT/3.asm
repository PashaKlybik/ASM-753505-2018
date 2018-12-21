.model small
.stack 100h

.data
	base dw 10
	endline db 13,10,'$'
	first_mes db 'dividend:$'
	second_mes db 'divider:$'
	zero_mes db 'divider != 0$'
	overflow_mes db 'Input again. Incorrect number (too big)$'
	result_mes db 'result:$'
	remainder_mes db 'remainder:$'
.code



cout proc  
    push ax 
    push bx                  
    push cx                     
    push dx
    xor cx,cx
    test ax,ax
    js show_minus
    jmp get_number

    show_minus:
         neg ax
         mov bx,ax
        mov dx,'-'
        mov ah,02h
        int 21h
        mov ax,bx
    get_number:                      
        xor dx,dx    
        div base
        add dx,30h                  
        push dx
        inc cx
        cmp ax,0
    jne get_number

    mov ah,02h
    cout_number:              
        pop dx
        int 21h                   
    loop cout_number

    call next_line
    pop dx
    pop cx 
    pop bx
    pop ax                     
    ret
cout endp



cout_Str proc
    push ax
    mov ah,09h
    int 21h 
    pop ax
    ret
cout_Str endp



cin proc
    push bx
    push cx
    push dx

    begin:
        xor cx,cx
        xor bx,bx
        mov ah,01h
        int 21h
        cmp al,'-'
        jne check_char
        mov cx,1
    cinChar:
        mov ah,01h
        int 21h
    check_char:
        xor ah,ah
        cmp al,13
        je endcin
        cmp al,8
        je pressed_reverse_delete
        cmp al,30h
        jb cinError
        cmp al,39h
        ja cinError
        sub al,30h
        xchg ax,bx
        mul base
        jc overflow
        add ax,bx
        xchg ax,bx
    jmp cinChar
    
    pressed_reverse_delete:
        call reverse_delete
        xchg ax,bx
        xor dx,dx
        div base
        xchg ax,bx        
    jmp cinChar
    
    cinError:
        mov ah,02h
        mov dl,8
        int 21h
        call reverse_delete
    jmp cinChar    
        
    overflow:
        call next_line    
        lea dx,overflow_mes
        call cout_Str
        call next_line
        xor bx,bx
        xor cx,cx
    jmp begin

    endcin:    
    cmp cx,1
    jne exit
    neg bx

exit:        
    mov ax,bx
    pop dx
    pop cx
    pop bx
    ret    
cin endp



reverse_delete proc
    push ax
    push dx
    mov ah,02h
    mov dl,32
    int 21h
    mov dl,8
    int 21h
    pop dx
    pop ax
    ret 
reverse_delete endp



next_line proc
    push dx
    lea dx,endline
    call cout_Str
    pop dx
    ret
next_line endp



start:
    mov ax,@data
    mov ds,ax

    lea dx, first_mes
    call cout_Str
    call next_line
    call cin
    call cout
    mov bx,ax
    jmp get_divisor

    error_divisor:
        lea dx,zero_mes
        call cout_Str
        call next_line

    get_divisor:
        lea dx, second_mes
        call cout_Str
        call next_line
        call cin
        cmp ax,0
    je error_divisor
    call cout

    xchg ax,bx
    xor dx,dx
    cwd
    idiv bx
    mov bx,dx

    lea dx,result_mes
    call cout_Str
    call next_line

    call cout

    mov ax,4c00h
    int 21h
end start