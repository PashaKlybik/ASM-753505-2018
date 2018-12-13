; сохранять в cp866
.model  small
.386
CR  =   0Dh
LF  =   0Ah
dos_inp macro   lbl, sz
_ib_    struc  
max db  sz      ; наибольшая длина строки
len db  ?               ; сюда вернется настоящая длина
bf  db  sz dup(?)   ; тут будет то, что ввели
_ib_    ends            
lbl _ib_ <>
endm
.stack  100
.data
req db  CR, LF, 'Enter string:$'
dos_inp buf1, 10
dos_inp buf2, 20
vowels  db  '123456789'
vow_sz  =   $ - vowels
.code   
start:  
    mov ax, @data
    mov ds, ax
    mov es, ax
    call    entr
    lea dx, buf1
    call    my_gets
    call    entr
    lea dx, buf2
    call    my_gets
    call    crlf
    lea dx, buf1.bf
    mov ah, 9
    int 21h
    call    crlf
    lea dx, buf2.bf
    mov ah, 9
    int 21h
    mov ax, 4C00h
    int 21h
 
my_gets:pusha
    mov si, dx
    lodsw
    mov di, si
    movzx   cx, al
    xor bx ,bx
@l: xor ax,ax
    int 16h
    cmp al, CR
    jz  done
    push    cx
    push    di
    lea di, vowels
    mov cx, vow_sz
    repne   scasb
    pop di
    jz  @F
    stosb
    inc bx
    int 29h
@F: pop cx
    loop    @l
done:   mov al, '$'
    stosb
    mov [si-1],bl
    popa
    ret
entr:   lea dx, req
    mov ah, 9
    int 21h
    ret
; newline
crlf:
    mov ax, 0D0Ah
    int 29h
    xchg    ah,al
    int 29h
;
 
    end start