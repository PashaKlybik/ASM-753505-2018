.MODEL  TINY
.CODE
        ORG 80h
cmd_len db ?
cmd_line db ?
        ORG 100h
start:
    jmp initialize

    bufferLen = 10
    upperMinusLower = 32
    buffer  db 10 dup ('a'), '$'
    oldHandlerPtr dd ?
    
intHandler proc far
    cmp ah, 09h
    jz newHandler
    jmp dword ptr cs:[oldHandlerPtr]
    
newHandler:
    push ax bx ds cx dx di si
    cli
    cld
    mov si, dx
    mov dx, offset buffer
    mov di, dx
    xor cx, cx
    mov cl, bufferLen
proccessing:
    cmp cx, 0
    je bufferIsFull
    lodsb
    cmp al, '$'
    jz endOfString
    cmp al, 'A'
    jc notLetter
    cmp al, 'z'
    ja notLetter
    cmp al, 'Z'
    jna toLower
    cmp al, 'a'
    jnc toUpper
    jmp notLetter
toLower:
    add al, upperMinusLower
    jmp notLetter
toUpper:
    sub al, upperMinusLower
notLetter:
    mov cs:[di], al
    inc di
    loop proccessing
bufferIsFull:
    push ds
    push cs
    pop ds
    pushf
    call cs:oldHandlerPtr
    pop ds
    lea di, buffer
    mov cl, bufferLen
    jmp proccessing
endOfString:
    mov byte ptr cs:[di], '$'
    push ds
    push cs
    pop ds
    pushf
    call cs:oldHandlerPtr
    pop ds
    sti
    pop si di dx cx ds bx ax
    iret
intHandler endp

initialize proc near
    mov ax, 3521h
    int 21h
    cmp byte ptr cmd_len, 2
    jnz incorrectInputError
    cmp byte ptr cmd_line[1], 'i'
    jz install
    cmp byte ptr cmd_line[1], 'd'
    jz unistall
    jmp incorrectInputError
    
install:
    cmp es:flag, 12123
    jz installError
    mov flag, 12123
    mov word ptr oldHandlerPtr, bx
    mov word ptr oldHandlerPtr + 2, es
    ;mov ds, offset seg oldHandlerPtr
    mov dx, offset intHandler
    mov ax, 2521h
    int 21h
    mov dx, offset initialize
    int 27h
    
unistall:
    cmp es:flag, 12123
    jnz uninstallError
    mov ax, 2521h
    mov dx, word ptr es:oldHandlerPtr
    mov ds, word ptr es:oldHandlerPtr + 2
    int 21h
    jmp endProgram
    
incorrectInputError:
    lea dx, errorMessage
    mov ah, 09h
    int 21h
    jmp endProgram
    
installError:
    lea dx, installedMessage
    mov ah, 09h
    int 21h
    jmp endProgram
    
uninstallError:
    lea dx, uninstallErrorMessage
    mov ah, 09h
    int 21h
    jmp endProgram
    
endProgram:
    mov ah, 4ch
    int 21h
    
    flag dw 7149
    installedMessage db "Already installed!", 10, '$'
    errorMessage db "Error! Use 'i' to install, 'd' to delete!", 10, '$'
    uninstallErrorMessage db "Error! Nothing to delete!", 10, '$'
initialize endp
end start
