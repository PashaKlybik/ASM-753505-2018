.model small
.stack 256
.data
    string db 250, 250 dup('$')
.code

main:
	  mov ax, @data
	  mov ds, ax
	MOV es, ax    
 	LEA di, string
	MOV dx, di
	MOV ah, 0ah
	INT 21h
	CALL SEQUENTSTR
	INC dx
	CALL REMOVEIT
	MOV ah, 09h
	INT 21h
	CALL SEQUENTSTR
	MOV ax, 4c00h
	INT 21h

 REMOVEIT proc
	PUSH cx
	PUSH bx
	PUSH ax
	XOR bx, bx
	MOV si, dx
	MOV di, dx

     ControlSimbol:
     	     MOV al, [si]
	     MOV cx, bx
	     repne scasb
	     JE IsItEqual
	     MOV di, dx
	     ADD di, bx
	     MOV [di], al
	     INC bx
     IsItEqual:
	     INC si
	     CMP byte ptr [si], '$'
	     JE FinishIT
	     MOV di, dx
	     JMP ControlSimbol
     FinishIT:
	     MOV byte ptr [di], '$'
	     POP ax
	     POP bx
	     POP cx
	     ret
REMOVE endp

SEQUENTSTR proc
    PUSH ax
    PUSH dx
    MOV ah, 02h
    MOV dl, 10
    INT 21h
    POP dx
    POP ax
    ret
SEQUENTSTR endp
 
end main