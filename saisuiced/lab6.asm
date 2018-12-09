;Перекрыть девятую функцию прерывания 21h таким образом, чтобы в выводимой строке маленькие буквы заменялись большими,
; а большие на маленькие.
CSEG segment
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG
org 80h
    cmdLength db ? ;cmd line lenght
    cmdLine db ? ;cmd line
org 100h
Start:

jmp init

Int_21h_proc proc
    cmp ah, 09h
    je itsOkayToBe9h
    jmp dword ptr cs:[Int_21h_vect]
    itsOkayToBe9h:
        push dx
        push di
        push si
        push es
        push ds
        pop es
        mov	di, dx
        mov si, dx
        veryCoolLoop:
            lodsb
            cmp al, '$'
            je finish
            cmp al, 'a'
            jl next
            cmp	al, 'z'
            jg ignore
            sub	al, 20h
            jmp ignore
        next:
            cmp al, 'A'
            jl ignore
            cmp	al, 'Z'
            jg ignore
            add	al, 20h
        ignore:
           stosb
           jmp veryCoolLoop
        finish:
            pushf
            call dword ptr cs:[Int_21h_vect]
            pop es
            pop si
            pop di
            pop dx
            iret
Int_21h_proc endp

installFlag dw 13579
Int_21h_vect dd ?
msgAlreadyInstalled db 'Already installed', 13, 10, '$'
msgCmdArgsErr db 'Command line arguments are invalid', 13, 10, '$'
msgNotInstalled db 'Not installed', 13,  10, '$'
msgUninstalled db 'Uninstalled', 13, 10, '$'
msgInstalled db 'Installed', 13, 10, '$'

init:
    mov ax, 3521h
    int 21h
    mov word ptr Int_21h_vect, bx
    mov word ptr Int_21h_vect + 2, es

    cmp cmdLength, 0
    je install
    cmp cmdLength, 3
    jne invalidParams

    cmp cmdLine[0], ' '
    jne invalidParams
    cmp cmdLine[1], '-'
    jne invalidParams
    cmp cmdLine[2], 'd'
    jne invalidParams

    cmp es:installFlag, 13579
    jne notInstalled

    ;if user wants to unistall handler
    mov dx, offset msgUninstalled
    mov ah, 09h
    int 21h
    mov ax, 2521h
    mov ds, word ptr es:Int_21h_vect + 2
    mov dx, word ptr es:Int_21h_vect
    int 21h
    mov ah, 4ch
    int 21h

    invalidParams:
        mov dx, offset msgCmdArgsErr
        jmp toEnd
    alreadyInstalled:
        mov dx, offset msgAlreadyInstalled
        jmp toEnd
    notInstalled:
        mov dx, offset msgNotInstalled
    toEnd:
        mov ah, 09h
        int 21h
        mov ah, 4ch
        int 21h
    install:
        cmp es:installFlag, 13579
        je alreadyInstalled
        mov ah, 09h
        mov dx, offset msgInstalled
        int 21h
        ;25h - installing of our handler
        mov ax, 2521h
        mov dx, offset Int_21h_proc; in ds:dx should be our handler
        int 21h
        ;27h - saving last byte of init label so its stays in memory
        mov dx, offset Init
        int 27h

    mov ah, 35h ;this function return adress of original handler
    mov al, 21h ;choosing for what interrupt we whant to get
    int 21h
    ;now in es:bx adress of 21h handler
    ;saving of old handler
    mov word ptr Int_21h_vect, bx
    mov word ptr Int_21h_vect + 2, es
    ;25h - installing of our handler
    mov ah, 25h
    mov al, 21h
    mov dx, offset Int_21h_proc; in ds:dx should be our handler
    int 21h
    ;27h - saving last byte of init label so its stays in memory
    mov dx, offset Init
    int 27h
CSEG ends
end Start
