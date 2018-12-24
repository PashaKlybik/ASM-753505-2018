.model small 
.stack 256 
.data 
    errorMessage db "ERROR!$" 
.code 

newline PROC         ;переход на новую строку 
    push AX 
    push DX 
    MOV AH, 02h 
    MOV DL, 13 
    int 21h 
    MOV DL, 10 
    int 21h 
    pop DX 
    pop AX 
    RET 
newline ENDP 

output PROC         ;функция вывода 
    push AX 
    push BX 
    push CX     
    push DX 
    mov CX,0 
    mov BX,10 

    cycleDivision:         ;разбиваем наше число на цифры и кидаем в стек 
        CMP AX,10 
        JC exit 
        mov DX, 0 
        div BX 
        inc CX 
        push DX 
    JMP cycleDivision 

    exit: 
        push AX 
        inc CX 

    cycleOutput:     ;достаем из стека наше число 
        pop DX 
        add DX,48 
        mov ah, 02h 
        int 21h 
    LOOP cycleOutput 

    pop DX 
    pop CX 
    pop BX 
    pop AX 
    ret 
output ENDP 



input PROC 
    push BX 
    push CX 
    push DX 
    
    mov AX, 0 
    mov BX, 0 
    mov CX, 0 
    mov DX, 0 
    
    enterSymbol: 
        mov ah, 01h 
        int 21h 
        cmp AL, 13; это enter тип 
        JZ stopInput 
        cmp AL, 8 
        JZ backspace 

        ;проверяем на цифру 
        sub AL,48 
        cmp AL,10 
        JNC error 

        mov CL, AL 
        mov AX, 10 
        mul BX 
        JC error ;если вышли за границы 
        mov BX,AX         
        add BX, CX 
        JC error ;опять выход за границы 

    JMP enterSymbol 
     
    ;сообщение об ошибке
    error: 
        CALL newline
        LEA DX, errorMessage 
        mov AH, 09h 
        int 21h 
        mov ax, 4c00h 
        int 21h 
            
    ;удаление символа обрабатываем 
    backspace: 
        push AX 
        push DX 

        ;ставим пробел 
        mov DL,' ' 
        mov AH, 02h 
        int 21h 

        ;сдвигаем курсор назад
        mov DL,8 
        mov AH, 02h 
        int 21h 
    
        mov AX,BX 
        cmp AX,10 
        JNC continue 

        mov BX,0 
        pop DX 
        pop AX 
    JMP enterSymbol 
    
    continue: 
        mov DX, 0 
        mov BX,10 
        div BX 
        mov BX,AX 
        pop DX 
        pop AX 
        
    JMP enterSymbol 

    ;конец ввода 
    stopInput: 
        mov AX, BX 
        pop DX 
        pop CX 
        pop BX 

ret     
input ENDP 

;деление беззнаковое
divide PROC
        
    push BX
    push DX

    cmp BX,0
    JE error
    mov DX,0
    DIV BX
    
    pop DX
    pop BX

ret
divide ENDP

main: 
    mov AX, @data 
    CALL input 
    mov CX, AX
    CALL output
    CALL newline 

 
    CALL input 
    mov BX, AX
    CALL output
    CALL newline
    
    mov AX, CX
    CALL divide
    CALL output
    CALL newline

    mov ax, 4c00h 
    int 21h 
end main
