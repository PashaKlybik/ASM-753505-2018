.model small
.stack 256
.data
	bufferSize  db  100
	inputSize   db  0
	inputString db  100 dup('$'),'$'
	newLine		db  0dh,0ah,'$'

	; max occurence
	maxWordIndex  dw  0
	maxWordLenth  dw  0
	maxOccur      dw  0

	; current word
	curWordIndex  dw  0
	curWordLenth  dw  0
	curOccur	  dw  0

	; rest string
	restWordIndex dw  0
	restWordLenth dw  0

	; output number
	numPromptMessage   db  'count: '
	outNum			   db  5 dup('$'),'$'
	wordPromptMessage  db  'word: '
	maxWord            db  100 dup('$'),'$'
	noWordsMessage     db  'no words found','$'

	wordFound dw 0

.code
	ReadString proc
		push ax
		mov ah,0ah
		lea dx,bufferSize
		int 21h 
		pop ax
		ret
	ReadString endp

	SetSearchRegisters proc
		lea di, inputString
		add di, restWordIndex
		mov cl, inputSize
		xor ch, ch
		sub cx, restWordIndex
		ret
	SetSearchRegisters endp

	FindWordBegin proc
		cld
		call SetSearchRegisters
    
		mov wordFound, word ptr 0
    
		add di, restWordLenth
		sub cx, restWordLenth
		mov al, 20h
		xor ah, ah
		repz scasb
		jz exitwordbegin
		mov wordFound, word ptr 1
      
		mov ax, di
		dec ax
		lea di, inputString
		sub ax, di
		mov restWordIndex, ax
		
		exitwordbegin:
		ret
	FindWordBegin endp 

	FindWordLenth proc
		cld
		call SetSearchRegisters
		push di
		mov al, 20h
		xor ah, ah
		repnz scasb
		mov ax, di
		jnz endstring
		dec ax
		
		endstring:
		pop di
		sub ax, di
		mov restWordLenth, ax
		ret
	FindWordLenth endp 

	FindNextWord proc
		mov ax, curWordIndex
		mov restWordIndex, ax
    
		mov ax, curWordLenth
		mov restWordLenth, ax

		call FindWordBegin

		mov ax, wordfound
		or ax, ax
		jz exitnext
    
		call FindWordLenth
    
		mov ax, restWordIndex
		mov curWordIndex, ax
    
		mov ax, restWordLenth
		mov curWordLenth, ax
		
		exitnext:
		ret
	FindNextWord endp

	PrintOccur proc
		lea dx, newline
		mov ah,09h
		int 21h
		mov ah,09h
		int 21h

		mov ax, maxoccur
		or ax, ax
		jnz foundmax
		lea dx, noWordsMessage
		mov ah,09h
		int 21h
		jmp exitprint
		
		foundmax:      
		lea di, outnum
		xor cx,cx 
		mov bx,10 
	
		digits:       
		xor dx,dx 
		div bx    
		add dl,'0'
		push dx   
		inc cx    
		test ax,ax
		jnz digits
	
		fillstr:      
		pop dx     
		mov [di],dl
		inc di     
		loop fillstr
		 
		lea dx, wordPromptMessage
		mov ah,09h
		int 21h
		lea dx, newline
		mov ah,09h
		int 21h
		
		lea dx, numPromptMessage
		mov ah,09h
		int 21h
		
		exitprint:        
		ret
	PrintOccur endp

	Init proc
		mov al, '$'
		xor ah, ah

	    lea di, outnum
		mov cx, 5
		repne stosb
    
		lea di, inputString
		mov cx, 100
		repne stosb

	    ret
	Init endp

	CountOccur proc
		mov ax, curWordIndex
		mov restWordIndex, ax
    
		mov ax, curWordLenth
		mov restWordLenth, ax

		mov curoccur, word ptr 1
		
		nextcount:
		call FindWordBegin
		mov ax, wordfound
		or ax, ax
		jz exitoccur
		call FindWordLenth
    
		; compare words
		mov cx, restWordLenth
		cmp cx, curWordLenth
		jne continuenextword
		lea si, inputString
		add si, curWordIndex
		lea di, inputString
		add di, restWordIndex
		repe cmpsb
		jnz continuenextword
		inc curOccur

		continuenextword:    
		mov ax, restWordIndex
		add ax, restWordLenth
		xor dh, dh
		mov dl, inputSize
		sub dx, ax
		jnz nextcount
    
	exitoccur:    
		ret
	CountOccur endp

	CompareMax proc
		mov ax, curOccur
		cmp maxoccur, ax
		jge exitcompare
		mov maxOccur, ax

		mov al, '$'
		xor ah, ah
		lea di, maxWord
		mov cx, 100
		rep stosb
    
		mov cx, curWordLenth
		lea si, inputString
		add si, curWordIndex
		lea di, maxWord
		rep movsb
    
		exitcompare:
		ret
	CompareMax endp

        assume  ds:@data,es:@data
	main:
        mov     ax, @data
        mov     ds, ax
        mov     es, ax
        call Init 
        call ReadString
		
		iter:
        call FindNextWord
        mov ax, wordFound
        or ax, ax
        jz exit
        
        call CountOccur
        call CompareMax
        jmp iter

		exit:
        call PrintOccur
        mov ah, 01h
		int 21h
		mov ax, 4c00h
		int 21h
	end main
