.model small
.stack 256
.data
    buffer db 256 dup(?)
    endline db 13,10,'$'
    correct db 13,10,'correct$'
    incorrect db 13,10,'incorrect$'
	;errMessaage db 'Error!', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax
    
    call enterString
    call printEndline
    mov ax, 4c00h
    int 21h
    
enterString proc ; Выход: cx - строка
    xor cx, cx
lp:
    mov ah, 01h
    int 21h
    cmp al, '('
    je cxinc
	cmp al, ')'
	je cxdec
    cmp al, 0dh
    je result
    jmp err
    
cxinc:
    inc cx
    jmp lp
cxdec:
    dec cx
    cmp cx, 0
    jl mst
    jmp lp
result:
    cmp cx, 0
    jne mst
    je rgt
rgt:
    push di
    lea di, correct
    call printString
    pop di
    ret
mst:
    push di
    lea di, incorrect
    call printString
    pop di
    ret
err:
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

