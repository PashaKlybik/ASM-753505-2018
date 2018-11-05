.model small
 .386
 .stack 256
 .data
     n dw 0
     a dw 0 
     b dw 0
     c dw 0 
     max db 200
     len db ?   ;длина введенной строки
     iputstring db 200 dup('$')
     stringvowelLen db 12
     stringvowel db "AEIOUYaeiouy$"
     Message1 db "Starting line:$"
     Message2 db "End line:$"
 .code

    Garbagecollection PROC 
        PUSH AX 
        PUSH DX
        PUSH BX 
        PUSH CX 
        PUSH SI 
        MOV CX, c
        MOV SI,0
        garbage:
        MOV DL, iputstring[SI]
        CMP DL,'a'
        JC zamena
        CMP DL,'z'
        JZ finish
        CMP DL,'z' 
        JC menshezz
        JMP zamena
        menshezz:
        JMP FINISH
        ZAMENA:
        zamena:
        CMP DL,'A'
        JC ZAMENAA
        CMP DL,'Z'
        JZ FINISH
        CMP DL,'Z' 
        JC FINISH
        ZAMENAA:
        CMP DL,"'" 
        JZ LABLE 
        JMP LABLE1
        LABLE:
        MOV DL, iputstring[SI-1] 
        CMP DL,'a'
        JC LABLE1
        CMP DL,'z'
        JZ finish
        CMP DL,'z' 
        JC menshezzZ
        JMP LABLE1
        menshezzZ:
        JMP FINISH
        LABLE1:
        cmp dl,'I'
        jz FINISH
        MOV DL,' '
        MOV iputstring[SI],DL 
        FINISH: 
        finish:
        INC SI
        loop garbage 
        MOV DL, iputstring[SI]
        MOV DL,' '
        MOV iputstring[SI],DL
        POP AX 
        POP DX
        POP BX 
        POP CX 
        POP SI
        RET
    Garbagecollection ENDP

    GarbageT PROC 
        PUSH AX 
        PUSH DX
        PUSH BX 
        PUSH CX 
        PUSH SI 
        MOV AX, c
        SUB AX,THRI 
        MOV CX, AX
        MOV SI,0
        garbageTTR:
        MOV DL, iputstring[SI]
        CMP DL,' '
        JNZ FINISHT 
        MOV DL, iputstring[SI+1]
        CMP DL,' '
        JNZ FINISHT 
        MOV DL, iputstring[SI+2]
        CMP DL,' '
        JNZ FINISHT
        MOV INDEX,SI  
        JMP KON
        FINISHT: 
        INC SI
        loop garbageTTR  
        JMP H
        KON:
        MOV AX, c
        SUB AX,INDEX
        MOV CX, AX
        MOV SI, INDEX
        GFR:
        MOV DL, iputstring[SI]
        MOV DL,' '
        MOV iputstring[SI],DL
        INC SI
        LOOP GFR
        H:
        POP AX 
        POP DX
        POP BX 
        POP CX 
        POP SI
        RET 
    GarbageT ENDP

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
        CALL Garbagecollection
        MOVZX CX, len 
        MOV c, CX
        XOR SI, SI    
        searchvowel:
            PUSH CX
            PUSH AX 
            ;поиск символа в строке гласных
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
    ;ввожу строчку
    LEA DX, max
    MOV AH, 0aH
    INT 21h
    CALL stringnew 
    CALL DeletionOfWordsBeginningWithAVowel
    CALL Garbagecollection
    CALL GarbageT
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
