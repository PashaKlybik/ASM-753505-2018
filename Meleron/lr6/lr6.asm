.model tiny
.386
.data
    ;Константы
    enterSymbol=0Dh ;Возврат каретки
    backspaceChar=8 ;Код backspaceChar'а
    space=20h ;Пробел
    
.code

org 100h

interruptVector label word

main:
    jmp initialize
    mov ax, 4c00h
    int 21h
    vowelsList  db 'AEIOUYaeiouy'
    
intIntercept proc far
    cmp ah, 0Ah
    je  handleFunc
    jmp dword ptr cs:[interruptVector] ;Перепрыгивает на адрес, равный cs+адрес, на который указывает interruptVector
handleFunc:
    push es
    push bx
    push cx
    push di
    push dx
    
    xor cx, cx
    mov bx, dx      ;bx - адрес на начала буфера (буфер:[длина],[эл-т 1], [эл-т 2], ..., [эл-т n])
    mov di, 1       ;Указатель на строке
    mov cl, [bx]    ;Размер буфера (его первый элемент)
    inc bx          ;bx - адрес первого символа в строке
    cmp cx, 0
    je handleStop   ;Если длина буфера = 0
    mov ax, 0d00h   ;Буфер должен заканчиваться 0dh
    mov [bx], ax
    dec cx
    jz handleStop
    push cs
    pop es          ;Помещаем в регистр es регистр cs, т.к. для строковых операций необходимо исользовать регистр es (для repne)
    
srtingInput:
    call charInput
    cmp al, enterSymbol
    je endOfInput   ;Если нажат enter, то закончить ввод
    cmp al, backspaceChar
    je backSpace
    call buffering  ;Иначе записывает в буфер
    call printChar
    call isVowel
    jnz srtingInput ;Если repne установил гласную букву, то флаг jz будет равен 0 (repne работает по принципу вычитания)
    call buffering
    jc srtingInput
    call printChar
    jmp srtingInput
    
backSpace:          ;Если пользователь ввёл backspace
    cmp di, 1
    je srtingInput
    mov [bx+si], byte ptr enterSymbol
    dec di
    dec byte ptr [bx]
    call printChar
    mov al, space
    call printChar
    mov al, backspaceChar
    call printChar
    jmp srtingInput
    
endOfInput:
    mov [bx+di], al
    call printChar
    
handleStop:
    pop dx
    pop di
    pop di
    pop bx
    pop es
    iret            ;Достает регистр ip, сегментный регистр cs и регистр флагов из стека, таким образом происходит переход управления на адрес, который поместила в стек команда int...
intIntercept endp

buffering proc
    inc byte ptr [bx]
    mov [bx+di], al
    mov byte ptr [bx+di+1], enterSymbol
    inc di
    ret
buffering endp

printChar proc
    push ax
    push dx
    mov dl, al
    mov ah, 2
    int 21h
    pop dx
    pop ax
    ret
printChar endp

charInput proc      ;Ввод символа без вывода его на экран
    mov ah, 8
    int 21h         ;al - введённый символ
    ret
charInput endp

isVowel proc
    push cx
    push di
    mov di, offset vowelsList
    mov cx, 12
    repne scasb     ;Сравнивает содержимое al с содержимым по адресу es:di
    pop di
    pop cx
    ret
isVowel endp

printString proc
    push ax
    mov ah, 09h
    xchg dx, di
    int 21h
    xchg dx, di
    pop ax
    ret
printString endp

initialize proc
    mov ax, 3521h
    int 21h
    mov [interruptVector], bx
    mov [interruptVector+2], es
    mov dx, offset intIntercept
    mov ax, 2521h
    int 21h
    mov dx, offset initialize
    int 27h         ;Возвращает управление DOS, оставляя часть памяти распределенной, так что последующие программы не будут перекрывать программный код или данные в этой памяти. (Завершиться, но остаться резидентным)       
initialize endp

end main