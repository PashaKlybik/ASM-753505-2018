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
    outOfRangeMess db 13,10,'OutOfRange outOfRangeException!!!', 13, 10, '$'
.code
    SignedInput PROC
        push bx
        push cx
        push dx
        push si
        xor bx, bx
        xor cx, cx
        xor dx, dx
        xor si, si
    inputCycle:
        or cx, cx
        jnz uncheckMinus    ;minus may be entered after incorrect input
        mov ah, 01h
        int 21h
        cmp al, '-'
        jnz unsignedInput
        inc si
        inc cx
    uncheckMinus:
        mov ah, 01h
        int 21h    
        
    unsignedInput:
        cmp al, 0dh 
        jnz noExitJump    ;localExit is too far
        jmp localExit  
    noExitJump:
        cmp al, 08h
        jz backspace
        cmp al, 1bh
        jz escape
        cmp al, '0'
        jb dels
        cmp al, '9'
        ja dels
        sub al, '0'
        xchg ax, bx
        xor dx, dx     
        mul [coeff]
        jc outOfRangeException
        xchg ax, bx
        xor ah, ah
        add bx, ax
        jc outOfRangeException
        inc cx    ;need for backspace
    jmp checkRange

    dels:    ;delete a symbol in cmd
        push dx
        mov ah, 02h
        mov dl, 08h
        int 21h
        mov dl, 0h
        int 21h
        mov dl, 08h
        int 21h
        pop dx
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
        or cx, cx
        jnz inputCycle
        xor si, si
        jmp inputCycle
    
    escape:
        xor bx, bx    ;in progr
        inc cx
        delLoop:    ;in cmd
            mov ah, 02h
            mov dl, 08h
            int 21h
            mov dl, 0h
            int 21h
            mov dl, 08h
            int 21h
        loop delLoop
        xor si, si
        jmp inputCycle
            
    checkRange:
        or si, si
        jz unsRangeCheck 
        cmp bx, 32768
        jna cycleJump
    unsRangeCheck:
        cmp bx, 32767
        ja outOfRangeException
    cycleJump:
        jmp inputCycle

    outOfRangeException:
        mov dx, offset outOfRangeMess
        call WriteMess
        stc
        jmp exit
        
    localExit:
        or si, si
        jz unsLocalExit
        neg bx
    unsLocalExit:
        mov ax, bx
        pop si
        pop dx
        pop cx
        pop bx
        ret
    SignedInput endp    
    
    SignedOutput PROC
        push ax                
        push cx
        push dx
        test ax, ax    ;check sign
        jns unsignedOutput
;if signed
        mov cx, ax
        mov ah, 02h          
        mov dl, '-'
        int 21h
        mov ax, cx
        neg ax
        
    unsignedOutput:
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
    SignedOutput endp
    
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
    call SignedInput
    mov dx, offset outputDivndMess
    call WriteMess
    call SignedOutput
    
    mov cx, ax    ;CX = dividend
    
    mov dx, offset inputDivrMess
    call WriteMess
    call SignedInput
    or ax, ax    ;check div by 0
    jz dbzException    

    cmp cx, -32768    ;-32768/-1 = 32768 --> cannot be placed in AX  
    jne continue
    cmp ax, -1
    jne continue
    jmp outOfRangeException
    
continue:
    mov dx, offset outputDivrMess
    call WriteMess
    call SignedOutput
    
    mov bx, ax    ;BX = divider
    mov ax, cx    ;AX = dividend
    cwd
    idiv bx    ;AX = res, DX = remainder 
;;;check remainder
    cmp dx, 32768
    jc noChange
    cmp bx, 32768
    jc dividendIsNeg
    sub dx, bx 
    inc ax
    jmp noChange
    
dividendIsNeg:
    add dx, bx
    dec ax
;;;
noChange:
    mov cx, dx    ;save remainder
    mov dx, offset resultMess
    call WriteMess
    call SignedOutput
    mov dx, offset remainderMess
    call WriteMess    
    mov ax, cx
    call SignedOutput
    jmp exit
    
dbzException:
    mov dx, offset divByZeroMess
    call WriteMess
    stc
exit:
    mov ax, 4c00h
    int 21h
end main
