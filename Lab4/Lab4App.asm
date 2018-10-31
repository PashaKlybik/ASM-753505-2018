.model small
.stack 100h
.data
    string db 255,0,256 dup (0)
    strCorrectAnswer db 'Correct string $'
    strNotCorrectAnswer db 'Incorrect string $'
    smthGoingWrong db 'Somphing going wrong:( $'
    stackCheck dw 7
.code

main proc
    mov     ax,     @data
    mov     ds,     ax
    
    call inputAndCheck
    
    mov dx,offset smthGoingWrong 
    mov ah,09h
    int 21h
    mov ax,4c00h
    int 21h
main endp

endl proc
    push ax
    push dx
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret
endl endp 

notCorrectProc proc
    call endl
    mov dx,offset strNotCorrectAnswer 
    mov ah,09h
    int 21h
    mov ax,4c00h
    int 21h
notCorrectProc endp

correctProc proc
    call endl
    mov dx,offset strCorrectAnswer 
    mov ah,09h
    int 21h
    mov ax,4c00h
    int 21h
    correctProc endp

inputAndCheck proc
    push ax
    push bx
    push cx
    push dx
    push si

    push 7
    mov ah,0ah
    lea dx,string
    int 21h 

    mov si,offset string+2
    mov cl,string[1]
    cld
    strLoop:
        lodsb
        cmp al,'('
        je roundBracketOpened
        cmp al,'{'
        je braceBracketOpened
        cmp al, '['
        je squareBracketOpened
        cmp al, ')'
        je roundBracketClosed
        cmp al, '}'
        je braceBracketClosed
        cmp al, ']'
        je squareBracketClosed

        roundBracketOpened:
        push 1
        jmp endCycle

        braceBracketOpened: 
        push 2
        jmp endCycle

        squareBracketOpened: 
        push 3
        jmp endCycle
    
        roundBracketClosed:
        pop bx
        cmp bx, 1
        je endCycle
        call notCorrectProc
        
        braceBracketClosed: 
        pop bx
        cmp bx,2
        je endCycle
        call notCorrectProc

        squareBracketClosed:
        pop bx
        cmp bx,3
        je endCycle
        call notCorrectProc

        endCycle:
    loop strLoop
    
    pop bx;
    cmp bx,[stackCheck]
    je correctCheck
    call notCorrectProc
    
    correctCheck:
    call correctProc
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
inputAndCheck endp
end main