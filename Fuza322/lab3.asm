.model small
.stack 256
.data
    errorMessage db 'ERROR!','$'
    errorMessageBoundary db 'Range Exception!','$'
    errorMessageZero db 'division by zero Exception!','$'
.code

mainError proc
lea dx, errorMessageZero
mov ah,09h
int 21h
mov ax, 4C00h
mainError endp

checkBoundaryCase proc
cmp ax,-32768
je exceptionCanBeReal
endThisProc:
    jmp return
exceptionCanBeReal:
    cmp bx,-1
    jne endThisProc
    xor dx,dx
    lea dx, errorMessageBoundary
    mov ah,09h
    int 21h
    mov ax, 4C00h
    int 21h
return:
    ret
checkBoundaryCase endp

main proc
mov ax,@data
mov ds,ax
call INPUT
mov  bx,ax
call INPUT
cmp ax,0
jne NEXT
call mainError
int 21h

NEXT:
xor  dx,dx
xchg ax,bx
call checkBoundaryCase

cwd
idiv  bx

call OUTPUT
call NewLine

cmp dx,0
jns finalOutput
neg dx
finalOutput:
mov  ax,dx
call OUTPUT
mov ax, 4C00h
int 21h
main endp

OUTPUT proc
    push ax
    push bx
    push cx
    push dx
    xor  cx,cx
    mov bx,10

    cmp ax,0
    jns InToTheStack  
    push ax
    push dx
    mov dl,'-'
    mov ah,02h
    int 21h
    pop dx
    pop ax
    neg ax
     
        InToTheStack:
        cmp ax, 10 
        jc exit
        xor dx,dx
        div bx
        push dx
        inc cx
    jmp InToTheStack
    exit:        
        push ax
        inc cx
          
    FromTheStack:        
    pop dx
        add dx, '0'
        mov ah, 02h
        int 21h
    loop FromTheStack
     
    pop dx
    pop cx
    pop bx
    pop ax
    ret
OUTPUT endp

NewLine proc
    push ax
    push dx
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret
NewLine endp

INPUT proc
    push bx
    push cx
    push si
    push dx
    xor  ax,ax
    xor  bx,bx
    xor  cx,cx
    xor  si,si
    xor  dx,dx
    WriteSymbol:
        mov ah, 01h
        int 21h    
        cmp al, 8 
        jz BackspaceClick
        cmp al, 13
        jz FinishInput

        cmp al,'-'
        jz minusTrigger

        cmp al, '0'
        jb ERROR
        cmp al, '9'
        ja ERROR
        sub al, '0'
        
        mov cl, al
        mov ax, 10
        mul bx
        call rangeCheck
        mov bx, ax
        add bx, cx
        call rangeCheck
    jmp WriteSymbol
     
    minusTrigger:
    cmp bx,0
    jnz ERROR
    cmp si,0
    jnz ERROR
    mov si,1
    jmp WriteSymbol

    BackspaceClick:
        push ax
        push dx
        mov dl, ' '
        mov ah, 02h
        int 21h
     
        mov dl, 8
        mov ah, 02h
        int 21h
     
        cmp bx, 0
        jnz notMinus
        mov si, 0
        pop dx
        pop ax
        jmp WriteSymbol
         
        notMinus:
            mov ax, bx
            cmp ax, 10
            jnc deleteLastDigit

        mov bx, 0
        pop dx
        pop ax
        jmp WriteSymbol

        deleteLastDigit:    
            mov dx, 0
            mov bx, 10
            div bx
            mov bx, ax
            pop dx
            pop ax
            jmp WriteSymbol

    ERROR:
    call NewLine
    lea dx, errorMessage
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h
    
    FinishInput:
        mov ax,bx
    cmp si,0
        jz endInput
        neg ax
    endInput:
        pop dx
        pop si
        pop cx
        pop bx
        ret
INPUT endp

rangeCheck proc
    jc ERROR
    cmp si, 0
    jz pozitiveCheck
    cmp ax, 32769
    jnc ERROR
    cmp bx, 32769
    jnc ERROR
    jmp endCheck
    pozitiveCheck:
        cmp ax, 32768
        jnc ERROR
        cmp bx, 32768
        jnc ERROR
endCheck:        
    ret
rangeCheck ENDP
end main