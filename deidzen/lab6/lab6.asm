.model tiny
.data
	strError db 'ERROR', 13, 10, '$'
	alreadyInstalled db 'is already installed', 13, 10, '$'
	installed db 'installed', 13, 10, '$'
	notInstalled db 'is not installed yet', 13, 10, '$'
	deleted db 'deleted', 13, 10, '$'
	
	backSpace=08h
	tab=09h
	cr=0Dh ; возврат каретки
	lf=0ah ; перевод строки
	space=20h
.code
org 80h 			; по смещению 80h от начала PSP находятся:
	cmdLength db ?	; длина командной строки
	cmdLine db ?	; и сама командная строка
org 100h

START:
	jmp init
	mov ax, 4c00h
	int 21h
	
	int21HVector dd ? ; вектор прерывания
	installFlag dw 1
	vowels db 'AEIOUYaeiouy'
	
	
int21HProc proc
	cmp ah, 0Ah
	je if0Ah
	jmp dword ptr cs:[int21HVector]
if0Ah:
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	push ds
	push es
	
	mov bx, dx	; в bx хранится начало буфера
	mov di, 1   ; указатель на строку
    xor ch, ch
    mov cl, [bx]; размер буфера (хранится в первом элементе)
    inc bx      ; bx указывает на первый символ в строке
	jcxz exitHandler	; если размер буфера = 0
	mov ax, 0d00h ; буфер должен заканчиваться 0dH
	mov [bx], ax
    dec cx
    jz exitHandler
    push cs
    pop es ; в es хранится cs (для repne нужно использовать регистр es)

stringInput: ; посимвольная обработка символов в процессе ввода
	call charInput
	cmp al, cr ; если конец строки
	je endOfInput ; заканчиваем ввод
	cmp al, backSpace
    je ifBackSpace
	call saveToBuffer ; иначе сохраняем символ в буфер
	call output
	call isVowel ; вернёт ZF=1, если буква гласная, или ZF=0, если согласная
	jnz stringInput
	call saveToBuffer ; если гласная, то дублируем
	jb stringInput
	call output
	jmp stringInput

ifBackSpace: ; обработка backspace
	cmp di, 1
	je stringInput
	mov [bx+si], byte ptr cr
	dec si
	dec byte ptr [bx]
	call output
	mov al, space
	call output
	mov al, backSpace
	call output
	jmp stringInput

endOfInput:
	mov [bx+di], al
	call output
	
exitHandler:
	pop es
	pop ds
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	iret
int21HProc endp

saveToBuffer proc  ; сохранить символ в буфер
	inc byte ptr [bx]
	mov [bx+di], al
	mov byte ptr [bx+di+1], cr
    inc di
    ret
saveToBuffer endp

;---------------------------

output proc ; вывод символа
	push ax
    push dx
    mov dl, al
    mov ah, 2
    int 21h
    pop dx
    pop ax
    ret
output endp

;---------------------------

charInput proc ; ввод символа без эха
	mov ah, 8
	int 21h
	ret
charInput endp

;---------------------------

isVowel proc ; вернёт ZF=1, если буква гласная, или ZF=0, если согласная
	push di
	push cx
	lea di, vowels
	mov cx, 12
	repne scasb
	pop cx
	pop di
	ret
isVowel endp
	
;---------------------------

init:
	mov ax, 3521h ; даёт вектор прерывания
	int 21h
	mov word ptr int21HVector, bx
	mov word ptr int21HVector+2, es
	
	cmp cmdLength, 0
	je install
	cmp cmdLength, 3
	jne argsError
	
	cmp cmdLine[0], ' '
	jne argsError
	cmp cmdLine[1], '-'
	jne argsError
	cmp cmdLine[2], 'd'
	jne argsError
	jmp delete
	
argsError:
	mov ah, 9
	lea dx, strError
	int 21h
	mov ax, 4c00h
	int 21h
	
install:
	cmp es:installFlag, 1
	je already
	
	mov ah, 9
	lea dx, installed
	int 21h
	mov ax, 2521h ; устанавливает вектор прерывания
	lea dx, int21HProc
	int 21h
	jmp exit
	
already:
	mov ah, 9
	lea dx, alreadyInstalled
	int 21h
	mov ax, 4c00h
	int 21h
	
delete:
	cmp es:installFlag, 1
	jne notInstall
	
	mov ah, 9
	lea dx, deleted
	int 21h
	mov ax, 2521h
	mov ds, word ptr es:int21HVector+2
	mov dx, word ptr es:int21HVector
	int 21h
	
	mov ax, 4c00h
	int 21h
	
notInstall:
	mov ah, 9
	lea dx, notInstalled
	int 21h
	
	mov ax, 4c00h
	int 21h
	
exit:
	lea dx, init
	int 27h
end start