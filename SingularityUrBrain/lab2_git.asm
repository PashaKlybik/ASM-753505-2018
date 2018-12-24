.model small
.stack 256
.data
    coeff dw 10
    inputDivndMess db 'Input the dividend: $'
    inputDivrMess db 'Input the divider: $'
    outputDivndMess db 'dividend=$'
    outputDivrMess db 'divider=$'
    resultMess db 'result(dividend/divider)=$'
    remainderMess db 'remainder=$'
    divByZeroMess db 13,10,'Division by zero!!!', 13, 10, '$'
    outOfRangeMess db 13,10,'OutOfRange exception!!!', 13, 10, '$'
.code                                                                                
    Input PROC
        push bx
        push cx
        push dx
        xor bx, bx
        xor cx, cx
    inputCycle:
        mov ah, 01h
        int 21h
        cmp al, 0dh  
        jz localExit
        cmp al, 08h
        jz backspace
        cmp al, 1Bh
        jz escape
        cmp al, '0'
        jb dels
        cmp al, '9'
        ja dels
        sub al, '0'
        xor ah, ah
        xchg ax, bx
        xor dx, dx
        mul [coeff]
        jc exception
        xchg ax, bx
        add bx, ax
        jc exception
        inc cx    ;need for backspace
    jmp inputCycle
    
    dels:    ;delete a symbol in cmd
        mov ah, 02h
        mov dl, 08h
        int 21h
        mov dl, 0h
        int 21h
        mov dl, 08h
        int 21h
        jmp inputCycle
                
    backspace:                
        mov ah, 02h        
        mov dl, 0h
        int 21h
        or cx, cx    ;check presence of symbols
        jz inputCycle
        mov dl, 08h
        int 21h
        
        mov ax, bx
        xor dx, dx
        div [coeff]      
        mov bx, ax
        
        dec cx
        jmp inputCycle
        
    escape:
        xor bx, bx    ;in progr
        inc cx
        mov ah, 02h
        delLoop:    ;in cmd
            mov dl, 08h
            int 21h
            mov dl, 0h
            int 21h
            mov dl, 08h
            int 21h
        loop delLoop 
        jmp inputCycle
            
    exception:
        mov dx, offset outOfRangeMess
        call WriteMess
        stc
        jmp exit
    localExit:
        mov ax, bx
        pop dx
        pop cx
        pop bx
        ret
    Input endp    
    
    OutputNumber PROC
        push ax             
        push cx
        push dx
        xor cx, cx      
        
    division:
        xor dx, dx
        div [coeff]
        push dx
        inc cx
        or ax, ax    
    jnz division
    
        mov ah, 02h
		outputLoop:
			pop dx
			add dl, '0'
			int 21h
		loop outputLoop
        mov dl, 0Ah    
        int 21h
    
        pop dx
        pop cx
        pop ax
        ret
    OutputNumber endp
    
    WriteMess PROC
        push ax
        mov ah, 09h
        int 21h
        pop ax
        ret
    WriteMess endp
    
main:
    mov ax, @data
    mov ds, ax
    
    mov dx, offset inputDivndMess
    call WriteMess
    call Input
    mov dx, offset outputDivndMess
    call WriteMess
    call OutputNumber
    
    mov dx, offset inputDivrMess
    call WriteMess    
    call Input
    or ax, ax        ;check div by 0
    jz dbzError
    mov dx, offset outputDivrMess
    call WriteMess
    call OutputNumber

    xor dx, dx
    xchg ax, bx
    div bx
    mov bx, dx
    
    mov dx, offset resultMess
    call WriteMess
    call OutputNumber
    mov dx, offset remainderMess
    call WriteMess
    mov ax, bx
    call OutputNumber
    jmp exit
    
    dbzError:
        mov dx, offset divByZeroMess
        call WriteMess
        stc
    exit:
        mov ax, 4c00h
        int 21h
end main      
