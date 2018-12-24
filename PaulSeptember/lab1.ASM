model small
stack 200h
.data
a dw 10
b dw 10
c dw 10
d dw 10

.code
start:  
	mov ax,@data
        mov ds,ax

        mov ax, c
        mul ax
        mul ax		;ax = c^4
        mov bx, a
        and bx, b	;bx = a & b
        cmp ax, bx
        jne else1
        cond1:
                mov ax, c
                div d
                div b		
                add ax, a	;ax = c / d / b + a
                jmp exit
        else1:
                mov ax,a
                mul a
                mul a		;ax = a^3
                mov bx, ax
                mov ax,b
                mul b
                mul b		;ax = b^3
                add ax, bx
                mov bx,b
                add bx,c
                cmp ax,bx	;a^3 + b^3 = c + b ?
                jne else2
                cond2:
                        mov ax, a
                        mov bx, b
                        add bx, c
                        xor ax, bx	;ax = a xor (b + c) 
                        jmp exit
                else2:
                        mov ax, b	
                        shr ax, 3	;ax = b >> 3

exit:
        mov ax, 4c00h 
        int 21h
end start