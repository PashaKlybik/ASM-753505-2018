.model small
.386
.stack 256
.data
	processed_char_index dw 0
	processed_line_len dw 0
	is_word_started db 1

	vowels db "AEIOUYaeiouy"
	vowelslength=$-vowels
	
	spaces db " ,.!?"
	spaceslen=$-spaces
	
	; input string buffer
	max db 200
	input_line_len db ?
	processed_string db 200 dup('$')
		
	inputmessage db "Enter the line:$"
	outputmessage db "Processed line:$"
.code

clearscreen proc
	push ax
	mov ax, 3
	int 10h
	pop ax
	ret
clearscreen endp

new_line proc
	push ax
	push dx
	mov ah, 02h
	mov dl, 0dh
	int 21h
	mov dl, 0ah
	int 21h
	pop dx
	pop ax
	ret
new_line endp

processing proc
	push ax
	push bx
	push si

processing_next_word:
	call skip_spaces
	mov ax, processed_line_len
	mov bx, processed_char_index
	cmp ax, bx
	je processing_end

	call check_proc_char_for_vowels
	cmp ax, 0
	jne processing_delete_word
	
	call skip_word
	jmp processing_next_word
	
processing_delete_word:
	call delete_word
	jmp processing_next_word	

processing_end:
	mov al, 0
	mov si, processed_line_len
	mov processed_string[si], '$'

	
	pop si
	pop bx
	pop ax	
	ret
processing endp

skip_spaces proc
	push cx
	push di
	push si
	
skip_spaces_check_char:
	mov si, processed_char_index
	cmp si, processed_line_len
	jae skip_spaces_end

	mov al, processed_string[si]
	lea di, spaces
	mov cx, spaceslen
	cld
	repne scasb
	jcxz skip_spaces_end
	inc processed_char_index
	jmp skip_spaces_check_char

skip_spaces_end:
	pop si
	pop di
	pop cx
	ret
skip_spaces endp

skip_word proc
	push ax
	push cx
	push di
	push si
	
skip_word_check_char:
	inc processed_char_index
	mov si, processed_char_index
	cmp si, processed_line_len
	jae skip_word_end
	
	mov al, processed_string[si]
	lea di, spaces
	mov cx, spaceslen
	cld
	repne scasb
	jcxz skip_word_check_char

skip_word_end:	
	pop si
	pop di
	pop cx
	pop ax
	ret
skip_word endp

delete_word proc
	push ax
	push bx
	push cx
	push si
	push di

	mov ax, processed_char_index
	push ax
	
	call skip_word

	mov cx, processed_char_index
	pop ax
	sub cx, ax
	
	mov bx, processed_line_len
	push bx
	sub bx, cx
	mov processed_line_len, bx
	pop bx
	push cx
	sub bx, processed_char_index
	mov cx, bx
	
	lea si, processed_string
	add si, processed_char_index
	lea di, processed_string
	add di, ax
	cld
	rep movsb
	pop cx
	mov ax, processed_char_index
	sub ax, cx
	mov processed_char_index, ax
	
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	ret
delete_word endp

check_proc_char_for_vowels proc
; modified ax for return, ax!=0 if vowel
	push cx
	push di
	push si
	
	mov si, processed_char_index
	mov al, processed_string[si]
	lea di, vowels
	mov cx, vowelslength
	cld
	repne scasb
	mov ax, cx
	
	pop si
	pop di
	pop cx
	ret
check_proc_char_for_vowels endp


main:
	mov ax, @data
	mov ds, ax
	call clearscreen
	mov es, ax
	call new_line
	lea dx, inputmessage
	mov ah, 09h
	int 21h
	call new_line
	lea dx, max
	mov ah, 0aH
	int 21h
	xor ax, ax
	mov al, input_line_len
	mov processed_line_len, ax
	call new_line
	
	call processing
	
	lea dx, outputmessage
	mov ah, 09h
	int 21h
	call new_line
	mov dx, offset processed_string
	mov ah,09h
	int 21h
	call new_line
	mov ax, 4c00h
	int 21h
end main