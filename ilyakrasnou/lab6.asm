.model tiny
.code
.186                           
org    2Ch
envseg  dw    ?                 ; сегментный адрес окружения DOS
org    80h
cmdLen  db    ?                     
cmdLine db    ?              

org 100h                           ; начало COM-программы

start:

jmp init                           ; переход на инициализирующую часть

int21hHandler proc far

jmp short actualInt21hHandler         ; ISP: пропустить блок,

oldInt21h  dd ?                    ; ISP: старый обработчик
           dw 424Bh                ; ISP: сигнатура
           db 00h                  ; ISP: вторичный обработчик
jmp short reset21h                 ; ISP: ближний jmp на reset21h
           db 7 dup (0)            ; ISP: зарезервировано

actualInt21hHandler:               ; начало обработчика INT 21h
    cmp ah, 09h                    ; перекрываем функцию 09h
    je newHandler
oldHandler:
    pushf
    call dword ptr cs:[oldInt21h]
    iret
newHandler:
    pushf
    push dx
    push cx
    push si
    push di
    push bx
    
    cli                            ; запрещаем аппаратные прерывания, чтобы никто не додумался с помощью них обрабатывать паралельно с нами строку
    mov si, dx
searchVowels:
    mov cl, byte ptr [si]
    cmp cl, '$'
    je restString
    lea di, vowels
    cmpWithVowel:
        cmp byte ptr [di], '$'         ; сравниваем с гласными
        je nextChar
        cmp cl, byte ptr [di]
        je isVowel
        inc di
        jmp short cmpWithVowel
nextChar:
    inc si
    jmp short searchVowels
restString:
    pushf
    call dword ptr cs:oldInt21h
    sti
    pop bx
    pop di
    pop si
    pop cx
    pop dx
    popf
    iret
isVowel:                                ; выводим подстроку без гласной
    mov bl, cl
    mov byte ptr [si], '$'
    pushf
    call dword ptr cs:oldInt21h
    mov dx, si                          ; устанавливаем начало следующей подстроки на следующий символ после гласной
    inc dx
    mov byte ptr [si], bl
    jmp short nextChar

vowels db "aeiouyAEIOUY$"

int21hHandler endp

reset21h: retf                       ; дальний возврат из процедуры
reset2Dh: retf

int2DhHandler proc far               ; 2Dh 
        
    jmp short actualInt2DhHandler       ; пропустить ISP

oldInt2Dh  dd ?
           dw 424Bh
           db 00h
jmp short reset2Dh
           db 7 dup (0)

actualInt2DhHandler:                      ; начало обработчика        
        db 80h, 0FCh                      ; начало команды CMP AH, число
  muxID db ?                              ; идентификатор программы,
        je correctID                      ; если вызываеться с другим ID - переходим к старому обработчику
        jmp dword ptr cs:oldInt2Dh

correctID:    
    cmp al, 03                           
    jae noSupportFor2DhFunc    
    cbw                                  
    mov di, ax                             ; DI = номер функции
    shl di, 1                              ;  * 2, так как choose_func - таблица слов
    jmp word ptr cs:choose_func[di]       
                                        
choose_func dw offset it00FuncOf2Dh, offset noSupportFor2DhFunc  
            dw offset it02FuncOf2Dh
        
it00FuncOf2Dh:                                ; проверка наличия(функция 00h)    
    mov al, 0FFh                     
    mov cx, 0100h                          ; номер версии программы 1.0
    push cs
    pop dx                                 ; DX:DI - адрес AMIS-сигнатуры
    mov di, offset amisSign
    iret

noSupportFor2DhFunc:                 
    mov    al, 00h                         
    iret

unloadFailed:                           
    mov al, 01h                            ; выгрузка программы не удалась
    iret

it02FuncOf2Dh:                                ; выгрузка программы из памяти(функция 02h)    
    cli                                       ; запрет прерываний 
    push 0
    pop ds                              
    mov ax, cs                          

    cmp ax, word ptr ds:[21h*4+2]
    jne unloadFailed    
    cmp ax, word ptr ds:[2Dh*4+2]
    jne unloadFailed

    push bx                          
    push dx
                                    
    mov ax, 2521h
    lds dx, dword ptr cs:oldInt21h
    int 21h
    
    mov ax, 252Dh
    lds dx, dword ptr cs:oldInt2Dh
    int 21h
                                        ; выгрузка резидента из памяти 
    mov ah,51h                          ; Функция DOS 51h (получить сегментный адрес PSP )
    int 21h                               
                                      
    mov word ptr cs:[16h],bx           ; поместить его в поле
                                       ; "сегментный адрес предка" в нашем PSP
    pop dx                             ; восстановить адрес возврата из стека
    pop bx
    mov word ptr cs:[0Ch],dx         ; и поместить его в поле
    mov word ptr cs:[0Ah],bx         ; "адрес перехода при 
                                     ; завершении программы" в нашем PSP
    push cs
    pop bx                           
    mov ah,50h                        
    int 21h                             ; установить текущий PSP
                                    
    mov ax,4CFFh                    
    int 21h                             ; завершить программу

    sti 
    iret
int2DhHandler endp
                                      ; AMIS: сигнатура для резидентных программ
amisSign  db "Krasnov "                 
          db "NoVowels"                
          db "Print string without vowels",0 
                                    
; конец резидентной части
; начало процедуры инициализации

init proc near
        
jmp short initStartPoint         

exitWithMSG:    
    mov ah, 9                      
    int 21h
    ret                                

alreadyLoaded:                         ; если программа уже загружена в память    
    cmp byte ptr unloading, 1        
    je startUnloading
    mov dx,offset msgAlreadyLoaded
    jmp short exitWithMSG

noMoreMux:                              ; если свободный идентификатор INT 2Dh не найден    
    mov dx, offset msgNoMoreMux
    jmp short exitWithMSG

cantUnload:                              ;  если нельзя выгрузить программу    
    mov dx, offset msgCantUnload
    jmp short exitWithMSG

startUnloading:                                                         
    inc ah
    mov al, 02h                           ; AMIS-функция выгрузки резидента
    mov dx, cs                       
    mov bx, offset unloadingSuccess     
    int 2Dh                               ; вызов нашего резидента через мультиплексор

    push cs                             ; если управление пришло сюда - выгрузка не произошла
    pop ds
    mov dx, offset msgCantUnload2
    jmp short exitWithMSG

unloadingSuccess:                    ; если управление пришло сюда - выгрузка произошла
    push cs
    pop ds
    mov dx, offset msgUnloaded
    push 0                          ; чтобы сработала команда RET для выхода
    jmp short exitWithMSG

initStartPoint:                        
    cld

    cmp byte ptr cmdLen, 0
    je notToUnload
    cmp byte ptr cmdLen, 3
    ja incorrectParams
    cmp byte ptr cmdLine[1],'-'
    jne incorrectParams
    cmp byte ptr cmdLine[2],'d' 
    jne incorrectParams
    mov byte ptr unloading, 1      

notToUnload:
    mov ah, -1                          
findCorrectMux:                     ; Проверка доступных идентификаторов     
    mov al, 00h                          
    int 2Dh                          
    cmp al, 00h                      
    jne notFree
    mov byte ptr muxID, ah            
    jmp short freeMuxIsFound
    
incorrectParams:
    mov dx, offset msgIncorrParams
    jmp exitWithMSG

notFree:                                 
    mov es, dx                          ; ES:DI = адрес AMIS-сигнатуры 
                                        ; вызвавшей программы
    mov si, offset amisSign             ; DS:SI = адрес нашей сигнатуры
    mov cx, 16                          
    repe cmpsb
    jcxz alreadyLoaded          
nextMux:
    dec ah 
    jnz findCorrectMux                 

freeMuxIsFound:    
    cmp byte ptr unloading, 1       ; если программа вызвана для выгрузки из памяти 
    je cantUnload              
    cmp byte ptr muxID, 0         
    je noMoreMux                      
    mov ax, 352Dh                     
    int 21h                              ; получить адрес обработчика INT 2Dh
    mov word ptr oldInt2Dh, bx           ; и поместить его в oldInt2Dh
    mov word ptr oldInt2Dh+2, es
    mov ax,3521h                    
    int 21h                            
    mov word ptr oldInt21h, bx        
    mov word ptr oldInt21h+2, es

    mov ax, 252Dh                  
    mov dx, offset int2DhHandler    ; DS:DX - адрес  обработчика(вектор прерывания)
    int 21h            
    mov ax, 2521h                    
    mov dx, offset int21hHandler    ; DS:DX - адрес нашего обработчика
    int 21h            
    
    mov ah, 49h                        ; Освобождение блока памяти
    mov es, word ptr envseg    
    int 21h                            ; освободить память

    mov ah,9
    mov dx,offset msgInstalled      
    int 21h            

    mov dx, offset init                ; DX - адрес первого байта за концом резидентной части
                        
    int 27h                            ; завершить выполнение, оставшись резидентом

msgAlreadyLoaded db    "ERROR: Already loaded",0Dh,0Ah,'$'
msgNoMoreMux     db    "ERROR: Too many TSR programs loaded",0Dh,0Ah,'$'
msgInstalled     db    "Handler was installed successfully",0Dh,0Ah,'$'
msgUnloaded      db    "Handler was unloaded successfully",0Dh,0Ah,'$'
msgCantUnload    db    "ERROR: Can't unload: program not found in memory",0Dh,0Ah,'$'
msgCantUnload2   db    "ERROR: Can't unload: another TSR hooked interrupts",0Dh,0Ah,'$' ; TSR - "Terminate and Stay Resident" 
msgIncorrParams  db    "ERROR: Incorrect parameters of command line",0Dh,0Ah,'$'
unloading        db    0    

init endp
     end start
