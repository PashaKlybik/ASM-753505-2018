LOCALS
.model small
.386
.stack 256
.data 
	errorMessage db "ERROR!$" 

	N=2
	arr1 dw 1,2,5,3,2,5,5,3,1
	arr dw 100 DUP(?)
	arr3 dw 4 dup(?)


;/////////////////////////////////
  dimension db ?
    array dw 9 dup (?)
    elementSize = 2
    handle dw 1
    enterDimensionMessage db "Please enter a dimension of the array: $"
    determinant db 100 dup (?)
    numberOfDeterminantDigits dw ?
    determinantMessage db "Determinant = $"
    matrixMessage db "Matrix:$"
    inputFileName db 'input.txt', 0
    outputFileName db 'output.txt', 0
    fileErrorMessage db 'Error with file', 13, 10, '$'
    number dw ?
    digit db ?

	
.code 

newline PROC		 ;переход на новую строку 
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


;///////////////////////////////////

inputArrayFromFile PROC
    PUSHA
    MOV AH,3dH
    LEA DX,inputFileName
    MOV AL,0
    INT 21h   
    MOV [handle],AX                               
    JNC @@fileIsOpen
    CALL fileError

    @@fileIsOpen:
        CALL readNumberFromFile
        MOV AX, number
        MOV dimension, AL

        MOV SI, 0 ;столбцы
        MOV BX, 0 ;строки
        MOVSX CX, [dimension]

        @@externalCycle:
            PUSH CX
            MOVSX CX, [dimension]
            MOV SI, 0
            @@iternalCycle:
                CALL readNumberFromFile
                MOV AX, [number]
                MOV arr[BX][SI], AX
                ADD SI, elementSize
            loop @@iternalCycle
            POP CX
            MOVSX DX, [dimension] ;BX += размерность_массива*размер_элемента
            IMUL DX, elementSize
            ADD BX, DX
        loop @@externalCycle

        MOV AH,3eH                               
        MOV BX,[handle]
        INT 21h
        JNC @@fileIsClose
        CALL fileError

    @@fileIsClose:
    POPA
RET
inputArrayFromFile ENDP

readNumberFromFile PROC
    PUSHA
    XOR BX, BX
    XOR SI, SI
    MOV [number], 0
    read:
        call isEndOfFile
        CMP AL, 0
        JZ endReading
        call readDigitFromFile
        CMP [digit], ' '
        JZ endReading
        CMP [digit], 0Ah
        JZ endReading
        CMP [digit], '-'
        JNZ notMin
        MOV SI, 1
        JMP read
        notMin:
            SUB [digit], 48
            MOV AX, 10
            MUL BX
            MOV BX, AX
            ADD BX, word ptr[digit]
    JMP read

    endReading:
    CMP SI, 0; если отрицательное - NEG
    JZ endPr
    NEG BX

    endPr:
    MOV [number], BX
    MOV AX, BX
    POPA
RET
readNumberFromFile ENDP

readDigitFromFile PROC
    PUSHA
    MOV AX, [handle]
    MOV BX,AX
    MOV AH,3fH
    LEA DX,digit
    MOV CX,1
    int 21h

    jnc @@fileIsRead
    call fileError

    @@fileIsRead:
    MOV AX, word ptr[digit]
    POPA
RET
readDigitFromFile ENDP

isEndOfFile PROC
    PUSH BX
    MOV AX, [handle]
    MOV BX,AX
    MOV AX,4406h
    int 21h
    POP BX
RET
isEndOfFile ENDP




fileError PROC
    LEA DX, fileErrorMessage
    MOV AH, 09h
    int 21h
    MOV ax, 4c00h
    INT 21h
fileError ENDP


;///////////////////////////////////



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
        ;LEA DX, errorMessage 
        ;mov AH, 09h 
        ;int 21h 
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


inputArr PROC
	push ax
	push cx
	push bx
	push si

	mov ax, cx
	mov bx, cx
	mul bx
	mov cx, ax
	xor ax, ax
	mov si, 0
cycle1:
	call input
	mov arr[si], ax
	inc si
	inc si
loop cycle1;
	
	pop si
	pop bx
	pop cx
	pop ax
	ret
inputArr ENDP


main: 
	mov ax, @data	
	mov ds, ax
	mov es, ax

	xor ax, ax

	
;	CALL inputArrayFromFile
;    	CALL outputArray



;	mov al, dimension
;	CBW
	
	call input
	mov cx, ax
	call inputArr
	

	cmp cx, 3
	je det3x3
	cmp cx, 2
	je det2x2
	cmp cx, 1
	je det1x1
det1x1:
	mov ax, arr[0][0]
	call CheckSymbol
	call newline
	jmp end1
det2x2:
	;считаем главную диагональ
	mov ax, arr[0][0]
	mov bx, arr[N*1][N*2]		 
	mul bx	
	mov cx, ax

	;считаем побочную диагональ
	mov ax,	arr[0][N*1]
	mov bx, arr[N*1][N*1]
	mul bx

	;находим определитель и выводим
	sub cx, ax
	mov ax,cx
	call CheckSymbol
	call newline
	
	jmp end1
det3x3:
	;главная диагональ
	mov ax, arr[N*3*0][N*0]
	mov bx, arr[N*3*1][N*1]
	mul bx
	mov bx, arr[N*3*2][N*2]
	mul bx
	mov cx, ax
	
	;1 треугольник
	mov ax, arr[N*3*1][N*0]	
	mov bx, arr[N*3*2][N*1]
	mul bx
	mov bx, arr[N*3*0][N*2]
	mul bx
	add cx, ax

	;2 треугольник
	mov ax, arr[N*3*2][N*0]	
	mov bx, arr[N*3*0][N*1]
	mul bx
	mov bx, arr[N*3*1][N*2]
	mul bx
	add cx, ax
	mov ax ,cx
	call CheckSymbol
	call newline
	
	;побочная диагональ
	mov ax, arr[N*3*0][N*2]	
	mov bx, arr[N*3*1][N*1]
	mul bx
	mov bx, arr[N*3*2][N*0]
	mul bx
	sub cx, ax

	;3 треугольник	
	mov ax, arr[N*3*0][N*1]	
	mov bx, arr[N*3*1][N*0]
	mul bx
	mov bx, arr[N*3*2][N*2]
	mul bx
	sub cx, ax
	
	;4 треугольник
	mov ax, arr[N*3*0][N*0]	
	mov bx, arr[N*3*2][N*1]
	mul bx
	mov bx, arr[N*3*1][N*2]
	mul bx
	sub cx, ax
	
	mov ax, cx
	call CheckSymbol
	call newline
	
	;вывод
	mov ax, cx
	call CheckSymbol
	


end1:	

        ;CALL outputInFile	
	mov ax, 4c00h
	int 21h
end main

	