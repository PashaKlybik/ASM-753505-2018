.model tiny
.386
.data

	backSpace=08h
	tab=09h
	cr=0Dh ; ������� �������
	lf=0ah ; ������� ������
	space=20h
	
.code

org 100h

int21HVector label word

start:
	jmp init
	mov ax, 4c00h
	int 21h
	vowels db 'AEIOUYaeiouy'
	
intOverlap proc far ; ���������� 10 ������� 21 ����������
	cmp ah, 0Ah
	je if0Ah
	jmp dword ptr cs:[int21HVector] ; ��������� �� �����, ��� �������� int21HVector
if0Ah:
	push es
    push di
    push bx
    push cx
    push si
    push dx
	
	mov bx, dx	; � bx �������� ������ ������
	mov si, 1   ; ��������� �� ������
    xor ch, ch
    mov cl, [bx]; ������ ������ (�������� � ������ ��������)
    inc bx      ; bx ��������� �� ������ ������ � ������
	jcxz exit	; ���� ������ ������ = 0
	mov ax, 0d00h ; ����� ������ ������������� 0dH
	mov [bx], ax
    dec cx
    jz exit
    cld
    push cs
    pop es ; � es �������� cs (��� repne ����� ������������ ������� es)

stringInput: ; ������������ ��������� �������� � �������� �����
	call charInput
	cmp al, cr ; ���� ����� ������
	je endOfInput ; ����������� ����
	cmp al, backSpace
    je ifBackSpace
	call saveToBuffer ; ����� ��������� ������ � �����
	call output
	call isVowel ; ����� ZF=1, ���� ����� �������, ��� ZF=0, ���� ���������
	jnz stringInput
	call saveToBuffer ; ���� �������, �� ���������
	jb stringInput
	call output
	jmp stringInput

ifBackSpace: ; ��������� backspace
	cmp si, 1
	je stringInput
	mov [bx+si], byte ptr cr
	dec si
	dec byte ptr [bx]
	call output
	mov al, space
	call output
	mov al, backSpace
	call output
	jmp stringInput

endOfInput:
	mov [bx+si], al
	call output
	
exit:
	pop dx
    pop si
    pop cx
    pop bx
    pop di
    pop es
    iret
intOverlap endp

;---------------------------

saveToBuffer proc  ; ��������� ������ � �����
	inc byte ptr [bx]
	mov [bx+si], al
	mov byte ptr [bx+si+1], cr
    inc si
    ret
saveToBuffer endp

;---------------------------

output proc ; ����� �������
	push ax
    push dx
    mov dl, al
    mov ah, 2
    int 21h
    pop dx
    pop ax
    ret
output endp

;---------------------------

charInput proc ; ���� ������� ��� ���
	mov ah, 8
	int 21h
	ret
charInput endp

;---------------------------

isVowel proc ; ����� ZF=1, ���� ����� �������, ��� ZF=0, ���� ���������
	push di
	push cx
	mov di, offset vowels
	mov cx, 12
	repne scasb
	pop cx
	pop di
	ret
isVowel endp
	
;---------------------------

init proc ; ������������� ����������
	mov ax, 3521h
	int 21h
	mov [int21HVector], bx
	mov [int21HVector+2], es

	mov dx, offset intOverlap
	mov ax, 2521h
	int 21h

	mov dx, offset init
	int 27h ;���������� ���������� DOS, �������� ����� ������ ��������������, ��� ��� ����������� ��������� �� ����� ����������� ����������� ��� ��� ������ � ���� ������.
init endp

end start