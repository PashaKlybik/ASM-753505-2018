.model small
.stack 256
.data
 strLine db 255,255 dup('$')
 buffer db 255 dup('$')
 result db 255 dup('$')
 BoolExit db 0
 beginSI dw 0
 rezSI dw 0
 indexResult dw 0
 rezCX dw 0
 message1 db 'Enter string: $'
 message2 db 'Result string: $'
.code
 ENTER MACRO
   MOV DL, 10
   MOV AH, 02h
   INT 21h
   MOV DL, 13
   MOV AH, 02h
   INT 21h
 ENDM

 out_str MACRO str
   push ax
   mov ah, 09h
   mov dx, offset str
   int 21h
   pop ax
 endm

main:
    mov ax, @data
    mov ds, ax
    mov es, ax
  out_str message1
  ENTER
  MOV AH, 0Ah
  LEA dx, strLine
  int 21h
  lea si, strLine+1
  lea di, buffer
  inc si
  mov beginSI, si
  mov ah,0
  mov cx,0
  push ax
  lea ax,result
  mov indexResult,ax
  pop ax
  mov ax,0
  cld
 cicle:
    lodsb
    cmp ax,13
    jnz next
       dec si 
       dec di
       push ax
       mov ah,1
       mov BoolExit,ah
       pop ax 
       jmp Space
  next:
    cmp ax, 32
    jnz next1
      dec si
      dec di
      jmp Space
  next1:
    inc cx
    dec si
    cld
    movsb
    jmp cicle 

 Space:
    mov ax,0
    mov rezSI, si
    mov rezCX, cx
    mov si, beginSI
    cmp cx,ax
    jnz nextSpace
      mov si, rezSI
    inc si
    mov beginSI, si
    push ax
    mov ah,1
    cmp ah,BoolExit
    pop ax
    jnz next5
       lea dx, result
       jmp exit
  next5:
    mov ax,0
    mov cx,0
    lea di,buffer
    jmp cicle
  nextSpace:
   cicleSpace:
    mov bl, [si]
    mov al, [di]
    cmp bl, al 
    jz next2
      jmp exitSpace     
  next2:
    lodsb   
    dec di
  loop cicleSpace
 exitSpace:
    push ax
    mov ax,0
    cmp cx, ax
    pop ax
   jz Copy 
    mov si, rezSI
    inc si
    mov beginSI, si
    push ax
    mov ah,1
    cmp ah,BoolExit
    pop ax
    jnz next3
       lea dx, result
       jmp exit
  next3:
    mov ax,0
    mov cx,0
    lea di,buffer
    jmp cicle
 
 Copy:
   push si
   push di
   lea si, buffer
   mov cx,rezCX
   mov di, indexResult
  cicleCopy:
     movsb
  loop cicleCopy
   mov [di], ' '
   inc di
   mov indexResult, di       
   pop di
   pop si 
  mov si, rezSI
    inc si
    inc di
    mov beginSI, si
    push ax
    mov ah,1
    cmp ah,BoolExit
    pop ax
    jnz next4
       lea dx, result
       jmp exit
  next4:
    mov ax,0
    mov cx,0
    lea di, buffer
    jmp cicle 

exit:
  ENTER
  out_str message2
  ENTER
  out_str result
  ENTER
    mov ax, 4c00h
    int 21h
end main