; ������������ ������ �4
; ���������� ������ ������ � ����������, ������� �� ��������� �������� ������� � �������� ��������� �� ������. 
; ��� ���������� ������ ���������� ������������ ���� �� ���� �� ������ ��� ������ � ���������. 
; ���������, ��� ������ ������� �� ����, ����������� ������������ ������ �������� (�� ����������� ��������� 5, 6, 8, 9). 
; ������� ����� ����� ������������� ����� ������ ������ � ����� ���������� �����.

; 17) � ��������� �������� 3 ������: A, B (����� ����� A � B ���������), C. � ��������� ������������� ������ ������� ��� �������, 
; ������������� � ������ �, � �������� ��� �������, ������������� � ������ �, ���������������� ��������� ������ B.

.model small

.stack 256

.data
    strA db 'qwert', '$'
    lengthAB db 5
    strB db 'asdfg', '$'
    strC db 'zxcvbnm', '$'
    lengthC db 7
    enterString db "Enter the string:", 13, 10, '$'
    endline db 13, 10, '$'
    
    temp dw 0
    
    max db 100
    len db 0
    string db 100 dup(?)
    result db 100 dup(?)
    lengthResult db 0
    
.code

inputString proc
    push ax
    push dx
    
    lea dx, enterString
    mov ah, 09h
    int 21h
    
    lea dx, max
    mov ah, 0ah
    int 21h
    
    lea dx, endline
    mov ah, 09h
    int 21h
    
    lea di, result
    mov [di], byte ptr '$'
    
    pop dx
    pop ax
    
    ret
endp

conversionString proc
    push ax
    push bx
    push cx
    push dx
    
    lea si, string
    xor bx, bx
    mov bl, len
    mov [bx+si], byte ptr '$' ; � si �������� �������� ������
    mov cx, bx
    xor bx, bx
    
    walkEnteredString:
    lodsb
    lea di, strC
    push cx ; ������ ���-�� �������� �������� ������ � ����
    xor cx, cx
    mov cl, lengthC
    repne scasb
    jne notFoundInMissed
    
    ;foundInMissed:
    jmp noPrint
    
    notFoundInMissed:
    lea di, strA
    mov cl, lengthAB
    mov word ptr temp, di
    repne scasb
    jne notFoundInReplaced
    
    ;foundInReplaced:
    dec di
    sub di, word ptr temp
    mov word ptr temp, di
    lea di, strB
    add di, word ptr temp
    mov al, [di]
    
    notFoundInReplaced:
    lea di, result
    push bx
    xor bx, bx
    mov bl, byte ptr lengthResult
    mov [bx+di], al
    inc lengthResult
    mov bl, byte ptr lengthResult
    mov [bx+di], byte ptr '$'
    pop bx
    
    
    noPrint:
    
    pop cx
    
    loop walkEnteredString
    
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
endp

outputString proc
    push ax
    push dx
    
    lea dx, result
    mov ah, 09h
    int 21h
    
    lea dx, endline
    mov ah, 09h
    int 21h
    
    pop dx
    pop ax
    
    ret
endp

start:

    mov ax, @data                       ; ���������� ����� �������� ������ � ������� AX
    mov ds, ax
    mov es, ax
    
    call inputString
    
    call conversionString
    
    call outputString
    
    mov ax, 4c00h
    int 21h
end start