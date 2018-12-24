.model small
.stack 100h
.data
	A dw 0
	in_filename db "input.txt"
	n1m1 dw ?
	buf db  100 dup (?)
			matrix dw 100 dup (?)		
			n			dw ? 	
			m			dw ?	
			matrixResult	dw 100 dup (?)	
	strresult db 200 dup (' ')
	endline db 13, 10
	handle dw ?
	out_filename db "output.txt"
.code


proc task
lea bx, matrixResult
			xor cx, cx
			mov cx, n1m1
			
cycle:		
			xor ax, ax
			mov ax,  [di]
			cmp ax, A
			jng notGreate
			mov ax, 0
			
	notGreate:
			mov [bx], ax		
			add bx, 2
			add di, 2			
loop cycle			

	ret
endp task



proc read_from_file
	push ax
	push bx
	push cx
	push dx
	xor dx, dx
	mov ah,3Dh              
	xor al,al              
	lea dx, in_filename
	xor cx,cx              
	int 21h
	
	mov handle, ax
	
	xor dx, dx
	mov bx, ax
	mov ah, 3Fh         
	lea dx, buf
	mov cx, 95       
	int 21h
	
	xor bx, bx
	lea si,buf
	add si, ax
    
	inc si
	inc si
	
	mov byte ptr [si], '$'
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	xor ax, ax
	mov ah,3Eh			
	mov bx, handle
	int 21h                
	
	ret	
endp read_from_file


proc read_matrix
	xor bp, bp
	xor dx,dX
	
beginn:	
	xor ax,ax
	lodsb

	cmp al, '$'
	jz exit

	cmp al, '-'
	jne division 

	inc bp
	jmp beginn

division:
	cmp al, '9'
	jg no_number

	cmp al, '0'
	jb no_number

	sub ax,'0'	
	shl dx,1	
	add ax, dx
	shl dx, 2
	add dx, ax	
	jmp beginn
	
no_number:
	cmp al,' '
	jne abzac
	jmp number
	
abzac:
	inc si
	
number:
	mov ax,dx
	cmp bp, 1
	jne positiveNumber
	neg ax
	
positiveNumber:
	mov [di], ax
	xor dx, dx
	inc di
	inc di
	xor bp, bp
	jmp beginn
	
exit:	
	ret
endp read_matrix


proc readAColRow
	mov ax, [di]
	mov A, ax
	inc di
	inc di
	
	mov ax, [di]
	mov n, ax
	inc di
	inc di
	
	mov ax, [di]
	mov m, ax
	inc di
	inc di
	
	ret	
endp readAColRow




proc matrixToString
	add si, 6
	push cx
	push si
	xor bp, bp
	cmp ax, 65535
	jg pos

	neg ax
	inc bp
pos:
	xor dx, dx
	mov cx, 10
	div cx
	mov byte ptr [si], '0'
	add [si], dl

	dec si

	cmp ax, 0
	jg pos

	cmp bp, 0
	je ex

	mov byte ptr [si], '-'
	xor bp, bp
ex:
	pop si
	inc si
	pop cx
	ret
endp matrixToString


proc output

	lea di, matrixResult
	mov cx, n
	
outAllMatrix:
	push cx
	mov cx, m
	
	outRow:
	mov ax, [di]
	call matrixToString
	inc di
	inc di
	loop outRow

	mov byte ptr [si], 13
	inc si
	mov byte ptr [si], 10
	inc si
	pop cx
loop outAllMatrix
	ret
endp output


proc fileOutput

	mov ah,3Ch             
	lea dx, out_filename      
	xor cx,cx              
	int 21h             
	mov handle,ax        
 
	mov bx,ax             
	mov ah,40h             
	lea dx, strresult          
	mov cx, 200      
	int 21h              

	mov ah, 3Eh             
	mov bx, handle      
	int 21h                 
	ret
endp fileOutput

proc mulNM
	push ax
	push dx
	xor ax, ax
	mov ax, n
	mov dx, m
	mul dx
	mov n1m1, ax
	pop dx
	pop ax
ret
endp MulNM


start:
mov ax, @DATA      
	mov DS, ax       
	mov es, ax
	
	call read_from_file

	lea si, buf	
	lea di, matrix		
	call read_matrix
	lea di, matrix
	call readAColRow
	call mulNM
	call task

	lea bx, matrixResult
	mov ax, [bx]
	lea si, strresult
		
	call output	
	call fileOutput

final:		
	mov ax, 4c00h
	int 21h
  end start 
