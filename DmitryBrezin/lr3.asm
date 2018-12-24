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

CheckSymbol PROC     ;проверка на знак, тип сравниваем с нулём выводим - если <0 убираем знак и выводим число. 

    push AX 
    test AX,AX 
    JNS out 
    push AX 
    mov DL,'-' 
    mov ah, 02h 
    int 21h 
    pop AX 
    neg AX 
    out: 
        CALL output 
        pop AX 
    ret 
CheckSymbol ENDP 

input PROC 
    push BX 
    push CX 
    push DX 
    push SI    

    mov AX, 0 
    mov BX, 0 
    mov CX, 0 
    mov DX, 0 
    mov SI, 0    
    enterSymbol: 
        mov ah, 01h 
        int 21h 
        cmp AL, 13; это enter тип 
        JZ stopInput 
        cmp AL, 8 
        JZ backspace 
        cmp AL, 45
        JZ check    ;проверка на минус

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
        JC error ;если вышли за границы

    JMP enterSymbol 
 
    check:        ;помечаем что число отрицательное
        mov SI, 1
    JMP enterSymbol

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
        cmp SI,1
        JZ  minus
        pop SI
        mov AX, BX 
        CALL range
        pop DX 
        pop CX 
        pop BX 
        ret

        minus:
            NEG BX
            mov AX, BX
            CALL range
            pop SI 
            pop DX 
            pop CX 
            pop BX 
        ret     
input ENDP 

;проверка на диапозон
range PROC
    push AX
    cmp AX,0
    JG module    ;если больше нуля то не меняем знак числа
    NEG AX 
    
    module:    
    cmp AX,32767
    JO error
    pop AX
ret
range ENDP

divide PROC
        
    push BX
    push DX

    cmp BX,0
    JZ error
    cmp AX,0
    JL negative
    
    mov DX,0
    IDIV BX
    pop DX
    pop BX
    ret
            
    negative:
        NEG AX
        mov DX,0
        IDIV BX
        NEG AX

    pop DX
    pop BX

ret
divide ENDP


main: 
    mov AX, @data 
    CALL input 
    mov CX, AX
    CALL CheckSymbol
    CALL newline 

    CALL input 
    mov BX, AX
    CALL CheckSymbol
    CALL newline 
    
    mov AX, CX
    CALL divide
    CALL CheckSymbol
    CALL newline
    mov ax, 4c00h 
    int 21h 
end main
