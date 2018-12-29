.model   small
.stack 100h
.data 
 
    max   db   80      
    len   db   0 
    string   db   80 dup (0) 
     
    
    EnterN db    13, 10, "Enter n: $" 
    Alphabet db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890", 13, 10, '$'
    PressAny      db   13, 10, "Press any key", 13, 10, "$" 
    Result      db   13, 10, "Result      : $"     
    EnterString      db   "Enter string: $" 
    n dw 0
    
.code 
 
InputInt proc 
 
    mov ah,0ah
    xor di,di
    mov dx,offset buff 
    int 21h 
    mov dl,0ah
    mov ah,02
    int 21h 
    

    mov si,offset buff+2  
    cmp byte ptr [si],"-" 
    jnz ii1
    mov di,1  
    inc si    
ii1:
    xor ax,ax
    mov bx,10 
ii2:
    mov cl,[si] 
    cmp cl,0dh  
    jz endin
    
    cmp cl,'0'  
    jb er
    cmp cl,'9'  
    ja er
 
    sub cl,'0' 
    mul bx     
    add ax,cx  
    inc si     
    jmp ii2    
 
er: 
    mov dx, offset error
    mov ah,09
    int 21h
    int 20h
 
endin:
    cmp di,1 
    jnz ii3
    neg ax   
ii3:
    ret
 
error db "incorrect number$"
buff    db 6,7 Dup(?)
InputInt endp 
 

 InputString   proc  
    push dx
    push ax
    
    lea   dx, EnterString   
    mov   ah, 9 
    int   21h
 
    lea   dx, max      
    mov   ah, 10
    int   21h
    
    pop ax
    pop dx
    ret 
InputString   endp 


isLetter   proc     
   push ax
   push cx
   lea di, Alphabet
   mov cx, 62
   repne scasb    
   jne notLetter
letter:
   inc   bp     
   stc         
   pop cx
   pop ax
   ret 
notLetter:
   clc        
   pop cx
   pop ax
   ret 
isLetter   endp

deleteWord proc
    push cx
    push bx
    push ax
    
    xor cx, cx
    mov cx, bp
    DelWordLoop:
        dec si
        mov di, si
        DelLetterLoop:      
            mov   al, [di]    
            mov   [di-1], al 
            inc   di 
            cmp   al, '$' 
        jne   DelLetterLoop
        xor di, di 
    loop DelWordLoop
    
    pop ax
    pop bx
    pop cx
deleteWord endp 


deleteWords proc
    push ax
    push bx
    
    lea si, string
    xor bp, bp
    xor   bx, bx      
    mov   bl, len       
    mov   [bx+si], byte ptr '$' 
    
    checkIsletter:
    
    lodsb 
    call isLetter
    jc  checkIsletter
    
    cmp bp, n
    jnb checkEndstr

    or bp, bp
    je checkEndstr

    call deleteWord
    
    checkEndstr:
    
    xor bp, bp
    cmp al, '$'
    jne checkIsletter
    
    pop bx
    pop ax
    
    ret
deleteWords endp

main:
   mov   ax, @data 
   mov   ds, ax 
   mov   es, ax 
 
    call   InputString 
    
    mov   ah, 9           
    mov   dx, offset EnterN        
    int   21h
    
    call InputInt
    mov n,ax
    
    call deleteWords
     
     
    lea   dx, Result 
    mov   ah, 9 
    int   21h

    lea   dx, string 
    mov   ah, 9 
    int   21h

    mov ah,4Ch
    int 21h

    end   main  
