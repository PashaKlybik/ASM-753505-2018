.MODEL SMALL
.STACK 100h
.DATA	
.CODE

START:
   	mov ax,@data
	mov ds,ax

	mov ah,0Ah
	int 21h

	mov ah,4ch
    	int 21h
END START
