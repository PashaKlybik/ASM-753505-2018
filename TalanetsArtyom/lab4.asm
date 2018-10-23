.MODEL SMALL
.STACK 100h

.DATA
    ten dw 10
	endl db 13, 10, '$'
	errorInput db "Input error", 13, 10, '$'
	stringIsValid db "String is valid", 13, 10, '$'
	stringIsNotValid db "String is not valid", 13, 10, '$'
	inputString   db 254,  256 dup(?)
.CODE

END_LINE:
	push ax
	mov ah, 9
	lea dx, endl
	int 21h
	pop ax	
ret

INPUT_STRING:	
	push ax
	push cx
	push dx	
	   
    mov ah,0Ah
    lea dx,inputString       ;DX = a���� ������
    int 21h     
    xor ch, ch
    mov cl,inputString[1]    ;cl = ����� �������� ������
    jcxz input_error    	 ;���� ����� = 0, ���������� ������
	call END_LINE
	
	pop dx
	pop cx
	pop ax
	ret  
	
input_error:
    xor ax,ax  
    mov ah, 9
    lea dx, errorInput
    int 21h      
    jmp END_PROGRAM 

CHECK_STRING:
	push ax		;������
	push bx		;����� �������
	push cx		;������� ��������
	push dx		;������� �������� ������
	      
	xor dx, dx
    xor ch, ch
    mov cl,inputString[1]    ;cl = ����� �������� ������
	inc cx   
	lea si, inputString
	inc si
	inc si
check_next_symbol:	    
	dec cx
    jcxz end_of_lines			;���� ���� ����������� ��� �������, �� ������ ���������
    lods inputString
    inc bx      	     	   	;��������� ������
	cmp al,'('      	    	;���� ��������� ������ ��� '('
    jz bracket_is_open  		;��������� � ���������� �������
    cmp al,')'   		       	;���� ��������� ������ ��� ')'
    jz bracket_closed   	    ;��������� � ���������� �������
	jmp string_is_not_valid		;���� ������ �� '(' � �� ')', �� ������ �� ���������
	
bracket_is_open:
	inc dx						;����������� ���������� �������� ������
	jmp check_next_symbol

bracket_closed:
	cmp dx, 0					
	jz string_is_not_valid		;���� �������� ������ ���, �� ������ �� ���������
	dec dx						;��������� ���������� �������� ������
	jmp check_next_symbol		
	
end_of_lines:
	cmp dx, 0					
	jz string_is_valid			;���� �������� � �������� ������ ���������� ����������, �� ������ ���������
	jmp string_is_not_valid		;���� �������� � �������� ������ ������ ����������, �� ������ � ���������
	

string_is_valid:
	mov ah, 9
    lea dx, stringIsValid
    int 21h      
    jmp check_exit 

string_is_not_valid:
	mov ah, 9
    lea dx, stringIsNotValid
    int 21h      
    jmp check_exit  
 
check_exit:
	call END_LINE
	pop dx
	pop cx
	pop bx
	pop ax
	ret

   
START:
	mov ax,@data
	mov ds,ax
	
	call INPUT_STRING
	call CHECK_STRING
	
END_PROGRAM:
    mov ah,4ch
    int 21h
    
    
END START