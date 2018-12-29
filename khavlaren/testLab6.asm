.model small
.386
.stack 100h
.data
    maxLine db 254
    len db 0
    line db 254 dup('$')
    newLine db 10, 13, '$'
.code

PrintNewLine PROC
    PUSH AX
    PUSH DX
    LEA DX, newLine
    MOV AH, 09h
    INT 21h
    POP DX
    POP AX
    RET
PrintNewLine ENDP

main:

    MOV AX, @data
    MOV DS, AX
    MOV ES, AX
    
    ; Input.
    LEA DX, maxLine
    MOV AH, 0Ah
    INT 21h
    ; CALL PrintNewLine
    LEA DX, line
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine

    MOV ax, 4c00h
    INT 21h

end main