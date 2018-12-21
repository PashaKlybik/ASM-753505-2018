.model tiny
.386
.data

	backSpace=08h
	tab=09h
	cr=0Dh ; возврат каретки
	lf=0ah ; перевод строки
	space=20h
	
.code

org 100h

int21HVector label word

start:
	jmp init
	mov ax, 4c00h
	int 21h
	vowels db 'AEIOUYaeiouy'
	
intOverlap proc far ; перекрытие 10 функции 21 прерывания
	cmp ah, 0Ah
	je if0Ah
	jmp dword ptr cs:[int21HVector] ; переходим на адрес, где хранится int21HVector
if0Ah:
	push es
    push di
    push bx
    push cx
    push si
    push dx
	
	mov bx, dx	; в bx хранится начало буфера
	mov si, 1   ; указатель на строку
    xor ch, ch
    mov cl, [bx]; размер буфера (хранится в первом элементе)
    inc bx      ; bx указывает на первый символ в строке
	jcxz exit	; если размер буфера = 0
	mov ax, 0d00h ; буфер должен заканчиваться 0dH
	mov [bx], ax
    dec cx
    jz exit
    cld
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
	cmp si, 1
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
	mov [bx+si], al
	call output
	
exit:
	pop dx
    pop si
    pop cx
    pop bx
    pop di
    pop es
    iret
intOverlap endp

;---------------------------

saveToBuffer proc  ; сохранить символ в буфер
	inc byte ptr [bx]
	mov [bx+si], al
	mov byte ptr [bx+si+1], cr
    inc si
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
	mov di, offset vowels
	mov cx, 12
	repne scasb
	pop cx
	pop di
	ret
isVowel endp
	
;---------------------------

init proc ; инициализация перекрытия
	mov ax, 3521h
	int 21h
	mov [int21HVector], bx
	mov [int21HVector+2], es

	mov dx, offset intOverlap
	mov ax, 2521h
	int 21h

	mov dx, offset init
	int 27h ;Возвращает управление DOS, оставляя часть памяти распределенной, так что последующие программы не будут перекрывать программный код или данные в этой памяти.
init endp

end start