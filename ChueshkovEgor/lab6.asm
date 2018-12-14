.model tiny
.code
.486                                    
org 100h    ;������ COM-���������
start:
    jmp initialization       
                      
newKeyboardHandle proc         ;����� ���������� ���������� ����������
    pushf
    push es
    mov ax, 40h            ;��� ������ � ������� ����������
    mov es, ax 
    xor ax, ax 
    IN  al, 60h            ;�������� ����-��� �������
    cmp al, 1eh            ;���������� ��� � ����� ����� a
    jne b                  ; �������, ����� � al �� 1eh
    mov al, 49             ; = '1'
    jmp newHandler
b:
    cmp al, 30h            ;���������� ��� � ����� ����� b
    jne c                  ; �������, ����� � al �� 30h
    mov al, 50             ; = '2'
    jmp newHandler
c:
    cmp al, 2eh            ;���������� ��� � ����� ����� c
    jne d                  ; �������, ����� � al �� 2eh
    mov al, 51             ; = '3'
    jmp newHandler
d:
    cmp al, 20h            ;���������� ��� � ����� ����� d
    jne e                  ; �������, ����� � al �� 20h
    mov al, 52             ; = '4'
    jmp newHandler
e:
    cmp al, 12h            ;���������� ��� � ����� ����� e
    jne old                ; �������, ����� � al �� 12h
    mov al, 53             ; = '5'
	
newHandler: 
    mov bx, 1ah        
    mov cx, es:[bx]        ;������ ������ 
    mov di, es:[bx]+2      ;����� ������
    cmp cx, 60             ;������ �� �������?
    je check      
    inc cx                 ;����������� ��������� ������ �� 2
    inc cx            
    cmp cx, di             ;���������� � ���������� ������
    je exit                ;���� �����, �� ����� �����
    jmp insert             ;����� ��������� ������
check:
    cmp di,30        
    je exit                ;���� ����� �����, �� �����
insert:
    mov es:[di], al        ;�������� ������ � �����
    cmp di, 60         
    jne tail             ;���� ����� �� � ����� ������, �� ��������� 2
    mov di, 28             ;����� ��������� ������ = 28+2
tail:
    add di, 2            
    mov es:[bx]+2, di      ;�������� ��� � ������� ������
    jmp exit
old: 
    pop es
    popf                      
    jmp dword ptr cs:standartHandler  ;����� ������������ ����������� ���������� 
                                 ;��������� �� ������ 
                                 ; cs:standartHandler, ��� �������� 
                                 ; ������������ ������� ��� ��������� 
                                 ; ����������, ������� ������� ������ 
                                 ; �� �������� al �� �����        

    iret
exit:
    xor ax, ax
    mov al, 20h
    out 20h, al 
    pop es
    popf 
    iret
newKeyboardHandle endp

    standartHandler dd ?
	
initialization proc
    ;�������� ����� ����������� ����������� � standartHandler
    mov ax, 3509h               ; ah = 35h, al = ����� ����������         
    int 21h                     ; ������� DOS: �������
                                ; ����� ����������� ����������
    mov word ptr standartHandler, bx         ;���������� �������� � bx
    mov word ptr standartHandler + 2, es     ;� ���������� ����� � es
    ;������������� ����� ����������
    mov ax, 2509h                            ;ah = 25h, al = ����� ����������
    mov dx, offset newKeyboardHandle         ;ds:dx - ����� �����������
    int 21h                                  ;������� DOS : ���������� ����������
    ;������ ��������� �����������      
    mov dx, offset initialization
    int 27h 
initialization endp

end start 