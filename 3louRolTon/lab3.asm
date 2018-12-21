.model small 
.stack 256 
.data 
    errorMessage db "ERROR!$" 
.code 

newline PROC         
    push AX 
    push DX 
    MOV AH, 02h 
    MOV DL, 13 
    int 21h 
    MOV DL, 10 
    int 21h 
    pop DX 
    pop AX 
    RET 
newline ENDP 

output PROC        
    push AX 
    push BX 
    push CX     
    push DX 
    mov CX,0 
    mov BX,10 

    cycleDivision:        
        CMP AX,10 
        JC exit 
        mov DX, 0 
        div BX 
        inc CX 
        push DX 
    JMP cycleDivision 

    exit: 
        push AX 
        inc CX 

    cycleOutput:     
        pop DX 
        add DX,48 
        mov ah, 02h 
        int 21h 
    LOOP cycleOutput 

    pop DX 
    pop CX 
    pop BX 
    pop AX 
    ret 
output ENDP 

CheckSymbol PROC    

    push AX 
    test AX,AX 
    JNS out 
    push AX 
    mov DL,'-' 
    mov ah, 02h 
    int 21h 
    pop AX 
    neg AX 
    out: 
        CALL output 
        pop AX 
    ret 
CheckSymbol ENDP 

input PROC 
    push BX 
    push CX 
    push DX 
    push SI    

    mov AX, 0 
    mov BX, 0 
    mov CX, 0 
    mov DX, 0 
    mov SI, 0    
    enterSymbol: 
        mov ah, 01h 
        int 21h 
        cmp AL, 13
        JZ stopInput 
        cmp AL, 8 
        JZ backspace 
        cmp AL, 45
        JZ check    

        sub AL,48 
        cmp AL,10 
        JNC error 

        mov CL, AL 
        mov AX, 10 
        mul BX 
        JC error 
        mov BX,AX         
        add BX, CX 
        JC error 

    JMP enterSymbol 
 
    check:        
        mov SI, 1
    JMP enterSymbol

    error: 
        CALL newline
        LEA DX, errorMessage 
        mov AH, 09h 
        int 21h 
        mov ax, 4c00h 
        int 21h 
            
    backspace: 
        push AX 
        push DX 

        mov DL,' ' 
        mov AH, 02h 
        int 21h 

        mov DL,8 
        mov AH, 02h 
        int 21h 
    
        mov AX,BX 
        cmp AX,10 
        JNC continue 

        mov BX,0 
        pop DX 
        pop AX 
    JMP enterSymbol 
    
    continue: 
        mov DX, 0 
        mov BX,10 
        div BX 
        mov BX,AX 
        pop DX 
        pop AX 
        
    JMP enterSymbol 

    stopInput:
        cmp SI,1
        JZ  minus
        pop SI
        mov AX, BX 
        CALL range
        pop DX 
        pop CX 
        pop BX 
        ret

        minus:
            NEG BX
            mov AX, BX
            CALL range
            pop SI 
            pop DX 
            pop CX 
            pop BX 
        ret     
input ENDP 

range PROC
    push AX
    cmp AX,0
    JG module    
    NEG AX 
    
    module:    
    cmp AX,32767
    JO error
    pop AX
ret
range ENDP

divide PROC
        
    push BX
    push DX

    cmp BX,0
    JZ error
    cmp AX,0
    JL negative
    
    mov DX,0
    IDIV BX
    pop DX
    pop BX
    ret
            
    negative:
        NEG AX
        mov DX,0
        IDIV BX
        NEG AX

    pop DX
    pop BX

ret
divide ENDP


main: 
    mov AX, @data 
	mov ds, ax
	mov es, ax
    CALL input 
    mov CX, AX
    CALL CheckSymbol
    CALL newline 

    CALL input 
    mov BX, AX
    CALL CheckSymbol
    CALL newline 
    
    mov AX, CX
    CALL divide
    CALL CheckSymbol
    CALL newline
    mov ax, 4c00h 
    int 21h 
end main
