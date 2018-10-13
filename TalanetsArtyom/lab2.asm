.MODEL SMALL
.STACK 100h

.DATA
	ten dw 10
	endl db 13, 10, '$'
	errorInput db "Input error", 13, 10, '$'
	errorDivByZero db "Division by zero", 13, 10, '$'
	buffer   db 6,  256 dup(?)
.CODE

END_LINE:
	push ax
	mov ah, 9
	lea dx, endl
	int 21h
	pop ax	
ret

INPUT:	
	push bx
	push cx
	push dx	
	
	              
    mov ah,0Ah
    lea dx,buffer       ;DX = a���� ������
    int 21h     
    xor ch, ch
    mov cl,buffer[1]    ;cl = ����� �������� ������
    lea bx, buffer     	;bx = ����� ������
	inc BX
    inc BX
    jcxz input_error    ;���� ����� = 0, ���������� ������
    xor ax,ax           ;AX = 0
 
input_loop:
    mov dl,[bx]			;�������� � dl ���������� ������� ������ (� dx ��� �������)
    inc bx              ;��������� ������
    cmp dx,'0'          ;���� ��� ������� ������ ���� '0', �� 
    jl input_error      ;���������� ������
    cmp dx,'9'          ;���� ��� ������� ������ ���� '9', ��
    jg input_error      ; ���������� ������
    sub dx,'0'			;� dx �����
	push dx
	mul ten             ;AX = AX * 10
	jc input_error          ;���� ������� - ������
    jo input_error          ;���� ������������ - ������
	pop dx
	add ax, dx
	jc input_error          ;���� ������� - ������
    jo input_error          ;���� ������������ - ������
    loop input_loop         ;������� �����
    jmp input_exit          ;�������� ���������� (����� ������ CF = 0)
 
input_error:
    xor ax,ax  
    mov ah, 9
    lea dx, errorInput
    int 21h      
    jmp END_PROGRAM   
 
input_exit:
	call END_LINE
	pop dx
	pop cx
	pop bx
	
ret

OUTPUT:
	push ax
	push bx
	push cx
	push dx
		
	xor cx, cx
push_digit_to_stack:
    xor dx,dx
    div ten
    push dx		;�������� � ���� ��������� ����� �����
    inc cx
    test ax, ax		;(���������� �)
    jnz push_digit_to_stack    ;���� ax - �� ����, �� ��������� ��������� �����
    
    mov ah, 02h
print:
	pop dx			;� dx - �����, ������� ���������� �������
    add dl, '0'		;������, �������� �� �������
    int 21h
    loop print   
    call END_LINE
    
    pop dx
    pop cx 
    pop bx 
    pop ax  
ret

CHECK_DIV_BY_ZERO:
	push ax
	xor ax, ax  
	cmp bx, ax
	jnz no_error
    mov ah, 9
    lea dx, errorDivByZero
    int 21h      
    jmp END_PROGRAM   
no_error:    
    pop ax
    ret

START:
	
    mov ax,@data
	mov ds,ax
		
	call INPUT      
   	call OUTPUT
	mov bx, ax
	call INPUT      
   	call OUTPUT   	
	xchg ax, bx
	xor dx, dx
	call CHECK_DIV_BY_ZERO
	div bx
	call OUTPUT
	
END_PROGRAM:
    mov ah,4ch
    int 21h
    
    
END START