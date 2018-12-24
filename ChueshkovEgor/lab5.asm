LOCALS
.model small
.386
.stack 256
.data
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

newline proc
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
newline endp

output proc
    push ax
    push bx
    push cx
    push dx
    mov cx, 0 
    mov bx, 10
    cmp ax, 0
    jns cycleRestToStack  
    push ax
    push dx 
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop dx
    pop ax
    neg ax
cycleRestToStack:
    cmp ax, 10
    jc exit
    mov dx, 0
    div bx
    push dx
    inc cx
    jmp cycleRestToStack
exit:		
    push ax
    inc cx		
cycleOutputStack:		
    pop dx	
    add dx, 48
    mov ah, 02h
    int 21h
    loop cycleOutputStack	
    pop dx
    pop cx
    pop bx
    pop ax
    ret
output endp

inputArrayFromFile proc
    pusha
    mov ah, 3dh
    lea dx, inputFileName
    xor al, al
    int 21h   
    mov [handle], ax                               
    jnc @@fileIsOpen
    call fileError
    @@fileIsOpen:
        call readNumberFromFile
        mov ax, number
        mov dimension, al
        mov si, 0 ;столбцы
        mov bx, 0 ;строки
        movsx cx, [dimension]
        @@externalCycle:
            push cx
            movsx cx, [dimension]
            mov si, 0
            @@iternalCycle:
                call readNumberFromFile
                mov ax, [number]
                mov array[bx][si], ax
                add si, elementSize
            loop @@iternalCycle
            pop cx
            movsx dx, [dimension] 
            imul dx, elementSize
            add bx, dx
        loop @@externalCycle
        mov ah, 3eh                               
        mov bx, [handle]
        int 21h
        jnc @@fileIsClose
        call fileError
    @@fileIsClose:
    popa
    ret
inputArrayFromFile endp

readNumberFromFile proc
    pusha
    xor bx, bx
    xor si, si
    mov [number], 0
read:
    call isEndOfFile
    cmp al, 0
    jz endReading
    call readDigitFromFile
    cmp [digit], ' '
    jz endReading
    cmp [digit], 0ah
    jz endReading
    cmp [digit], '-'
    jnz notMin
    mov si, 1
    jmp read
notMin:
    sub [digit], 48
    mov ax, 10
    mul bx
    mov bx, ax
    add bx, word ptr[digit]
    jmp read
endReading:
    cmp si, 0
    jz endPr
    neg bx
endPr:
    mov [number], bx
    mov ax, bx
    popa
    ret
readNumberFromFile endp

readDigitFromFile proc
    pusha
    mov ax, [handle]
    mov bx, ax
    mov ah, 3fh
    lea dx, digit
    mov cx, 1
    int 21h
    jnc @@fileIsRead
    call fileError
    @@fileIsRead:
    mov ax, word ptr[digit]
    popa
    ret
readDigitFromFile endp

isEndOfFile proc
    push bx
    mov ax, [handle]
    mov bx, ax
    mov ax, 4406h
    int 21h
    pop bx
    ret
isEndOfFile endp

outputArray proc
    pusha
    lea dx, matrixMessage
    mov ah, 09h
    int 21h
    call newline
    mov si, 0 ;столбцы
    mov bx, 0 ;строки
    movsx cx, [dimension]
    @@externalCycle:
        push cx
        movsx cx, [dimension]
        mov si, 0
        @@iternalCycle:
            mov dx, 9
            mov ah, 02h
            int 21h
            mov ax, array[bx][si]
            call output
            add si, elementSize
            loop @@iternalCycle
                pop cx
                movsx dx, [dimension] 
                imul dx, elementSize
                add bx, dx
                call newline
        loop @@externalCycle
    popa
    ret
outputArray endp

outputDeterminant proc
    pusha
    push ax
    lea dx, determinantMessage
    mov ah, 09h
    int 21h
    pop ax
    call output
    popa
    ret
outputDeterminant endp

matrix2x2 proc
    push dx
    mov ax, array[0][0]
    imul ax, array[elementSize*2][elementSize]
    mov dx, array[0][elementSize]
    imul dx, array[elementSize*2][0]
    sub ax, dx
    pop dx
    ret
matrix2x2 endp

matrix3x3 proc
    push dx
    mov ax, array[0][0]
    imul ax, array[elementSize*3][elementSize]
    imul ax, array[elementSize*6][elementSize*2]
    mov dx, array[0][elementSize]
    imul dx, array[elementSize*3][elementSize*2]
    imul dx, array[elementSize*6][0]
    add ax, dx
    mov dx, array[0][elementSize*2]
    imul dx, array[elementSize*3][0]
    imul dx, array[elementSize*6][elementSize]
    add ax, dx
    mov dx, array[0][elementSize*2]
    imul dx, array[elementSize*3][elementSize]
    imul dx, array[elementSize*6][0]
    sub ax, dx
    mov dx, array[0][0]
    imul dx, array[elementSize*3][elementSize*2]
    imul dx, array[elementSize*6][elementSize]
    sub ax, dx
    mov dx, array[0][elementSize]
    imul dx, array[elementSize*3][0]
    imul dx, array[elementSize*6][elementSize*2]
    sub ax, dx
    pop dx
    ret
matrix3x3 endp

convertDeterminantToString proc
    pusha
    mov numberOfDeterminantDigits, 0
    xor si, si
    xor cx, cx
    cmp ax, 0
    jge convert
    mov determinant[SI],'-'
    mov numberOfDeterminantDigits, 1
    inc si
    neg ax
convert:
    inc cx
    xor dx, dx
    mov bx, 10
    div bx
    add dx, '0'
    push dx
    test ax, ax
    jnz convert
    add numberOfDeterminantDigits, cx
putDigitsToString:
    pop dx
    mov determinant[si], dl
    inc si
    loop putDigitsToString
    popa
    ret
convertDeterminantToString endp

outputInFile proc
    pusha
    push ax
    mov ah, 3ch
    xor cx, cx
    lea dx, outputFileName
    int 21h
    jnc @@fileIsOpen
    call fileError
    @@fileIsOpen:
        mov [handle], ax
        mov bx, ax
        lea dx, determinantMessage
        mov ah, 40h
        mov cx, 14
        int 21h
        pop ax
        call convertDeterminantToString
        lea dx, determinant
        mov ah, 40h
        mov cx, numberOfDeterminantDigits
        int 21h
        jnc @@output
        call fileError
        @@output:
            mov ah, 3eh
            mov bx, [handle]
            int 21h
            jnc @@fileIsClose
            call fileError
            @@fileIsClose:
    popa
    ret
outputInFile endp

fileError proc
    lea dx, fileErrorMessage
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h
fileError endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call inputArrayFromFile
    call outputArray
    cmp [dimension], 1
    jnz determinant2x2
    mov ax, array[0][0]
    jmp endProgram
determinant2x2:
    cmp [dimension], 2
    jnz determinant3x3
    call matrix2x2
    jmp endProgram
determinant3x3:
    call matrix3x3
endProgram:
    call outputDeterminant
    call outputInFile	
    mov ax, 4c00h
    int 21h
end main