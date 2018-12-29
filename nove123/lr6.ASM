.model tiny
.code
.486                                    
org 100h 

start:
jmp initialization       

;новый обработчик прерывания клавиатуры
new_handle proc       
    pushF
    push ES
    mov  AX,40H 
    mov  ES,AX 
    xor AX, AX 
    IN  AL,60H
    cmp AL, 1Eh 
    jne b
    mov AL, 49
    jmp newHandler
    b:
    cmp AL, 30h 
    jne c
    mov AL, 50
    jmp newHandler
    c:
    cmp AL, 2Eh 
    jne d
    mov AL, 51
    jmp newHandler
    d:
    cmp AL, 20h 
    jne e
    mov AL, 52
    jmp newHandler
    e:
    cmp AL, 12h 
    jne old
    mov AL, 53
    newHandler: 
        mov  BX,1AH        
        mov  CX,ES:[BX]    
        mov  DI,ES:[BX]+2  
        cmp  CX,60
        je   CHECK      
        inc  CX   
        inc  CX            
        cmp  CX,DI
        je   EXIT
        jmp  insert        
        CHECK:
            cmp  DI,30        
            je   EXIT         
        insert:
            mov  ES:[DI],AL    
            cmp  DI,60         
            jne  NOWRAP        
            mov  DI,28         
        NOWRAP:
            ADD  DI,2          
            mov  ES:[BX]+2,DI  
	jmp EXIT

    old: 
        pop ES
        popf                      
        jmp DWORD PTR cs:old_handler 
        IRET
    exit:
        xor AX, AX
        mov AL, 20h
        OUT 20h, al 
        pop ES
        popf 
        IRET
new_handle ENDP

old_handler dd ?
	
initialization PROC
    mov AX, 3509h
    INT 21h
    mov WORD PTR old_handler, BX
    mov WORD PTR old_handler + 2, ES
    mov AX, 2509h
    mov DX, offset new_handle
    INT 21H
    mov DX, offset initialization
    INT 27H 
initialization ENDP
end start