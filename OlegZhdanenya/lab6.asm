; tasm experiment.asm
; tlink /t prog.obj (/t - for COM)
;line 149?
.model tiny
.code
.186 
.startup
    jmp real_start

    identifier  dw 752Fh
    scanA       db 1Eh
    scanB       db 30h
    scanC       db 2Eh
    scanD       db 20h
    scanE       db 12h
    bufferStartIndex dw 1Eh
    bufferEndIndex   dw 3Ch
    scanAscii   dw ?
    usedBufferCells dw ?

new09handler proc far
    pushf ;push all flags
    pusha ;push all registers
    push  es
    push  ds
    sti
      
    push  cs                      ;DS=CS
    pop   ds

    in    al, 60h ;to work with input port
    cmp   al, scanA
    je replaceA
    cmp   al, scanB
    je replaceB
    cmp   al, scanC
    je replaceC
    cmp   al, scanD
    je replaceD
    cmp   al, scanE
    je replaceE
    jmp call_old_09 


replaceA:
    mov scanAscii, 0231h
    jmp endcheck
replaceB:
    mov scanAscii, 0332h
    jmp endcheck
replaceC:
    mov scanAscii, 0433h
    jmp endcheck
replaceD:
    mov scanAscii, 0534h
    jmp endcheck
replaceE:
    mov scanAscii, 0635h
    jmp endcheck

endcheck:      
    in al, 61h ;confirm scan-code read
    mov ah, al 

    or al, 80h
    out 61h, al

    and al, 7Fh
    out 61h,al
  
    cli
    mov al,20h
    out 20h,al
    
    ;write scan-code and ASCII code to keyboard buffer
    mov ax, 40h
    mov es, ax
    mov bx, 1Ah
    mov cx, es:[bx]
    mov di, es:[bx+2]
    cmp cx, di
    je write    ;empty buffer
    jg startAfterEnd

startBeforeEnd:
    mov dx, di
    sub dx, cx
    jmp checkBuf

startAfterEnd:
    mov dx, bufferEndIndex
    sub dx, bx
    inc dx
    inc dx
    mov usedBufferCells, dx
    mov dx, di
    sub dx, bufferStartIndex
    add dx, usedBufferCells

checkBuf:
    cmp dx, 30
    je bufFull
    jmp write

write:
    mov dx, scanAscii    
    mov es:[di], dl
    mov es:[di+1], dh
    
    cmp di, bufferEndIndex
    jne normalIdx
    mov di, bufferStartIndex
    jmp storeIdx

normalIdx:
    inc di
    inc di
storeIdx:
    mov es:[bx+2],di
    jmp return
    
bufEnd:
    cmp di, bufferStartIndex
    je bufFull    

bufFull:
return:    
    pop   ds
    pop   es
    popa
    popf
    iret
      
call_old_09:
    cli
    pop   ds
    pop   es
    popa
    popf
    jmp dword ptr cs:old_09_address

    old_09_address  dd ?

new09handler endp
    
real_start:
      mov   ax,3509h
      int   21h
 
      cmp   byte ptr ds:[82h],'-'
      jne   install
      cmp   word ptr es:identifier,752Fh
      je remove
      jmp not_installed      

install:
      cmp   word ptr es:identifier,752Fh
      je    already_inst
 
      push  es
      mov   ax,ds:[2Ch]             ;psp
      mov   es,ax
      mov   ah,49h
      int   21h
      pop   es
      jc    not_mem
 
      mov   word ptr cs:old_09_address, bx
      mov   word ptr cs:old_09_address+2, es
      mov   ax,2509h
      mov   dx,offset new09handler
      int   21h
      mov   dx,offset ok_installed
      mov   ah,9
      int   21h

      mov   dx,offset real_start
      int   27h
 
remove:
      cmp   word ptr es:identifier,752Fh
 
      push  es
      push  ds
      mov   dx,word ptr es:old_09_address
      mov   ds,word ptr es:old_09_address+2
      mov   ax,2509h
      int   21h

      pop   ds
      pop   es
      mov   ah,49h
      int   21h
      jc    not_remove
 
      mov   dx,offset removed_msg
      mov   ah,9
      int   21h
      jmp   exit
 
not_installed:
      mov   dx, offset noinst_msg
      mov   ah,9
      int   21h
      jmp   exit
 
not_remove:
      mov   dx, offset noremove_msg
      mov   ah,9
      int   21h
      jmp   exit
 
already_inst:
      mov   dx, offset already_msg
      mov   ah,9
      int   21h
      jmp   exit
 
not_mem:
      mov   dx, offset nomem_msg
      mov   ah,9
      int   21h
 
exit:
      int  20h
 
ok_installed      db 'Resident successful installed$'
already_msg       db 'already installed$'
nomem_msg         db 'No free memory for staying resident$'
removed_msg       db 'successful removed$'
noremove_msg      db 'Can not remove resident. Error$'
noinst_msg        db 'Resident not installed. Nothing remove$'
end

