.model small
.stack 100h
.data
rows dw ?
colums dw ?
matrix dw 100 dup(?) ;10[max rows] * 10[max colums]
i dw ?
count dw ?
buffer db 910 dup('$') ;(8[max length of num + sign] * 10[max colums] + (10[max colums] - 1) * 1[delimiter character]) + 2[enter]) * 10[max rows]
file_name db 'lab5.txt',0
ten dw 10
two dw 2
newLine db 10,13,'$'
errorMsg db 10, 13,"Input error!", 10, 13, '$'
repeatInput db 10, 13,"Repeat input!", 10, 13, '$'
pak     db 'Press any key...$'
numOfRows db 'Enter number of rows:$'
numOfColums db 'Enter number of colums:$'
fileErr db 'File error!$'
handle    dw ?
lengthOfNum dw ?
max dw 32768
min dw 32767
.code

PrintStr PROC
    push AX
    mov AH, 09h
    int 21h
    pop AX
    ret
PrintStr ENDP

TenInDegreeAX PROC
    cmp AX, 0
    JZ flag1
    push CX
    mov CX, AX
    mov AX, 1
    cycle1:
        mul ten
    LOOP cycle1
    pop CX
    jmp flag2
    flag1:
        mov AX, 1
    flag2:
    ret
TenInDegreeAX ENDP

OpenFile PROC
    push AX
    push CX
    push DX

    xor AX, AX
    mov AH, 3Dh              
    lea DX, file_name                     
    int 21h
    JNC openErr
        call EndWithFileErr
    openErr:
    mov [handle], AX

    pop DX
    pop CX
    pop AX
    ret
OpenFile ENDP

CloseFile PROC
    push AX
    push BX
    push DX

    mov AH, 3Eh 
    mov BX, handle
    lea DX, file_name                     
    int 21h
    JNC closeErr
        call EndWithFileErr
    closeErr:
    pop DX
    pop BX
    pop AX
    ret
CloseFile ENDP

EndWithFileErr PROC
    push AX
    push DX

    lea DX, fileErr
    call PrintStr

    lea DX, newLine
    call PrintStr
 
    lea DX, pak
    call PrintStr
    
    mov AH, 08h
    int 21h

    lea DX, newLine
    call PrintStr
 
    mov AX,4c00h
    int 21h 
    
    pop DX
    pop AX
    ret
EndWithFileErr ENDP

CreateMass proc
    push DI
    push CX
    push BX
    push DX
    push AX

    mov BX, 0
    mov DX, 0
    mov CX, 0
    mov i, 0
    mov count, 0
    mov rows, 0
    mov colums, 0
    readSymbol:
        mov AL, [SI]            ;character reading
        
        cmp AL, 2Dh
        jnz isMinus1
            mov BX, 1
            push 2Dh
            inc CX
            inc SI
            jmp readSymbol
        isMinus1:

        cmp AL, 9
        jnz isDelimiterCharacter1
            inc count
            inc SI
            jmp addDigitsToNum
        isDelimiterCharacter1:
        cmp AL, 20h
        jnz isDelimiterCharacter2
            inc count
            inc SI
            jmp addDigitsToNum
        isDelimiterCharacter2:


        cmp AL, 13
            jnz isEnter
            inc rows
            inc count
            add SI, 2
            jmp addDigitsToNum
        isEnter:

        cmp AL, 24h
        jz exit

        mov AH, 0            ;adding a digit to the stack
        sub AL, '0'
        push AX

        inc CX            ;count of the number of digits in the number
        inc SI
    jmp readSymbol

    addDigitsToNum:

        mov lengthOfNum, CX
        mov DI, 0

    addToNum:                    ;Adding number to the AX
        pop BX                ;extract a digit from the stack

        cmp BX, 2Dh
        jnz isMinus2
            neg DI
            jmp stopAdding
        isMinus2:

        mov AX, lengthOfNum        
        sub AX, CX    
        xor DX, DX
        call tenInDegreeAX
        
        mul BX
        add DI, AX
    LOOP addToNum

    stopAdding:
    mov AX, i
    mov BX, 2
    mul BX
    mov BX, AX
    mov matrix[BX], DI
    inc i
    xor CX, CX
    jmp readSymbol

    exit:
    mov AX, count
    div rows
    mov colums, AX

    pop AX
    pop DX
    pop BX
    pop CX
    pop DI
    ret
CreateMass endp

ReadFile PROC
    push AX
    push BX
    push CX
    push DX
    push SI

    call OpenFile

    mov CX, 910
    mov BX, handle
    mov AH, 3Fh  
    lea DX, buffer   
    int 21h
    
    lea SI, buffer

    call CreateMass

    call CloseFile

    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
ReadFile ENDP

PrintAX proc
    push AX
    push CX
    push DX
    push SI

    mov SI, 0
    mov CX, 0
    test AX, AX
    jns isNegNum
        neg AX
        mov SI, 1
    isNegNum:
    pushDigit:                ;adding a character to a number on the stack 
        mov DX,0
        div ten
        add DX, '0'
        push DX
        inc CX
        cmp AX, 0
    JNZ pushDigit
    
    cmp SI,1
    jnz isNegNum1
        inc CX
        push 2Dh
    isNegNum1:

    printDigit:                ;character printing
        pop DX
        mov AH, 02h
        int 21h
    LOOP printDigit

    pop SI
    pop DX
    pop CX
    pop AX
    ret
PrintAX endp

PrintMatrix PROC
    push AX
    push CX
    push SI

    mov CX, rows
    mov SI, 0
    cycleRows1:
        push CX
        mov CX, colums
        cycleColums1:
            mov AX, matrix[SI]
            call PrintAX
            add SI, two
            mov DL, 09h
            mov AH, 02h
            int 21h
        LOOP cycleColums1
        pop CX
        lea DX, newLine
        call PrintStr
    LOOP cycleRows1

    pop SI
    pop CX
    pop AX
    ret
PrintMatrix ENDP

Task PROC
    push AX
    push BX
    push CX
    push SI

    mov CX, rows
    mov count, 0
    mov BX, max
    cycleRows2:
        push CX
        mov AX, rows
        sub AX, CX
        mul colums
        mul two
        mov SI, AX
        mov CX, rows
        sub CX, count
        cycleColums2:
            mov AX, matrix[SI]

            test AX, AX
            jns isNegNum2
                test BX, BX
                jns isNegNum3
                    cmp AX, BX
                    jc cmp1
                        mov BX, AX
                    cmp1:
                    jmp continue1
                isNegNum3:
                jmp continue1
            isNegNum2:
                test BX, BX
                js isPosNum1
                    cmp AX, BX
                    jc cmp2
                        mov BX, AX
                    cmp2:
                    jmp continue1
                isPosNum1:
                mov BX, AX
                
            continue1:
            add SI, 2
        LOOP cycleColums2
        pop CX
        inc count
    LOOP cycleRows2
    mov max, BX

    mov CX, rows
    mov count, 1
    mov BX, min
    cycleRows3:
        push CX
        mov AX, rows
        sub AX, CX
        mul colums
        add AX, colums
        sub AX, count
        mul two
        mov SI, AX
        mov CX, count
        cycleColums3:
            mov AX, matrix[SI]

            test AX, AX
            jns isNegNum4
                test BX, BX
                jns isNegNum5
                    cmp AX, BX
                    jnc cmp3
                        mov BX, AX
                    cmp3:
                    jmp continue2
                isNegNum5:
                mov BX, AX
                jmp continue2
            isNegNum4:
                test BX, BX
                js isPosNum2
                    cmp AX, BX
                    jnc cmp4
                        mov BX, AX
                    cmp4:
                    jmp continue2
                isPosNum2:
                
            continue2:
            add SI, 2
        LOOP cycleColums3
        pop CX
        inc count
    LOOP cycleRows3
    mov min, BX

    mov AX, max
    sub AX, min
    lea DX, newLine
    call PrintStr
    call PrintAX
    lea DX, newLine
    call PrintStr

    pop SI
    pop CX
    pop BX
    pop AX
    ret
Task ENDP
main:
    mov AX, @data
    mov DS, ax

    call ReadFile
    call PrintMatrix
    call Task



    mov AX,4c00h
    int 21h  

end main