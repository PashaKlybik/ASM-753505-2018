.model small
.stack 256
.data
    a dw ?
    b dw ?
	c dw ?
	d dw ?
	tn dw ?
	checker dw 0
	inpbuf db 7, 0, 7 dup(0)
	CR_LF db 0Dh, 0Ah, '$'
.code
main:
    mov ax, @data
    mov ds, ax
	
	call IntInput
	mov ax, tn
	mov a, ax
	
	call IntInput
	mov ax, tn
	mov b, ax
	
	mov ax, a
	mov bx, b
	xor dx, dx
	div bx
	
	xor ah, ah
	
	call OutInt
	

	mov ax, 4c00h
	int 21h
	ret
	
	OutInt proc near
	push ax
	push bx
	push cx
	push dx
	
    xor     cx, cx
    mov     bx, 10 
oi2:
    xor     dx,dx
    div     bx

    push    dx
    inc     cx

    test    ax, ax
    jnz     oi2

    mov     ah, 02h
oi3:
    pop     dx

    add     dl, '0'
    int     21h

    loop    oi3
	
	lea dx, CR_LF
    mov ah, 09h
    int 21h
    
	pop dx
	pop cx
	pop bx
	pop ax
    ret
	OutInt endp
	
IntInput proc
	push ax
	push dx
	mov ah, 0Ah
	mov dx, offset inpbuf
	int 21h
	lea dx, CR_LF
    mov ah, 09h
    int 21h
	lea si, inpbuf+1
	lea di, tn
	call tstoint
	pop dx
	pop ax
	ret
IntInput endp

	
Str2Num proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
 
        push    ds
        pop     es
 
        mov     cl, ds:[si]
        xor     ch, ch
 
        inc     si
 
        mov     bx, 10
        xor     ax, ax
 
cycle1:
        mul     bx        
        mov     [di], ax  
        cmp     dx, 0     
        jnz     errr
 
        mov     al, [si]   
        cmp     al, '0'
        jb      errr
        cmp     al, '9'
        ja      errr
        sub     al, '0'
        xor     ah, ah
        add     ax, [di]
        jc      errr    
        inc     si
 
        loop    cycle1

 
        mov     [di], ax
        clc
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
errr:
        xor     ax, ax
        mov     [di], ax
        stc
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
Str2Num endp

SIntInput proc
	push bx
	push cx
	push dx
	push si
	
	xor si, si
	xor bx, bx
	xor cx, cx
	
	mov ah, 01h
	int 21h
	cmp al, '-'
	jne unc	
	mov si, 1
	
mloop:
	mov ah, 01h
	int 21h
unc:
	cmp al, '9'
	ja zhzh
	sub al, '0'
	jb zhzh
	xor ah, ah
	mov cx, ax
	mov ax, bx
	shl ax, 1
	shl bx, 3
	add bx, ax
	add bx, cx
	
	jmp mloop
zhzh:
	test si, si
	jz fin
	neg bx
fin:
	test ax, ax
	jz ovrf
	xor bx, bx
ovrf:
	lea dx, CR_LF
    mov ah, 09h
    int 21h
	
	mov ax, bx
	
	pop si
	pop dx
	pop cx
	pop bx
	ret
SIntInput endp

SIntOut proc
	
	push bx
	push cx
	push dx
	push ax
	mov bx, 10
	xor cx, cx
	test ax, ax
	jns cycl
	mov ah, 02h
	mov dx, '-'
	int 21h
	pop ax
	push ax
	neg ax
cycl:
	call OutInt
	
	pop ax
	pop dx
	pop cx
	pop bx
	
	ret
SIntOut endp


tstoint proc
	push    ax
    push    bx
    push    cx
    push    dx
    push    ds
    push    es
    push    ds
    pop     es 
    mov     cl, ds:[si]
    xor     ch, ch
 
    inc     si
 
    mov     bx, 10
    xor ax, ax
    
    mov bl, [si]
    cmp bl, '-'
    jne @cycl
    mov checker, 1
    inc si
    dec cl
@cycl:
		mov bx, 10
        mul     bx        
        mov     [di], ax  
        cmp     dx, 0     
        jnz     @err
 
        mov     al, [si]   
        cmp     al, '0'
        jb      @err
        cmp     al, '9'
        ja      @err
        sub     al, '0'
        xor     ah, ah
        add     ax, [di]
        jc      @err    
        inc     si
 
        loop    @cycl

        cmp checker, 1
        jne pls
        neg ax
pls:
        mov     [di], ax
        mov checker, 0
        clc
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
@err:
		mov checker, 0
        xor     ax, ax
        mov     [di], ax
        stc
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
tstoint endp
end main