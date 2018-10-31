.model small
.stack 100h
.data
    errorMessage db 'ERROR!','$'
    errorMessageBoundary db '-32768,-1 Exception!','$'
    errorMessageZero db 'division by zero Exception!','$'
    result db 'Result', '$'
    residual db 'Residual', '$'
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
call input
mov  bx,ax
call input
cmp ax,0
jne next
call mainError
int 21h
next:
xor  dx,dx
xchg ax,bx
call checkBoundaryCase

cwd
idiv  bx

call show_ax
call endl

cmp dx,0;residual check
jns finalOutput
neg dx
finalOutput:
mov  ax,dx
call show_ax
mov ax, 4C00h
int 21h
main endp
Show_AX proc
    push ax
    push bx
    push cx
    push dx
    xor  cx,cx
    mov bx,10

    ;sign check
    cmp ax,0
    jns toStack;if not negative
    
    push ax
    push dx
    mov dl,'-'
    mov ah,02h
    int 21h
    pop dx
    pop ax
    neg ax
     
    ;output with the help of stack
    toStack:
        cmp ax, 10 
        jc exit
        xor dx,dx
        div bx
        push dx
        inc cx
    jmp toStack
    exit:        
        push ax
        inc cx
     
    ;output digits from stack     
    fromStack:        
    pop dx
        add dx, '0'
        mov ah, 02h
        int 21h
    loop fromStack
     
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Show_AX endp
endl proc
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
endl endp
input proc
    push bx
    push cx
    push si
    push dx
    xor  ax,ax
    xor  bx,bx
    xor  cx,cx
    xor  si,si
    xor  dx,dx
    symbolEntry:
        mov ah, 01h
        int 21h    
        cmp al, 8 
        jz backspace    
        cmp al, 13
        jz exitInput

        cmp al,'-'
        jz minusTrigger

        cmp al, '0'
        jb error
        cmp al, '9'
        ja error
        sub al, '0'
        
        mov cl, al
        mov ax, 10
        mul bx
        call rangeCheck
        mov bx, ax
        add bx, cx
        call rangeCheck
    jmp symbolEntry
     
    minusTrigger:
    cmp bx,0
    jnz error
    cmp si,0
    jnz error
    mov si,1
    jmp symbolEntry

    backspace:
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
        jmp symbolEntry
         
        notMinus:
            mov ax, bx
            cmp ax, 10
            jnc deleteLastDigit

        mov bx, 0
        pop dx
        pop ax
        jmp symbolEntry

        deleteLastDigit:    
            mov dx, 0
            mov bx, 10
            div bx
            mov bx, ax
            pop dx
            pop ax
            jmp symbolEntry

    error:
    call endl
    lea dx, errorMessage
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h
    
    exitInput:
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
input endp
rangeCheck proc
    jc error
    cmp si, 0
    jz pozitiveCheck
    cmp ax, 32769
    jnc error
    cmp bx, 32769
    jnc error
    jmp endCheck
    pozitiveCheck:
        cmp ax, 32768
        jnc error
        cmp bx, 32768
        jnc error
endCheck:        
    ret
rangeCheck ENDP
end main