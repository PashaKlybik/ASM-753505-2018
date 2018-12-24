.model small
.stack 256
.data
 strLine db 255,255 dup('$')      ;строка на ввод
 buffer db 255 dup('$')           ;буффер, а котором будем хранить слово
 result db 255 dup('$')           ;строка-результат
 BoolExit db 0                    ;Переменная проверки: достигнут конец строки
 beginSI dw 0                     ;метка начала продолжения нашей строки
 rezSI dw 0                       ;резервная копия для текущего места в строке
 indexResult dw 0                 ;место нахождения в строке результата
 rezCX dw 0                       ;резервная копия для регистра СХ
 message1 db 'Enter string: $'
 message2 db 'Result string: $'
.code
 ENTER MACRO                      ; макрос для вывода ENTER, т.е. переход на новую строку
   MOV DL, 10
   MOV AH, 02h
   INT 21h
   MOV DL, 13
   MOV AH, 02h
   INT 21h
 ENDM

 out_str MACRO str                ;макрос вывода строки str
   push ax
   mov ah, 09h
   mov dx, offset str
   int 21h
   pop ax
 endm

main:
    mov ax, @data
    mov ds, ax
    mov es, ax
  out_str message1
  ENTER
  MOV AH, 0Ah                     ;настройка 21-го прерывания на 10-ю функцию. Ввод строки
  LEA dx, strLine
  int 21h
  lea si, strLine+1               ;настройка si на введенную строку
  lea di, buffer                  ;настройка di на буффер
  inc si                          ;переход в начало строки strLine, т.е. введенной(первый символ там длина строки)
  mov beginSI, si                 ;вносим место начала входа для считывания слова
  mov ah,0
  mov cx,0
  push ax
  lea ax,result                   
  mov indexResult,ax              ;настраиваем переменную на начало строки-результата
  pop ax
  mov ax,0
  cld                             ;указываем, что цепочка обраббатывается слева направо
 cicle:
    lodsb                         ;str[i]=ah i++
    cmp ax,13                     ;проверка на конец вводимой строки
    jnz next                      ;переход, если не конец
       dec si                     
       dec di                     
       push ax
       mov ah,1
       mov BoolExit,ah            ;помещаем в переменную проверки 1: т.е. достигнут конец строки
       pop ax 
       jmp Space                  ;на метку обработки пробела, т.к. перед концом строки могло быть слово
  next:
    cmp ax, 32                    ;проверка на пробел
    jnz next1
      dec si
      dec di
      jmp Space                   ;переход на обработку пробела
  next1:
    inc cx
    dec si                        ; на символ назад
    cld
    movsb                         ;buffer[di]=str[si] si++ di++
    jmp cicle                     ;повтор прохода по цепочке

 Space:                           ;обработка пробела
    mov ax,0
    mov rezSI, si                 ; делаем резервные копии
    mov rezCX, cx
    mov si, beginSI               ; заносим в si начало слова
    cmp cx,ax                     ; проверка, было ли вообще введено слово или это пробел, cx-колличество символов в слове
    jnz nextSpace                 ; переход, если не пробел просто а слово
      mov si, rezSI               ;возвращаем в SI резервную копию
    inc si                        ;переходим на следующий символ
    mov beginSI, si               ;и делаем его началом нового слова
    push ax
    mov ah,1
    cmp ah,BoolExit               ;проверка на конец строки
    pop ax
    jnz next5                     ;переход, если не конец
       lea dx, result             ;настройка сегмента dx на результат
       jmp exit                   ; выход, если конец строки
  next5:
    mov ax,0
    mov cx,0
    lea di,buffer                 ;возвращаемся в начало буфферу т.к. новое слово нужно вводить
    jmp cicle
  nextSpace:                      ;сравнение на полиндромность по буфферу двигаемя назад а по слову в строке вперед
   cicleSpace:
    mov bl, [si]                  ;сравнение слова на полиндромность посимвольно
    mov al, [di]                  
    cmp bl, al                    
    jz next2
      jmp exitSpace               ;конец проверки, т.к. не полиндром
  next2:
    lodsb                         ;si++
    dec di                        ;di--
  loop cicleSpace                 ;цекл, пока длина строки > 0
 exitSpace:                       ;конец проверки
    push ax
    mov ax,0
    cmp cx, ax                    ;проверка сх на 0, т.е. было ли все слово сравнено
    pop ax
   jz Copy                        ;если полиндром то копируем в строку результат
    mov si, rezSI
    inc si
    mov beginSI, si
    push ax
    mov ah,1
    cmp ah,BoolExit
    pop ax
    jnz next3
       lea dx, result
       jmp exit
  next3:
    mov ax,0
    mov cx,0
    lea di,buffer
    jmp cicle
 
 Copy:                             ;копирование в строку резултат
   push si
   push di
   lea si, buffer                  ;в si начала буффера
   mov cx,rezCX                    ;возврат длины слова
   mov di, indexResult             ; в di место в строке-результате
  cicleCopy:                       ; копируем si++ di++
     movsb                         
  loop cicleCopy                   
   mov [di], ' '                   ; вставляем пробел поле слова
   inc di
   mov indexResult, di             ;запоминаем индекс для нового слова
   pop di
   pop si 
  mov si, rezSI                    ;возвращаем в si вводимую строку
    inc si
    inc di
    mov beginSI, si                ;обновление начала слова
    push ax
    mov ah,1
    cmp ah,BoolExit                ;проверка на конец строки
    pop ax
    jnz next4
       lea dx, result              ; настройка на dx строки-результата
       jmp exit                    ; перемещаемся на выход
  next4:
    mov ax,0
    mov cx,0
    lea di, buffer                 ;возвращаем в di начало буффера
    jmp cicle 

exit:
  ENTER                            ;переход на новую строку после ввода
  out_str message2                 ;вывод сообщения Result string:
  ENTER                            ; переход на новую строку
  out_str result                   ; вывод строки -результата
  ENTER                            ; переход на новую строку
    mov ax, 4c00h
    int 21h
end main
