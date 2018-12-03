.model tiny
.code
org 100h ; начало COM-программы
Start: 
jmp installation 

resident proc 
 
cmp al, 1eh           ; 1eh = 'a' 
jne isB               ; переход, когда в al не 1eh
mov al, 02h           ; 02h = '1'
jmp to_ret 

isB: 
cmp al, 30h           ; 30h = 'b' 
jne isC               ; переход, когда в al не 30h
mov al, 03h           ; 03h = '2' 
jmp to_ret 

isC: 
cmp al, 2eh           ; 2eh = 'c'
jne isD               ; переход, когда в al не 2eh
mov al, 04h           ; 04h = '3'
jmp to_ret 

isD: 
cmp al, 20h           ; 20h = 'd' 
jne isE               ; переход, когда в al не 20h
mov al, 05h           ; 05h = '4' 
jmp to_ret 

isE: 
cmp al, 12h           ; 12h = 'e' 
jne to_original_handler ; переход, когда в al не 12h
mov al, 06h           ; 06h = '5' 
jmp to_ret 

to_ret: 
jmp dword ptr cs:handler_vector ; переходит по адресу 
                          ; cs:handler_vector, где хранится 
                          ; оригинальная функция для обработки 
                          ; прерывания, которое выводит символ 
                          ; из регистра al на экран
to_original_handler: 
jmp dword ptr cs:handler_vector 

handler_vector dd ?     ; здесь хранится адрес 
                        ; предыдущего обработчика
resident endp 

installation: 
; скопировать адрес предыдущего обработчика 
; в переменную handler_vector
mov ax, 3515h        ; AH = 35h, AL = номер прерывания
int 21h              ; функция DOS: считать 
                     ; адрес обработчика прерывания
mov word ptr handler_vector, bx     ; возвратить смещение в BX  
mov word ptr handler_vector + 2, es ; и сегментный адрес в ES,
                                   ; установить наш обработчик
mov ax, 2515h        ; AH = 25h, AL = номер прерывания
mov dx, offset resident ; DS:DX - адрес обработчика
int 21h              ; функция DOS : установить обработчик  

mov dx, offset installation ; DX - адрес первого байта за 
                            ; концом резидентной части
int 27h              ; оставить программу резидентной 

end Start
