; ������������ ������ �5
; ����� ������� ����������� ���������� ��������. ������ �� ��� �������� �������������, ���� �� ������� �������� 
; (���������� ����� ����� ���� �������� �� ���������� ��������). ��� ������� ������� ���������� ������ ���������� �����, 
; ����� ���������� �������� � ����� ��� ��������. ��� ����� � ������ ����� ������������ ������� �� 3 ������ 
; (������ �� ��������� �������), ��� �������� �������, ��� ���� ������ ���������� (�.�. ����� ������ ��� �������� �� �������������� 
; �� �������). ��� ������ �� ����� �������� ������ ������� ������� ���������� ���������� ���� ��� ������ (��������� �������� �������� ���������).
; �������������� ������� �� ����� ������� ������: ������� ���� �������� ������ �� �����, 
; ����� ���������� � ���� (�������� ������ ����� ������ � �������� ������, �������� "input.txt" "output.txt").

; 7) �������� ����������� N � M � ������� ����������� NxM. �������� ������� ������������ �������, 
; ������������� ���� ������� ���������, � ����������� �������, ������������� �� ���� ������� ���������.

.model small

.stack 256

.data
    array db 128 DUP (0)
    buffer db 256 DUP(0)
    inputFileName db 'matrix.txt', 0
    outputFileName db 'output.txt', 0
    handle dw 1
.code
      
readDataFromFile proc
    mov ah, 3Dh  ; ��������� ��������� �����      
    xor al, al   ; 0 - ��������� ��� ������        
    lea dx, inputFileName   
    xor cx, cx             
    int 21h                  
    mov [handle], ax ; ��������� ���������
    mov bx, ax ; ������� � bx
    mov ah, 3Fh  ; ������ ���� ����� ���������
    mov dx, offset buffer  ; ����� ������ ��� ������ ������
    mov cx, 256  ; ����� ����������� ����
    int 21h   
    ret
endp
; ax - ����� ����������� ����, dx - ����� ������
 
createIntArray proc ; bx - ����� ������, cx - ����� ����������� ����
    mov dl, 10 
    xor si, si
    xor ax, ax    
    xor di, di ; ���� �����
    
    bufferHandler:
    mov dh, [bx]
    cmp dh, 10 ; ���� ������� ������
    je endOfIteration
    cmp dh, '-'
    jl ifNotNumber
    jg ifNumber
    inc di ; ���� ���� �����
    jmp endOfIteration
    
    ifNumber:
    mul dl
    add al, [bx]
    sub al, '0'
    jmp endOfIteration
    
    ifNotNumber:
    cmp di, 1
    jne ifPositive
    neg ax
    xor di, di
    
    ifPositive:
    mov array[si], al ; ������� ����� � �������
    xor ax, ax
    inc si
    
    endOfIteration:
    inc bx
    loop bufferHandler
    cmp di, 1
    jne notNegative
    neg al
    notNegative:
    mov array[si], al
    
    ret
endp

findMax proc ; dl - columns, dh - rows
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor di, di
    mov si, 2
    
    cmp dl, dh
    jg moreColumns
    mov cl, dl
    dec cl
    jmp searchMax
    
    moreColumns:
    mov cl, dh  ; cl = min(columns - 1, rows)
    
    searchMax:
    inc di ; �����
    add si, di
    push cx
    xor cx, cx
    mov cl, dl
    sub cx, di
     
    inRowAfterDiagonal: ; ������ �� ���� ����� ���������
    cmp array[si], al
    jle nextIteration
    mov bx, si
    mov al, array[bx]
    nextIteration:
    inc si
    loop inRowAfterDiagonal
    
    pop cx
    loop searchMax
    
    ret
endp

findMin proc ; dl - columns, dh - rows
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor di, di
  
    mov cl, dh
    dec cl ; cl = rows - 1
    
    mov al, dl
    mov di, ax ; di = columns
    xor ax, ax
    
    mov si, 2
    mov bx, si
    mov al, array[si] ; al = a[0][0]
    add si, di ; si -> a[1][0]
    sub di, 2 ; di = columns - 2
     
    mov ah, 2
       
    searchMin:
    push cx
    mov cl, ah
    
    inRowBeforeDiagonal: ; ������ �� ���� �� ���������
    cmp array[si], al
    jge nextIterationMin
    mov bx, si
    mov al, array[bx]
    
    nextIterationMin:
    inc si
    loop inRowBeforeDiagonal
         
    cmp ah, dl
    je maxLength
    add si, di
    dec di
    inc ah
    maxLength:
    pop cx
    loop searchMin
    
    ret
endp

openFile proc
    mov ah, 3Ch             
    lea dx, outputFileName  
    xor cx, cx              
    int 21h
    mov [handle], ax
    ret
endp

printBuffer proc
    push ax
    push dx       
    mov bx, [handle]        
    mov ah, 40h   
    xor dh, dh              
    mov dl, offset buffer   
    int 21h    
    pop dx
    pop ax
    ret
endp
   
closeFile proc
    mov ah, 3Eh             
    mov bx, [handle]         
    int 21h
    ret
endp

output proc
    printNumber: 
    push cx
    mov cl, dl
    
    outputInRow: 
    mov al, array[si]  
    cmp al, 0
    
    jge isPositive
    mov buffer, '-'
    push cx
    mov cx, 1
    call printBuffer
    pop cx
    neg al
    
    isPositive:
    xor di, di
    push cx
    
    intToWord:
    mov bl, 10
    div bl
    add ah, 48
    mov bh, al
    mov al, ah
    xor ah, ah
    push ax
    mov al, bh
    inc di
    cmp al, 0    
    jg intToWord
    mov cx, di
    xor bx, bx
    
    toBuffer:
    pop ax
    mov buffer[bx], al
    inc bx
    loop toBuffer
    
    mov buffer[bx], ' '
    inc bx
    mov cx, bx
    call printBuffer
    pop cx
    inc si
    loop outputInRow
    mov buffer[0], 13
    mov buffer[1], 10
    mov cx, 2
    call printBuffer
    pop cx
    loop printNumber
    
    ret
endp

start:
    mov ax, @data
    mov ds, ax
    
    call readDataFromFile
    
    mov bx, dx 
    mov cx, ax
    
    call createIntArray
    
    mov dl, array[0]
    mov dh, array[1]
    
    call findMax
    
    push bx
    
    call findMin
    
    pop si  ; si - ����� ���������, bx - ����� ��������
    mov al, array[si]
    mov ah, array[bx]
    mov array[si], ah
    mov array[bx], al
    
    call openFile
    
    xor ax, ax
    mov si, 2
    mov dl, array[0]
    mov dh, array[1]
    mov cl, dh
    
    call output
    
    call closeFile
    
    mov ax, 4c00h
    int 21h
end start