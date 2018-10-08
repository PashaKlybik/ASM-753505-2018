; Лабораторная №1(Вариант 8)
.MODEL SMALL
.STACK 100h

.DATA
	a dw 10
	b dw 23
	c dw 19
	d dw 7
.CODE
START:
    mov ax,@data
	mov ds,ax


	mov ax,a
	mov bx,b
    cmp ax,bx
	jae label1
	mov ax,b		; if a < b
	mov bx,a
label1:

	cmp c,ax
	jbe label2
	mov ax,c		; if c > ax
	jmp label3
label2:
	cmp c,bx
	jae label3		
	mov bx,c		; if c < bx
label3:

	cmp d,ax
	jbe label4
	mov ax,d		; if d > ax
	jmp label5
label4:
	cmp d,bx
	jae label5	
	mov bx,d		; if d < bx
label5:

	sub ax,bx


	mov ah,4ch
    int 21h
END START