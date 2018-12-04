.model small
.386
.stack 256
.data
    max db 100
        len db ?
        string db 100 dup('$')
.code

;������� ����� ������
newline PROC
        push AX
        push DX
         mov AH, 02h
        mov DL, 13
        int 21h
        mov DL, 10
        int 21h
         pop DX
    pop AX
ret
newline ENDP

;�������� ��������
delete proc
        push cx
        push bx
        push ax
    
    lea si, string
    lea di, string
    
cycle:
    ;���������� ���� �� �������� ������ ���� ����� ������
    cmp byte ptr [si], ' '
    je Space
    cmp byte ptr [si], '$'
    je exit
    
    lodsb
    mov [di], al

    inc di
    jmp cycle

Space:
    ;��������� �������� �� ����. ������ �������� , ���� �� , �� ���������� ���
    cmp byte ptr [si+1], ' '
    je Skip
    
    lodsb
    mov [di], al
    inc di
    jmp cycle
Skip:
    inc si
    jmp cycle
    
exit:
    lodsb
    mov [di], al
    lea di, string
        pop ax
        pop bx
    pop cx
ret
delete ENDP



main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    ;���� ������
    lea dx, max
    mov ah, 0aH
    int 21h
    
    ;�������� ��������
    call newline
    call delete
    lea dx, string

    ;�����
    mov ah, 09h
    int 21h
    call newline

    mov ax, 4c00h
    int 21h
end main    
