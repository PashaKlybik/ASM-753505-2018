CSEG segment
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG    
org 100h
Start:
    jmp Here    

Int_21h_proc proc            
    cmp ah,9                 
    je IsItInterrupt09h
    jmp dword ptr cs:[Int_21h_vect]

Here:
    mov ah,35h            
    mov al,21h            
    int 21h
    mov word ptr Int_21h_vect,bx
    mov word ptr Int_21h_vect+2,es
    mov ax,2521h        
    mov dx,offset Int_21h_proc 
    int 21h
    mov ah, 9
    lea dx, Message
    int 21h 
    mov dx,offset Here
    int 27h        

IsItInterrupt09h:        
 pushf
    push ax
    push cx
    push dx
    push si
    push di
    push cs        
    pop es            
    cld
    mov si, dx
    StringHandling:
        lodsb
        cmp al, '$'
        je StringFinished
        lea di, letters
        mov cx, 10
        repne scasb        
        je StringHandling
        mov dx, [si-1]
        mov ah, 02h
        int 21h
        jmp StringHandling
    StringFinished:
    pushf
    call dword ptr cs:[Int_21h_vect]
    sti
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    popf
    iret
Int_21h_vect dd ?
Int_40h_vect dd ?
letters db "YaeiouyAEIOU"
int_21h_proc endp

Message db "Zaebala Proga.",10,13,'$'

CSEG ends
end Start 