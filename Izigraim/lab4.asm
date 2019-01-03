.model   small
.stack 100h
.data 
 
    max   db   120      
    len   db   0 
    string   db   80 dup (0) 
    ten dw 10
     
    strCMD db 10, 13,'> $'
    strOF db 10, 13,'Overlim. Please, repeat :$'
    EnterN db    13, 10, "Enter n: $" 
    Alphabet db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890", 13, 10, '$'
    PressAny      db   13, 10, "Press any key", 13, 10, "$" 
    Result      db   13, 10, "Result      : $"     
    EnterString      db   "Enter string: $" 
    n dw 0
    
.code 
 
Delete PROC         ;show ' ' and move it on 1 position left  
    push ax        
    push dx 
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    mov ah, 02h
    int 21h

    pop dx
    pop ax 
    ret
Delete ENDP

Show_AX proc
    
    push ax
    push bx
    push cx
    push dx
    
    xor cx,cx
    mov bx,10
    
DivCycle:
    xor dx,dx
    div bx
    push dx         ; v stek kladem poslednee chislo
    inc cx
    cmp ax, 0
    jnz DivCycle
    
OutputCycle:
    pop dx          ; CX raz vipolnyaem cikl
    add dl, '0'    
    mov ah, 02h
    int 21h
    loop OutputCycle
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
    Show_AX endp

readInput proc
            
    push bx
    push cx
    push dx
    push si
    
    xor bx,bx
    xor si,si
InputBegin:

    mov ah, 08h         ;read simbol, but not show it
    int 21h
    
    cmp al, 13          ; Enter.
    jz FinishInput
    
    cmp al, 8           ; Backspace.
    jz Backspace
    
    cmp al, 27         ; Escape.
    JZ Escape
    
    cmp al, '9'  
    ja InputBegin     

    cmp al, '0'
    jb InputBegin
    
    mov ah, 02h 
    mov dl, al            ; show simbol on display
    int 21h
    
    sub al, '0'        
    
    xor ch,ch
    mov cl,al          
    mov ax,bx          
    mul ten
    cmp dx, 0           ; if dx!=0, number is more than 16 bit
    jnz Overlim
    add ax, cx
    jc Overlim
    mov bx, ax
    inc si
    jmp InputBegin
    
Backspace:
    mov ax, bx
    xor dx, dx
    div ten
    mov bx, ax
    lea dx, strCMD
    push ax
    
    mov ah, 9
    int 21h
    pop ax
    call Show_AX
    JMP InputBegin
    
Escape:
    mov cx, si
    xor si, si
    xor bx, bx
    inc cx
ClearLoop:
    mov dl, 8       ; move left on 1 position(if we can do it)
    mov ah, 02h
    int 21h
    call Delete
    loop ClearLoop
    jmp InputBegin
    
Overlim:
    mov bx,0
    mov   ah, 9           
    mov   dx, offset strOF        
    int   21h
    jmp InputBegin
    
FinishInput:
    mov ax, bx
    pop si
    pop dx
    pop cx
    pop bx
    ret
    
    readInput endp

 

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
   repne scasb    ;????????? ?????????? ???????? . ???????????? ??????
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
    
    lodsb         ;???????? ??????
    call isLetter
    jc  checkIsletter ; ???? ???????
    
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
    
    call readInput
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
