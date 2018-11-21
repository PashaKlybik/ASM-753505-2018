.model small
.stack 256
.data
    ;for files
    mesNotFountFile db "File hasn't been found", 10, '$'
    mesReadException db "Read file exception", 10, '$'
    mesCloseException db "Close file exception", 10, '$'
    mesCreateException db "Create/rewrite file exception", 10, '$'
    mesWriteException db "Write file exception", 10, '$'
    mesErrorInputNegative db "ERROR. Size of matrix must be positive", 13, 10, '$'
    mesErrorSize db "ERROR. Size of matrix must be <= 100", 13, 10, '$'
    mesIncorrectValue db "ERROR. Incorrect value", 10, '$'
    
    outputFile db "output.txt", 0
    inputFile db "input.txt", 0
    newline db 13, 10, '$'
         dw 1
    
    outBuffer db 8 dup (' '), '$'
    maxBufferSize dw 1000
    bufferSize dw (?)
    buffer db 1002 dup (?)
    M dw 0
    N dw 0
    maxSize dw 100
    elemSize dw 2
    array dw 100 dup (0)
    
    ;for input/outputInteger integers
    minus dw ?
    number dw ? ; push pop slower
    maxPositive dw 32767
    maxNegative dw 32768
    ten dw 10
.code

    fileWrite proc
        mov ah, 3Ch
        lea dx, outputFile
        xor cx, cx
        int 21h
        jc createFileException
        mov bx, ax
        mov cx, N ;use only to output newline
        mov di, 0
    externalOutput:
        push cx
        mov cx, M ;use only to output newline
    innerOutput:
        mov ax, array[di] 
        call outputInteger
        add di, elemSize
        loop innerOutput
        lea dx, newline
        mov cx, 2
        mov ah, 40h
        int 21h
        cmp al, 2
        jnz writeFileException
        pop cx
        loop externalOutput
        ;close file
        mov ah, 3Eh
        int 21h
        jnc fileWriteExit
        lea dx, mesCloseException
        mov ah, 09h
        int 21h
        jmp fileWriteExit
    writeFileException:
        mov ah, 09h
        lea dx, mesWriteException
        int 21h
        jmp fileWriteExit
    createFileException:
        mov ah, 09h
        lea dx, mesCreateException
        int 21h
    fileWriteExit:
        ret
    fileWrite endp

    fileRead proc
        mov ah, 3Dh ;open or create
        xor al, al
        lea dx, inputFile
        xor cx, cx
        int 21h
        jc notFoundFile
        mov bx, ax ;read from file to buffer
        mov ah, 3Fh
        lea dx, buffer
        mov cx, maxBufferSize
        int 21h
        jc readException
        mov cx, bx ;insert space and symbol of ending string
        lea bx, buffer
        add bx, ax
        mov byte ptr [bx], ' '
        inc bx
        mov byte ptr [bx], '$'
        mov bx, cx
        mov ah,3Eh ;close file
        int 21h
        jnc fileReadExit
        lea dx, mesCloseException
        mov ah, 09h
        int 21h
        jmp fileReadExit
    readException: ; processing exception
        mov ah, 09h
        lea dx, mesReadException
        int 21h
        jmp fileReadExit
    notFoundFile:
        mov ah, 09h
        lea dx, mesNotFountFile
        int 21h
    fileReadExit:
        ret
    fileRead endp

    inputInteger proc
        push bx
        push cx
        push dx
        xor cx, cx ; cx == counter
        xor ax, ax
        mov number, 0
        mov minus, 0
        inp:
            lodsb ;read byte from buffer, si save reference on buffer
            cmp al, 13
            jz finish
            cmp al, 10
            jz finish
            cmp al, 20h
            jz finish
            cmp al, 9
            jz finish
            cmp al, '-'
            jnz positiveNumber
            cmp cx, 0
            jnz errorInput
            mov minus, '-'
            inc cx
            jnp inp
            
        positiveNumber:
            cmp al, '0'
            jc errorInput
            cmp al, '9'
            ja errorInput
            xor bx, bx
            mov bl, al
            sub bl, '0'
            mov ax, number
            mul ten
            jc errorInput
            add ax, bx
            cmp minus, '-'
            jnz positive
                cmp ax, maxNegative
                jmp nextStep
            positive:
                cmp ax, maxPositive
            nextStep:
                ja errorInput
                mov number, ax
                inc cx
                jmp inp
            errorInput:
                mov ah, 09h
                lea dx, mesIncorrectValue
                int 21h
                jmp exit
        finish:
            cmp cx, 0 ; if two or more spacing symbols consecutive
            jz inp
            mov ax, number
            cmp minus, '-'
            jnz toExit
            neg ax
            toExit:
            mov minus, 0
            pop dx
            pop cx
            pop bx
            ret        
    inputInteger endp
    
    outputInteger proc
        push cx
        push dx
        push si
        xor cx,cx
        mov si, 6
    zeroing:
        mov outBuffer[si], ' ' ; after the last output this string will fill some digit, to delete it, we fill this string with spaces except the last symbol in string, because in out number always will be one digit
        dec si
        cmp si, 0
        jnz zeroing
        mov si, 7
        mov minus, 0
        cmp ax, maxPositive
        jna numberInString
        neg ax
        mov minus, '-'
    numberInString:
        xor dx, dx
        div ten
        add dx, '0'
        mov outBuffer[si], dl
        dec si
        cmp ax,0
        jnz numberInString
        cmp minus, '-'
        jnz next
        mov outBuffer[si], '-'
    next:
        lea dx, outBuffer ;output string
        mov cx, 8
        mov ah, 40h
        int 21h
        pop si
        pop dx
        pop cx
        ret
    outputInteger endp

    inputMatrix proc
        push ax dx
        mov dx, M
        add dx, M
        mov cx, N
        mov bx, 0
    externalInput:
        mov di, N
        sub di, cx
        add di, di
        push cx
        mov cx, M
        ;in order to if N > M, shifts will be done
    greaterThanDoubleM:
        cmp di, dx
        jc innerInput
        sub di, dx
        jmp greaterThanDoubleM
    innerInput:
        cmp di, dx
        jc nextInput
        mov di, 0
    nextInput:
        call inputInteger
        mov array[bx][di], ax
        add di, elemSize
        loop innerInput
        pop cx
        add bx, M
        add bx, M
        loop externalInput
        pop dx ax
        ret
    inputMatrix endp
    
main:
    mov ax, @data
    mov ds, ax
    
    call fileRead
    lea si, buffer
    call inputInteger
    cmp ax, 0
    jng negativeError
    mov N, ax
    call inputInteger
    cmp ax, 0
    jng negativeError
    xor dx, dx
    mov M, ax
    mul N
    jc incorrectSizeError
    cmp ax, 100
    ja incorrectSizeError
    call inputMatrix      ; fill array with values in biffer
    call fileWrite          ; write in file
    jmp exit
incorrectSizeError:
    lea dx, mesErrorSize
    mov ah, 09h
    int 21h
    jmp exit
negativeError:
    lea dx, mesErrorInputNegative
    mov ah, 09h
    int 21h
exit:
    mov ah, 4ch
    int 21h
end main