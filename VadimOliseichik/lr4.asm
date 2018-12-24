.model small
 .386
 .stack 256
 .data 
     THRI dw 3 
     INDEX dw 0
     n dw 0
     a dw 0 
     b dw 0
     c dw 0 
     max db 200
     len db ?                     ;длина введенной строки
     iputstring db 200 dup('$')
     stringvowelLen db 12
     stringvowel db "AEIOUYaeiouy$"
     Message1 db "Starting line:$"
     Message2 db "End line:$"
 .code
 
    Search PROC 
        PUSH AX
        PUSH DX
        MOV DL, iputstring[SI+ 1] 
        CMP DL, ' '
        JNE repeat
        INC SI
        JMP exit 
        repeat:
        MOV DL, iputstring[SI]
        CMP DL,' '
        JZ exit 
        INC SI
        JMP repeat
        exit: 
        POP DX
        POP AX
        RET
    Search ENDP

    stringnew PROC
        PUSH AX
        PUSH DX
        MOV AH, 02h
        MOV DL, 13
        INT 21h
        MOV DL, 10
        INT 21h
        POP DX
        POP AX
    RET
    stringnew ENDP

    DeletionOfWordsBeginningWithAVowel PROC
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI	
        MOVZX CX, len 
        MOV c, CX
        XOR SI, SI    
        ;CALL Garbagecollection
        ;MOVZX CX, len 
        ;MOV c, CX
        ;XOR SI, SI    
        searchvowel:
            PUSH CX
            PUSH AX 
            ;поиск очередного символа в строке гласных
            MOV AL, iputstring[SI]
            LEA DI, stringvowel
            MOVZX CX, stringvowelLen
            REPNE SCASB
            JNE letternext
            checkBeginning:
            CMP SI, 0
            JZ beginningofword	
            MOV DL, iputstring[SI- 1] 
            CMP DL, ' '
            JNE letternext
            beginningofword:
            POP AX
            MOV a, SI
            CALL Search
            MOV b,SI
            MOV SI,a
            MOV AX,b 
            SUB AX,a
            ADD AX,1
            MOV b,AX 
            return:
            MOV AX, SI
            ADD AX,b 
            MOV a, SI
            MOV SI, AX
            MOV DL,iputstring[SI]
            MOV SI,a 
            MOV iputstring[SI], DL
            CMP c, SI
            JZ continue
            INC SI
            JMP return
            continue:
            MOV SI,0
            PUSH AX
            POP AX
            POP CX
        loop searchvowel
        JMP p	
        letternext:
        INC SI	
        POP AX
        POP CX
        loop searchvowel
        p:
        POP SI
        POP DX
        POP CX
        POP BX
    RET
    DeletionOfWordsBeginningWithAVowel ENDP

 main:
    MOV ax, @data
    MOV ds, ax
    MOV es, ax
    CALL stringnew 
    lea dx, Message1 
    mov ah, 09h 
    int 21h 
    CALL stringnew 
     ;ввод строки
    LEA DX, max
    MOV AH, 0aH
    INT 21h
    CALL stringnew 
    CALL DeletionOfWordsBeginningWithAVowel
    CALL DeletionOfWordsBeginningWithAVowel
    CALL stringnew 
    lea dx, Message2 
    mov ah, 09h 
    int 21h 
    CALL stringnew 
    MOV DX,offset iputstring
    MOV ah,09h
    INT 21h
    CALL stringnew 
    CALL stringnew 
    MOV ax, 4c00h
    INT 21h	
 end main 
