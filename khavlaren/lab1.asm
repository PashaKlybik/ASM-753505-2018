.model small
.386
.stack 100h
.data
    a dw 2
    b dw 0
	c dw 73
	d dw 1
.code
; Найти максимум между a, b, c, d и отнять от него минимум между этими числами.

main:

    MOV AX, @data
    MOV DS, AX
    
    MOV AX, a
	MOV BX, a
	
	CMP AX, b
	JC L_b_is_bigger_than_a
	; a >= b
	MOV BX
	JMP	Next_1
	L_b_is_bigger_than_a:
	; b > a
	MOV AX, b
	Next_1:
	
	CMP AX, c
	JC L_c_is_bigger_than_AX
	; c <= [AX]
	CMP BX, c
	JC Next_2
	MOV BX, c
	JMP Next_2
	L_c_is_bigger_than_AX:
	; c > [AX]
	MOV AX, c
	Next_2:
	
	CMP AX, d
	JC L_d_is_bigger_than_max
	; d <= [AX]
	CMP BX, d
	JC Next_3
	MOV BX, d
	JMP Next_3
	L_d_is_bigger_than_max:
	; d > [AX]
	MOV AX, d
	Next_3:
		
	SUB AX, BX
	
	MOV ax, 4c00h
	INT 21h

end main