.model tiny
.code
.186
org 100h
Start:
    jmp Init

    Int21hProc proc

    cmp ah, 09h
    je Is09h

    jmp dword ptr cs:[Int_21h_vect]    

Is09h:
    pushf
    push DX
    push CX
    push SI
    push DI
    pysh AX
    push CS
    pop ES

    CLD
    mov SI, DX
    nextSymbol:
        LODSB

        cmp AL, 24h
        je exit

        lea DI, Vowels
        scan:

        mov CX, 10
        repne    SCASB
        je found

        mov DX, [SI-1]
        mov AH, 02h
        int 21h

        found:
        jmp nextSymbol
    exit:

    pushf
    call dword ptr cs:[Int_21h_vect]

    sti
    pop AX
    pop DI
    pop SI
    pop CX
    pop DX
    popf
    iret


    Int_21h_vect dd ?
    Vowels db "aeiouAEIOU"
    Int21hProc endp

Init:
    mov AH, 35h
    mov AL, 21h
    int 21h

    mov word ptr Int_21h_vect, BX
    mov word ptr Int_21h_vect+2, ES

    mov AX, 2521h
    mov DX, offset Int21hProc
    int 21h

    mov DX, offset Init
    int 27h

end Start