CSEG segment
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG
org 100h
Start:
    jmp installation
 
resident proc
    push ax    
    cmp al, 3Bh
    jne f2 
    push cx    
    mov ah, 5      
    mov cx, 'h'    
    int 16h
    mov ah, 5
    mov cx, 'e'
    int 16h
    mov ah, 5
    mov cx, 'l'
    int 16h
    pop ax
    mov al, 19h
    jmp to_ret
f2:
    cmp al, 3Ch    
    jne f3
    push cx    
    mov ah, 5      
    mov cx, 's'    
    int 16h
    mov ah, 5
    mov cx, 'a'
    int 16h
    mov ah, 5
    mov cx, 'v'
    int 16h
    pop ax
    mov al, 12h
    jmp to_ret
f3:
    cmp al, 3Dh    
    jne f4
    push cx    
    mov ah, 5      
    mov cx, 'o'    
    int 16h
    mov ah, 5
    mov cx, 'p'
    int 16h
    mov ah, 5
    mov cx, 'e'
    int 16h
    pop ax
    mov al, 31h
    jmp to_ret
f4:
    cmp al, 3Eh    
    jne f5
    push cx    
    mov ah, 5      
    mov cx, 'e'    
    int 16h
    mov ah, 5
    mov cx, 'd'
    int 16h
    mov ah, 5
    mov cx, 'i'
    int 16h
    pop ax
    mov al, 14h
    jmp to_ret
f5:
    cmp al, 3Fh    
    jne to_original_int15
    push cx    
    mov ah, 5      
    mov cx, 'c'    
    int 16h
    mov ah, 5
    mov cx, 'o'
    int 16h
    mov ah, 5
    mov cx, 'p'
    int 16h
    pop ax
    mov al, 15h
 
to_ret:
    pop cx
    jmp dword ptr cs:int15_vector
   
to_original_int15:
    pop ax
    jmp dword ptr cs:int15_vector
 
    int15_vector dd ?
resident endp
 
installation:
    mov ax, 3515h  
    int 21h
 
    mov word ptr int15_vector, bx  
    mov word ptr int15_vector + 2, es  
 
    mov ax, 2515h  
    mov dx, offset resident
    int 21h
 
    mov dx, offset installation
    int 27h
CSEG ends
end Start
