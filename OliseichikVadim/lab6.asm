.model tiny
.code
org 100h ; ������ COM-���������
Start: 
jmp installation 

resident proc 
 
cmp al, 1eh           ; 1eh = 'a' 
jne isB               ; �������, ����� � al �� 1eh 
mov al, 02h           ; 02h = '1'
jmp to_ret 

isB: 
cmp al, 30h           ; 30h = 'b' 
jne isC               ; �������, ����� � al �� 30h
mov al, 03h           ; 03h = '2' 
jmp to_ret 

isC: 
cmp al, 2eh           ; 2eh = 'c'
jne isD               ; �������, ����� � al �� 2eh
mov al, 04h           ; 04h = '3'
jmp to_ret 

isD: 
cmp al, 20h           ; 20h = 'd' 
jne isE               ; �������, ����� � al �� 20h 
mov al, 05h           ; 05h = '4' 
jmp to_ret 

isE: 
cmp al, 12h           ; 12h = 'e' 
jne to_original_handler ; �������, ����� � al �� 12h
mov al, 06h           ; 06h = '5' 
jmp to_ret 

to_ret: 
jmp dword ptr cs:handler_vector ; ��������� �� ������ 
                            ; cs:handler_vector, ��� �������� 
                            ; ������������ ������� ��� ��������� 
                            ; ����������, ������� ������� ������ 
                            ; �� �������� al �� �����
to_original_handler: 
jmp dword ptr cs:handler_vector 

handler_vector dd ?     ; ����� �������� ����� 
                        ; ����������� �����������
resident endp 

installation: 
; ����������� ����� ����������� ����������� 
; � ���������� handler_vector
mov ax, 3515h        ; AH = 35h, AL = ����� ����������
int 21h              ; ������� DOS: ������� 
                     ; ����� ����������� ���������� 
mov word ptr handler_vector, bx     ; ���������� �������� � BX  
mov word ptr handler_vector + 2, es ; � ���������� ����� � ES,
                                  ; ���������� ��� ����������
mov ax, 2515h        ; AH = 25h, AL = ����� ����������
mov dx, offset resident ; DS:DX - ����� ����������� 
int 21h              ; ������� DOS : ���������� ���������� 

mov dx, offset installation ; DX - ����� ������� ����� �� 
                            ; ������ ����������� �����
int 27h              ; �������� ��������� ����������� 

end Start
