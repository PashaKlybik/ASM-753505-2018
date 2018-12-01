;Пользователь вводит строку, состоящую только из круглых скобок.
;Проверить, является ли данная скобочная последовательность корректной.

.model small
.stack 256
.data
    strForInput db 100 dup('$')
    inputStr db 'Write string that consist of ( & ) to check if this sequence is correct:', 13, 10, '$'
    true db 'Sequence is correct', 13, 10, '$'
    false db 'Sequence is incorrect', 13, 10, '$'
    condition dw ?
    status dw ?
    resultMessage db 'Result:', 13, 10, '$'
    errorMessage db 13, 10, 'String should consist only from ( & ), try again', 13, 10, '$'
.code

SrtInput proc ;proc for input of string
    push ax
    push si
    xor si, si
    readChars:
        mov ah, 01h
        int 21h
        cmp al, 13
        je toEnd
        cmp al, '('
        jne check
    continue:
        mov strForInput[si], al
        inc si
        cmp si, 99
        je toEnd
        jmp readChars
    check:
        cmp al, ')'
        je continue
        call Error
        jmp vstatus
    toEnd:
        mov strForInput[si], 10
        mov ax, 1
        mov status, ax; status is 1 - user makes valid input, 0 - invalid input
    vstatus:
        pop si
        pop ax
        ret
SrtInput endp

Restart proc ;proc to restart the program
    push si
    push ax
    xor si, si
    xor ax, ax
    fillLoop: ;dumping string to initial state
        mov al, '$'
        mov strForInput[si], al
        mov al, strForInput[si + 1]
        inc si
        cmp al, '$'
        je ending
        jmp fillLoop
    ending:
        mov ax, 0
        mov status, 0
        pop ax
        pop si
        ret
Restart endp

Error proc ;message for error
    push dx
    push ax
    mov dx, offset errorMessage
    mov ah, 09h
    int 21h
    call Restart
    pop ax
    pop dx
    ret
Error endp

CheckingStr proc; main task to check the sequence using stack
    push si
    push ax
    push cx
    xor si, si
    xor ax, ax
    xor cx, cx
    push 0; set condition when program stop checkin' parentheses
    checkLoop:
        lods strForInput
        cmp al, 10 ;condition when the end of the string
        je toTheEnd
        cmp al, '('
        jne popStack
        push ax
        inc cx
        jmp checkLoop
    popStack:
        pop ax
        cmp ax, 0
        je firstIsClosedParentheses
        dec cx
        jmp checkLoop
    toTheEnd:
        pop ax
        cmp ax, 0
        je return
    firstIsClosedParentheses:
        mov ax, 0; if sequence is incorrect
        mov condition, ax
        jmp exit
    return:
        mov ax, 1; if sequence is correct
        mov condition, ax
    exit:
        popLoop:
            pop ax
            loop popLoop
        pop cx
        pop ax
        pop si
        ret
CheckingStr endp

main:
    mov ax, @data
    mov ds, ax
    try: ;using status variable
        mov dx, offset inputStr
        mov ah, 09h
        int 21h
        mov ax, 0
        call SrtInput
        cmp ax, status
        jne next
        jmp try
    next:
        mov dx, offset resultMessage
        mov ah, 09h
        int 21h
        call CheckingStr
        xor ax, ax
        mov ax, condition
        cmp ax, 1
        je isTrue
        mov dx, offset false
        mov ah, 09h
        int 21h
        jmp goEnd
        isTrue:
            mov dx, offset true
            mov ah, 09h
            int 21h
        goEnd:
            mov ax, 4c00h
            int 21h
end main
