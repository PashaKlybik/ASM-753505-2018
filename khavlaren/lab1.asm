.model small
.386
.stack 100h
.data
    a dw 2
    b dw 0
    c dw 73
    d dw 1
.code
; Вариант 8.
; Найти максимум между a, b, c, d и отнять от него минимум между этими числами.

main:

    MOV AX, @data
    MOV DS, AX
    
    MOV AX, a
    MOV BX, AX
    
    MOV CX, b
    CMP AX, CX
    JC L_b_is_bigger_than_a
    ; a >= b
    MOV BX, CX
    JMP	Next_1
L_b_is_bigger_than_a:
    ; b > a
    MOV AX, CX
Next_1:
    
    MOV CX, c
    CMP AX, CX
    JC L_c_is_bigger_than_AX
    ; c <= [AX]
    CMP BX, CX
    JC Next_2
    MOV BX, CX
    JMP Next_2
L_c_is_bigger_than_AX:
    ; c > [AX]
    MOV AX, CX
Next_2:
    
    MOV CX, d
    CMP AX, CX
    JC L_d_is_bigger_than_max
    ; d <= [AX]
    CMP BX, CX
    JC Next_3
    MOV BX, CX
    JMP Next_3
L_d_is_bigger_than_max:
    ; d > [AX]
    MOV AX, CX
Next_3:
    
    SUB AX, BX
    
    MOV ax, 4c00h
    INT 21h

end main