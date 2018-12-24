.MODEL TINY
.DATA
    argExceptionMess db 'Incorrect argument!!!', 13, 10, '$'
    handlerInstallExceptionMess db 'The handler is already installed!!!', 13, 10, '$'
    handlerRemoveExceptionMess db 'The handler is not installed yet!!!', 13, 10, '$'
.CODE
org 80h
    cmdLen db ?
    cmdLine db ?
org 100h
Start:
    jmp init
    int9hVec dd ?
    f1 db 'HELP'
    f2 db 'SAVE'
    f3 db 'OPEN'
    f4 db 'EDIT' 
    f5 db 'COPY'
    installFlag dw 7149
    
Int09hProc proc
    push ax bx cx dx
    push ds 
    
    xor ax, ax 
    in  al, 60h   ;scan-code
    cmp al, 3Bh   ;F1
    jl standartkey
    cmp al, 3Fh      ;F5
    jg standartkey
    jmp replaceKey
    standartkey:
    pop ds
    pop dx cx bx ax
    jmp dword ptr cs:[int9hVec]
replaceKey:
    push cs      ;need for segment data (ds:dx)
    pop ds
    
    mov cx, 4
    cmp al, 3Bh
    jnz nof1
    mov bx, offset [f1]
    jmp fCycle
    nof1:
    cmp al, 3Ch
    jnz nof2
    mov bx, offset [f2]
    jmp fCycle
    nof2:
    cmp al, 3Dh
    jnz nof3
    mov bx, offset [f3]
    jmp fCycle
    nof3:
    cmp al, 3Eh
    jnz nof4
    mov bx, offset [f4]
    jmp fCycle
    nof4:
    mov bx, offset [f5]
    
    fCycle:            
        push cx
        mov ah, 05h
        mov cl, byte ptr [bx]
        int 16h                    ;write in the buff of the keyboard
        inc bx
        pop cx
    loop fCycle
    
    mov al, 20h  ;need for hw ints (IRQ1)
    out 20h, al  
    pop ds
    pop dx cx bx ax
    iret
    ;jmp dword ptr cs:[int9hVec]
Int09hProc endp
;;;;;;;;a temp part
init:
    mov ax, 3509h     
    int 21h                            ;es:bx = vector(09h)
    mov word ptr int9hVec, bx        ;save the adress of a standartkey interrupt(segment + offset)
    mov word ptr int9hVec+2, es        
    
    cmp cmdLen, 0
    je install
    cmp cmdLen, 3
    jne argException
    cmp cmdLine[0], ' '
    jne argException
    cmp cmdLine[1], '-'                 
    jne argException
    cmp cmdLine[2], 'd'
    jne argException
    jmp remove
argException:                    
    mov dx, offset argExceptionMess
    call WriteMessExit
install:
    cmp es:installFlag, 7149     ;check my handler
    je handlerInstallException
    mov ax, 2509h                 ;set my handler
    mov dx, offset Int09hProc                    
    int 21h
    jmp exit
handlerInstallException:                            
    mov dx, offset handlerInstallExceptionMess
    call WriteMessExit
remove:
    cmp es:installFlag, 7149        ;check handler
    jne handlerRemoveException
    cli                                
    mov ax, 2509h                    ;set old handler
    mov ds, word ptr es:int9hVec+2
    mov dx, word ptr es:int9hVec
    int 21h                                    
    sti
    mov ah, 4ch
    int 21h
handlerRemoveException:                                    
    mov dx, offset handlerRemoveExceptionMess
    call WriteMessExit
    
WriteMessExit proc
    mov ah, 09h
    int 21h
    mov ah, 4ch
    int 21h
WriteMessExit endp

exit:
    mov dx, offset init
    int 27h                        ;save prog from 0000h to dx (last byte)
end Start 
