.model tiny
.code
.486                                    
org 100h    ;начало COM-программы
start:
    jmp initialization       
                      
newKeyboardHandle proc         ;новый обработчик прерывания клавиатуры
    pushf
    push es
    mov ax, 40h            ;для работы с буфером клавиатуры
    mov es, ax 
    xor ax, ax 
    IN  al, 60h            ;получаем скан-код клавиши
    cmp al, 1eh            ;Сравниваем код с кодом буквы a
    jne b                  ; переход, когда в al не 1eh
    mov al, 49             ; = '1'
    jmp newHandler
b:
    cmp al, 30h            ;Сравниваем код с кодом буквы b
    jne c                  ; переход, когда в al не 30h
    mov al, 50             ; = '2'
    jmp newHandler
c:
    cmp al, 2eh            ;Сравниваем код с кодом буквы c
    jne d                  ; переход, когда в al не 2eh
    mov al, 51             ; = '3'
    jmp newHandler
d:
    cmp al, 20h            ;Сравниваем код с кодом буквы d
    jne e                  ; переход, когда в al не 20h
    mov al, 52             ; = '4'
    jmp newHandler
e:
    cmp al, 12h            ;Сравниваем код с кодом буквы e
    jne old                ; переход, когда в al не 12h
    mov al, 53             ; = '5'
	
newHandler: 
    mov bx, 1ah        
    mov cx, es:[bx]        ;голова буфера 
    mov di, es:[bx]+2      ;хвост буфера
    cmp cx, 60             ;голова на вершине?
    je check      
    inc cx                 ;увеличиваем указатель головы на 2
    inc cx            
    cmp cx, di             ;сравниваем с указателем хвоста
    je exit                ;если равны, то буфер полон
    jmp insert             ;иначе вставляем символ
check:
    cmp di,30        
    je exit                ;если буфер полон, то выход
insert:
    mov es:[di], al        ;помещаем символ в хвост
    cmp di, 60         
    jne tail             ;если хвост не в конце буфера, то добавляем 2
    mov di, 28             ;иначе указатель хвоста = 28+2
tail:
    add di, 2            
    mov es:[bx]+2, di      ;посылаем его в область данных
    jmp exit
old: 
    pop es
    popf                      
    jmp dword ptr cs:standartHandler  ;вызов стандартного обработчика прерывания 
                                 ;переходит по адресу 
                                 ; cs:standartHandler, где хранится 
                                 ; оригинальная функция для обработки 
                                 ; прерывания, которое выводит символ 
                                 ; из регистра al на экран        

    iret
exit:
    xor ax, ax
    mov al, 20h
    out 20h, al 
    pop es
    popf 
    iret
newKeyboardHandle endp

    standartHandler dd ?
	
initialization proc
    ;копируем адрес предыдущего обработчика в standartHandler
    mov ax, 3509h               ; ah = 35h, al = номер прерывания         
    int 21h                     ; функция DOS: считать
                                ; адрес обработчика прерывания
    mov word ptr standartHandler, bx         ;возвратить смещение в bx
    mov word ptr standartHandler + 2, es     ;и сегментный адрес в es
    ;устанавливаем новый обработчик
    mov ax, 2509h                            ;ah = 25h, al = номер прерывания
    mov dx, offset newKeyboardHandle         ;ds:dx - адрес обработчика
    int 21h                                  ;функция DOS : установить обработчик
    ;делаем программу резидентной      
    mov dx, offset initialization
    int 27h 
initialization endp

end start 