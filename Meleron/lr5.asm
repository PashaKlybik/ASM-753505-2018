.model small
.stack 256
.data
    rowsAmount dw ?
    colsAmount dw ?
    lowestNumber dw ?
    greatestNumber dw ?
    lowestNumberX dw ?
    lowestNumberY dw ?
    greatestNumberX dw ?
    greatestNumberY dw ?
    return dw ?
    temp dw ?
    array dw 10*10 dup(?)
    counter dw ?
    endline db 13,10,'$'
    buffer db 256 dup(?)
    correct db 13,10,'correct$'
    incorrect db 13,10,'incorrect$'
    enterRowsAmountMessage db 13,10,'Enter amount of rows(>=2, <=10): $'
    enterColsAmountMessage db 13,10,'Enter amount of columns(>=2, <=10): $'
    enterMatrixMessage db 13,10,'Enter matrix:$'
    enteredMatrixMessage db 13,10,'Entered matrix:$'
    changedMatrixMessage db 13,10,'Changed matrix:$'
.code

main:
    mov ax, @data
    mov ds, ax
    lea di, enterRowsAmountMessage
    call printString
    call enterString
    pop rowsAmount
    lea di, enterColsAmountMessage
    call printString
    call enterString
    pop colsAmount
    lea di, enterMatrixMessage
    call printString
    call printEndline
    call enterArray
    lea di, enteredMatrixMessage
    call printString
    call printArray
    call task
    mov si, greatestNumberX
    mov bx, greatestNumberY
    pop cx
    mov array[si][bx], cx
    mov si, lowestNumberX
    mov bx, lowestNumberY
    pop cx
    mov array[si][bx], cx
    lea di, changedMatrixMessage
    call printString
    call printArray
    mov ax, 4c00h
    int 21h
  
enterString proc
    push ax
    push bx
    push cx
    
    mov ah, 01h
    int 21h  
    cmp al, '-'
    je ifNegative
    sub al, 30h
    xor ah, ah
    mov bx, 10
    mov cx, ax
    
  ifPositive:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je stop
    cmp al, 20h
    je stop
    
  notEquals:
    sub al, 30h
    xor ah, ah
    xchg ax, cx
    mul bx
    add cx, ax
    jmp ifPositive
    
  ifNegative:
    mov ah, 01h
    int 21h
    sub al, 30h
    xor ah, ah
    mov bx, 10
    mov cx, ax
    
  lp:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    jne spaceCheckTrue
    jmp spaceCheckFalse
  spaceCheckTrue:
    cmp al, 20h
    jne ifNegAndNotEquals
  spaceCheckFalse:
    neg cx
    jmp stop
    
  ifNegAndNotEquals:
    sub al, 30h
    xor ah, ah
    xchg ax, cx
    mul bx
    add cx, ax
    jmp lp
    
  stop:
    mov temp, cx
    pop cx
    pop bx
    pop ax
    pop return
    push temp
    push return
	jmp ex
    
  ex:
    ret
enterString endp

task proc
    mov ax, 32768
    xor bx, bx
    xor dx, dx
    mov counter, 0
    mov cx, rowsAmount
    
  rowsCycleTaskGreater:
    push cx
    mov si, 2
    add si, counter
    mov cx, colsAmount
    
  colsCycleTaskGreater:
    push ax
    mov ax, 2
    mul colsAmount
    cmp si, ax
    pop ax
    jge breakGreater
    mov dx, array[bx][si]
    cmp dx, ax
    jg foundGreater
    jmp notGreater
    
  foundGreater:
    mov ax, dx
    mov greatestNumberX, bx
    mov greatestNumberY, si
    
    
  notGreater:
    inc si
    inc si
    
  breakGreater:
    loop colsCycleTaskGreater
    
    add bx, colsAmount
    add bx, colsAmount
    pop cx
    inc counter
    inc counter
    loop rowsCycleTaskGreater
    
    pop bx
    push ax
    push bx
    
    ;-------------------
    mov ax, 32767
    xor bx, bx
    xor dx, dx
    mov counter, 0
    mov cx, rowsAmount
    
  rowsCycleTaskLower:
    push cx
    mov si, 0
    mov cx, colsAmount
    
  colsCycleTaskLower:
    push ax
    mov ax, 2
    mul counter
    cmp si, ax
    pop ax
    jg breakLower
    mov dx, array[bx][si]
    cmp dx, ax
    jl foundLower
    jmp notLower
    
  foundLower:
    mov ax, dx
    mov lowestNumberX, bx
    mov lowestNumberY, si
    
  notLower:
    inc si
    inc si
    
  breakLower:
    loop colsCycleTaskLower
    
    add bx, colsAmount
    add bx, colsAmount
    pop cx
    inc counter
    loop rowsCycleTaskLower
    
    pop bx
    push ax
    push bx
    
    ret
task endp

enterArray proc
    mov cx, rowsAmount
    
  rowsCycleInput:
    push cx
    mov si,0
    mov cx, colsAmount
    
  colsCycleInput:
    call enterString
    pop array[bx][si]
    inc si
    inc si
    loop colsCycleInput
    
    add bx, colsAmount
    add bx, colsAmount
    pop cx
    loop rowsCycleInput
    
    ret
enterArray endp

printArray proc

    mov cx, rowsAmount
    xor bx, bx
    
  rowsCycleOutput:
    push cx
    mov cx, colsAmount
    mov si,0
    call printEndline
    
  colsCycleOutput:
    push ax
    push ax
    mov ax, array[bx][si]
    pop ax
    push array[bx][si]
    call printNumber
    pop ax
    pop ax
    inc si
    inc si
    loop colsCycleOutput
    
    add bx, colsAmount
    add bx, colsAmount
    pop cx
    loop rowsCycleOutput
    
    call printEndline
    ret
printArray endp

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

printNumber proc
    pop return
    pop ax
    push ax
    push return
    push di
    lea di,buffer	    
    push di	
    call convertNumber
    mov byte[di],'$'
    pop di
    call printString
    pop di
    call clearBuffer
    ret
printNumber endp

convertNumber proc
    push cx
    push bx
    lea di, buffer
    xor cx, cx
    mov bx, 10
    
  lp1:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz lp1
    
  lp2:
    pop dx
    mov [di], dl
    inc di
    loop lp2
    pop bx
    pop cx
    ret
convertNumber endp

clearBuffer proc
    mov [buffer], 0h
    mov [buffer+1], 0h
    mov [buffer+2], 0h
    mov [buffer+3], 0h
    mov [buffer+4], 0h
    mov [buffer+5], 0h
    mov [buffer+6], 0h
    ret
clearBuffer endp

exitProg proc
    call printEndline
    mov ax, 4c00h
    int 21h
    ret
exitProg endp

end main

