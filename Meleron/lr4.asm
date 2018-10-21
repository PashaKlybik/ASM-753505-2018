.model small
.stack 256
.data
    buffer db 256 dup(?)
    endline db 13,10,'$'
    correct db 13,10,'correct$'
    incorrect db 13,10,'incorrect$'
.code
main:
    mov ax, @data
    mov ds, ax
    
    call enterString
    call printEndline
    mov ax, 4c00h
    int 21h
    
enterString proc ; Выход: cx - строка
  cycle:
    mov ah, 01h
    int 21h
    cmp al, '('
    je isRoundBracketOpened
	cmp al, '{'
    je isBraceOpened
	cmp al, '['
    je isSquareBracketOpened
	cmp al, ')'
	je isRoundBracketClosed
	cmp al, '}'
	je isBraceClosed
	cmp al, ']'
	je isSquareBracketClosed
    cmp al, 0dh
    je right
    jmp wrongInput
    
  isRoundBracketOpened:
    push 1
    jmp cycle
  isBraceOpened: 
    push 2
    jmp cycle
  isSquareBracketOpened: 
    push 3
    jmp cycle
  isRoundBracketClosed:
    pop bx
    cmp bx, 1
    je cycle
    jne mistake
  isBraceClosed:
    pop bx
    cmp bx, 2
    je cycle
    jne mistake
  isSquareBracketClosed:
    pop bx
    cmp bx, 3
    je cycle
    jne mistake
  right:
    push di
    lea di, correct
    call printString
    pop di
    ret
  mistake:
    push di
    lea di, incorrect
    call printString
    pop di
    ret
  wrongInput:
	call exitProg
enterString endp

printEndline proc
    push di
    lea di, endline
    call printString
    pop di
    ret
printEndline endp

printString proc
    push ax
    mov ah, 09h
    xchg dx, di
    int 21h
    xchg dx, di
    pop ax
    ret
printString endp

exitProg proc
    call printEndline
    mov ax, 4c00h
    int 21h
    ret
exitProg endp

end main

