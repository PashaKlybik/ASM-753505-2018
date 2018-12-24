.model small 
.stack 256

data segment
     string db 0ah,100 dup ('$')
data ends
 
code segment
assume cs:code,ds:data


newline PROC
        push AX
        push DX
         mov AH, 02h
        mov DL, 13
        int 21h
        mov DL, 10
        int 21h
         pop DX
    pop AX
ret
newline ENDP
 ;oaaeaiea i?iaaeia
delete proc
        push cx
        push bx
        push ax
    
    lea si, string
    lea di, string
    
cycle:
    ;ia?aae?aai iiea ia ano?aoei i?iaae eeai eiiao no?iee
    cmp byte ptr [si], ' '
    je Space
    cmp byte ptr [si], '$'
    je exit
    
    lodsb
    mov [di], al
     inc di
    jmp cycle
 Space:
    ;i?iaa?yai yaeyaony ee neaa. neiaie i?iaaeii , anee aa , oi i?iioneaai aai
    cmp byte ptr [si+1], ' '
    je Skip
    
    lodsb
    mov [di], al
    inc di
    jmp cycle
Skip:
    inc si
    jmp cycle
    
exit:
    lodsb
    mov [di], al
    lea di, string
        pop ax
        pop bx
    pop cx
ret
delete ENDP

start:
    mov ax, data
    mov ds, ax
    
    mov cx,99
    lea bx,string+1
        
n1:
    mov ah,1
    int 21h
    cmp al,13     ;
    je ex
    cmp al,8
    je backspace
    mov [bx],al
    inc bx
        
    
    loop n1

backspace:
	push ax
	push dx
	
  	cmp bx, 0
	je n1

        mov [bx], '$'
	dec bx
	
	mov DL,' ' 
        mov AH, 02h 
        int 21h 

        ;сдвигаем курсор назад
        mov DL,8 
        mov AH, 02h 
        int 21h 

	pop dx
	pop ax

  	jmp n1

ex: 
    
    

    CALL newline
    CALL delete
    
    mov ah,9
    lea dx,string
    int 21h
  
    CALL newline
    mov ax, 4c00h
    int 21h
code ends
end start


