	.model tiny
	.code
	org 100h
		
	Start: 	
	JMP installation 

	resident proc 		;DS:DX = ����� ������, ��������������� �������� '$'
					
		cmp ah, 09h
		je next
		jmp dword ptr cs:[int21Vector]	;��������� �� ������ cs:int21Vector, ��� �������� ������������ 21 ����������
		jmp endres
		next:
		lea di,newString		;����� ����� (������ ��������)
		mov bx,dx						;�������� � BX ����� ������� �������� ������
		dec bx
		_loop:
		inc bx
		mov dl, [bx]
		
		cmp dl, '$'
		je endres
		cmp dl, 'e'
		je _loop
		cmp dl, 'y'
		je _loop
		cmp dl, 'u'
		je _loop
		cmp dl, 'i'
		je _loop
		cmp dl, 'o'
		je _loop
		cmp dl, 'a'
		je _loop
				
		mov [di], dl
		inc di
		
		jmp _loop
		
		endres:	
		mov [di], dl
		mov ah, 09h
		lea dx, newString
		jmp dword ptr cs:[int21Vector]	
		iret						
	resident endp 

		int21Vector dd ?     		; �������� ����� ������� �����������
		newString db 255 dup ('$')
		
	installation: 
		;����������� ����� ����������� ����������� � ���������� int21Vector
		mov ah, 35h			;AH = 35h, ������� DOS: ������� ����� ����������� ����������
		mov al, 21h        	;AL = ����� ����������
		int 21h             ;35 ������� 21 ���������� - ������� ����� ����������� ����������	
		mov word ptr int21Vector, bx     ; BX - ����� ������� ����������� ����������
		mov word ptr int21Vector + 2, es ; ES - ���������� ����� ������� ����������� ����������
										 
		;���������� ����� ����������
		mov ah, 25h					;AH = 25h, ������� DOS : ���������� ���������� 
		mov al, 21h        			;AL = ����� ����������
		mov dx, offset resident		;DS:DX - ����� ������ �����������
		int 21h     		        ;25 ������� 21 ���������� - ���������� ����������  

		;�������� ��������� ����������� 
		mov dx, offset installation ; DX - ����� ������� ����� �� ����������� �������� ��������� 
									;(DX ���������������� ��� �������� �� PSP (DS/ES ��� �������)
		int 27h             ;�������� ��������� ����������� 

	end Start
