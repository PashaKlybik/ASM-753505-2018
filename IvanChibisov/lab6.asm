.model tiny
.386
.code
org 100h
Start:
jmp Initialisation

Int_21h_proc proc
       
	cmp ah, 09h
	jz It_is_09
	jmp dword ptr cs:[Int_21h_vect]
	It_is_09:
        push ds
        push si 
        push es
        push di 
        push dx
        push cx 
        push bx 
        push ax
        pushf
        push cs
	push cs
        cld
        pop es
        mov si, dx
	lea di, InputStr
	xor cx, cx
       copy:
		lodsb
		cmp al, '$'
		jz End_loop
		inc ch
		stosb
	jmp copy
  End_loop:
        pop ds
   mov inputStr_length,ch
   mov bx,0
  lea si, ResidentStr
  cicleLength:
   lodsb
   cmp al, 36
   jz endLength
   inc bx
  jmp cicleLength
 endLength:
  mov ax,bx
  mov bl,1
  div bl
  mov resident_length, al
  mov ah, resident_length
   push bx
   lea bx, Temp_max_str
   mov offset_temp_max, bx
   pop bx 
        
    
    lea si, ResidentStr
    lea di, InputStr
    cld
   cicle_i:
    push ax
    push bx
    mov ah,i
    mov al, resident_length
    cmp ah,al
    pop bx
    pop ax
   
    jl next_cicle_i
    jmp end_cicle_i
   next_cicle_i:
    
    cicle_j:
      push ax
     push bx
     mov ah,j
     mov bh, InputStr_length
     cmp ah,bh
     pop bx
     pop ax
     jl next_cicle_j
     jmp end_cicle_j
    next_cicle_j:
      cmpsb
      pushf
      dec si
      popf 
      jz next
       push ax
        mov ah, j
        inc ah
        mov j,ah
       pop ax
       jmp cicle_j
     next: 
      dec di
      push ax
      mov ah,i
      mov indexBegin1,ah
      mov ah,j
      mov indexBegin2,ah
      mov ah, 0 
      mov tempCount, ah
      pop ax
      push ds
      push si 
      push es
      push di
       cicle_while:
        cmpsb
        jz next_while
        jmp end_while
       next_while:
        dec si
        push es
        push di
        mov di, offset_temp_max
        movsb
        mov offset_temp_max, di
        pop di
        pop es  
        push bx
        mov bh, tempCount
        inc bh
        mov tempCount, bh
        mov bh , indexBegin1
        inc bh
        mov indexBegin1, bh
        mov bh,indexBegin2
        inc bh
        mov indexBegin2, bh
        pop bx
         push ax 
         push bx
         push cx
         push dx
           mov ah, indexBegin1
           mov bh, indexBegin2
           mov ch, resident_length
           mov dh, inputStr_length
          cmp ah,ch
          jz next_if_in_while1
          pop dx
          pop cx 
          pop bx 
          pop ax 
          jmp cicle_while
         next_if_in_while1:
          cmp bh,dh
          pop dx
          pop cx 
          pop bx
          pop ax 
          jz next_if_in_while2
          jmp cicle_while
         next_if_in_while2:
          jmp end_while  
       jmp cicle_while
      end_while:
      push es
      push di
      push ax
        mov di, offset_temp_max
        mov al, 36
        stosb
        mov offset_temp_max, di
      pop ax
      pop di
      pop es  
     pop di
     pop es
     pop si
     pop ds
      push ax
      push bx
        mov ah, MaxCount
        mov bh, tempCount
        cmp ah, bh
        jl next_in_max_str
        jmp next_cicle_j2
       next_in_max_str:
        mov MaxCount, bh
                 push si
                 push di
                 push ax
                 push bx
                 pushf
                 lea si, Temp_max_str
                lea di, Max_str
                 cicle_copy:
                  movsb
                  dec si
                   lodsb
                   cmp al, 36
                   jnz cicle_copy
                  jmp end_cicle_copy
                 end_cicle_copy:
                  popf
                  pop bx
                  pop ax
                  pop di
                  pop si
     next_cicle_j2:
      pop bx
      pop ax 
     push ax
      mov ah, j
      inc ah
      mov j,ah
     pop ax
     jmp cicle_j     
    end_cicle_j:
   push ax
    mov ah, i 
    inc ah
    mov i,ah
    mov ah,0
    mov j,ah
   pop ax
   lea di, InputStr
   push bx
    lea bx, Temp_max_str
    mov offset_temp_max, bx
   pop bx
   inc si
   jmp cicle_i
  end_cicle_i:
        push ax
         mov al, 0 
         mov i,al
         mov j,al
        pop ax
        mov ah, 09h
        mov dx, offset Max_str
        popf
        pushf
        call dword ptr cs:[Int_21h_vect]
   lea di, Max_str
   mov cx, 254
  NullCicle:
    mov al,'$'
    stosb
   loop NullCicle
  lea di, Temp_max_str
   mov cx, 254
  NullCicle2:
    mov al,'$'
    stosb
  loop NullCicle2
  push ax
   mov ah,0
   mov MaxCount, ah
  pop ax
   pop ax 
   pop bx 
   pop cx 
   pop dx
   pop di
   pop es
   pop si
   pop ds
iret

Int_21h_proc endp

	Int_21h_vect dd ?
        ResidentStr db 'Karl u klary read writeln rapapa never lets you go$'
        InputStr db 255 dup('$')
        Max_str db 255 dup('$')
        MaxCount db 0
        indexBegin1 db 0
        indexBegin2 db 0
        Temp_max_str db 255 dup('$')
        TempCount db 0
        i db 0
        j db 0
        resident_length db 0
        inputStr_length db 0
        offset_temp_max dw 0
	
Initialisation:
	mov ah, 35h
	mov al, 21h
	int 21h
	
	mov word ptr Int_21h_vect, bx
	mov word ptr Int_21h_vect+2, es
	
	mov ax, 2521h	
	
	mov dx, offset Int_21h_proc
	int 21h
	
	mov dx, offset Initialisation
	int 27h
	
end Start