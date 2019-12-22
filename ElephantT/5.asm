.model small
.stack 100
.486
.data
   ent db 13,10,'$' 
   path db "input.txt",0 ;
   max db "Max value - ", '$'
   min db "Min value - ", '$'
   buf  db ?
   t db 5
   digit db ?
   ten db 10
   tn dw 10
   counter dw 0
   rows   dw 0
   cols   dw 0
   array  db 100*100 dup (?)
   array2 db 100*100 dup (?)
   num db 0
   temp1 dw 0
   temp2 dw 0
   temp3 dw 0
   Filename db 'output.txt',0 
   handler dw ?
   res db 100 dup(?)
   cnt db 0 
.code

putdigit macro ;вывод цифры 
  local lput1
  local lput2
  local exx
 
  push  ax
  push  cx
  push  -1  ;сохраним признак конца числа
  mov   cx,10 ;делить будем на 10
lput1:  xor   dx,dx ;чистим регистр dx
  mov   ah,0                   
  div   cl  ;Делим 
  mov   dl,ah 
  push  dx  ;Сохраним цифру
  cmp al,0  ;Остался 0? 
  jne lput1 ;нет -> продолжим
  mov ah,2h
lput2:  pop dx  ;Восстановим цифру
  cmp dx,-1 ;Дошли до конца -> выход 
  je  exx
  add dl,'0'  ;Преобразуем число в цифру
  int 21h ;Выведем цифру на экран
  jmp lput2 ;И продолжим
exx:
  mov dl,' ' 
  int 21h
  pop cx
  pop   ax
endm

putdigitinstr macro ;перевод числа в строку
  local lput12
  local lput22
  local exx2
 
  push  ax
  push  cx
  push  -1  ;сохраним признак конца числа
  mov   cx,10 ;делить будем на 10
lput12:  xor   dx,dx ;чистим регистр dx
  mov   ah,0                   
  div   cl  ;Делим 
  mov   dl,ah 
  push  dx  ;Сохраним цифру
  cmp al,0  ;Остался 0? 
  jne lput12 ;нет -> продолжим
  mov ah,2h
lput22:  pop dx  ;Восстановим цифру
  cmp dx,-1 ;Дошли до конца -> выход 
  je  exx2
  add dl,'0'  ;Преобразуем число в цифру
  mov word ptr[di], dx
  inc di
  jmp lput22 ;И продолжим
exx2:
  mov dl,' ' 
  mov word ptr[di], dx
  inc di
  pop cx
  pop   ax
endm

NewLine PROC ;переход на новую строку

  push  ax
  push  dx
  xor ax, ax
  xor dx, dx

  lea   dx,ent  
  mov   ah,09h  
  int   21h
 
  pop   dx
  pop   ax

  ret
NewLine ENDP

ReadFile PROC  ;чтение из файла
    mov ax,3d00h    ;открытие существующего файла
    lea dx,path     
    int 21h     
    jc exit     ;если ошибка, то выйти
    
    mov bx,ax   ;записываем в bx дескриптор файла    
    xor cx,cx
    xor dx,dx
    mov ax,4200h ;установка указателя на последний байт файла
    int 21h    
   out_str: 
    mov ah,3fh      ;чтение символа из файла
    mov cx,1        ;количество байтов для чтения
    lea dx,buf    ;указатель на буфер для записи
    int 21h         
    cmp ax,cx       ;проверка на оставшиеся байты
    jnz close      ;если их нет, то закончить ввод
    mov dl,buf
    mov ah,2      ;вывод считанного символа в консоль
    int 21h    

    cmp dl, 48  ;считали ли мы цифру
    jl pass ;если нет, то обрабатываем уже прочитанное число
    cmp dl, 57
    jg pass


        xor ax, ax
        mov al, num ; здесь мы в переменную num записываем цифры, чтобы составить считанное число
        mul ten
        add al, dl ; чтобы добавить к числу цифру, умножаем его на 10 и прибавляем эту цифру
        sub al, 48
        mov num, al
        jmp null
    pass:  
        xor ax, ax
        mov al, num ;запоминаем считанное число
        cmp ax, 0
        mov num, 0 ;обнуляем переменную для чисел
        je null ; если мы вдруг ничего не считали, то переходим в null
        push ax ;помещаем в стек считанное число
        mov ax, rows ;проверяем считали ли мы уже количество рядов в массиве
        cmp ax, 0
        je g1 ;если ещё нет, то идём читать
        jne g2 ;если да, то проверяем считали ли мы число столбцов
        g1: 
          pop ax
          mov rows, ax ;запонимаем число рядов
          jmp null
        g2:
          mov ax, cols
          cmp ax, 0  ;проверяем считали ли мы уже количество столбцов в массиве
          je g3
          jne null
          g3:
            pop ax
            mov cols, ax ;запонимаем число столбцов
            jmp null   
        null:; идём читать дальше
    jmp out_str
   close:           
    mov ah,3eh ;закрываем файл
    int 21h
   exit:  
   

    mov al, num ;помещаем последнее считанное число в стек, т.к. мы его не поместили в цикле выше
    push ax
 

    lea   bx,array    ;проходим по массиву
                  mov   cx,rows
                in1: 
                  mov dx, cx
                  mov   cx,cols
                  mov   si,0
                in2:  
                  pop ax  ;и записываем в него считанные из файла и лежащие в стеке числа
                  mov   [bx][si],al
                  inc   si
              
                  loop  in2
             
                  add   bx,cols
                  mov cx, dx
                  loop  in1


  ret
ReadFile ENDP

Shift PROC ;сдвиг
    mov ax, rows

    lea  bx,array ;проходим по массиву
    xor cx, cx
  mov   cl, al
t1: ;внешний цикл
    push  cx
    xor cx, cx
    xor ax, ax
    mov ax, cols
    mov cl, al
    mov si, 0


  
  
t2: ;внутренний
  xor   ax, ax
  xor dx, dx



  mov al, [bx][si]
  mov temp1, ax ; //запоминаем текущий элемент(i, j)


  xor ax, ax
  mov ax, si ;берём элемент ответающий за позицию в ряде
  add ax, counter ;прибавляем к нему сдвиг в текущем ряду(i,j+k)
  cmp ax, cols ;если сдвиг вышел за пределы массива,  то берём по модулю
  jl inside
  sub ax, cols

 inside: 
  mov temp3, ax ; //запоминаем положение в строке(j+k)
  



  xor dx, dx
  push si ;запоминаем текущее положение в обходе массива
  push bx
  mov si, temp3 ; переходим в позицию, где должен оказаться очередной элемент



  xor dx, dx
  xor ax, ax
  mov ax, temp1 ;записываем элемент, который мы сдвигали

  lea  dx, array ;вернулись к старой позиции 
  sub bx, dx ;отняли смещение, по которому находится начало массива
  lea dx, array2 ;указали на 2ой массив, куда мы записываем результат
  add dx, bx
  mov bx, dx
  mov [bx][si], al ; записали во 2ой массив сдвинутый элемент


  pop bx ;снова вернули место в 1ом массиве, где мы совершаем обход
  pop si



  add si, 1 ;перешли к следующему элементу в 1ом массиве



  loop  t2new  
  cmp cx, 0
  je next1
  t2new: jmp  t2 ;дополнительные переходы, т.к. расстояние между началом и концом цикла слишком велико
  next1:
  inc counter ;с каждым рядом сдвиг растёт на 1
  add  bx, cols; перехлд на новую строку в массиве
  pop   cx
  loop  t1new
  cmp cx, 0
  je next2
  t1new: jmp  t1
  next2:
  ret
Shift ENDP

Reverse Proc 
xor dx,dx
  lea   bx,array  ;обходим массив, записывая в стек все его элементы
  mov   cx,rows
out1: ;цикл по строкам
  mov dx, cx
  mov   cx,cols
  mov   si,0
out2: ;цикл по колонкам
  xor   ax,ax

  mov al,[bx][si]  
  push ax
  inc   si
  loop  out2
 
  add   bx,cols
  mov cx, dx
  loop  out1

  call NewLine


    xor dx,dx
  lea   bx,array ;обходим массив, доставая из стека все его элементы
  mov   cx,rows
out12: ;цикл по строкам
  mov dx, cx
  mov   cx,cols
  mov   si,0
  call NewLine
out22: ;цикл по колонкам
  xor   ax,ax

  pop ax
  mov [bx][si], al
  inc   si
  loop  out22
 
  add   bx,cols
  mov cx, dx
  loop  out12
ret
Reverse endp


output Proc
xor dx,dx
  lea   bx,array2 ; указываем на начало  массива с результатом и обходим его
  mov   cx,rows
out13: ;цикл по строкам
  mov dx, cx
  mov   cx,cols
  mov   si,0
  call NewLine
out23: ;цикл по колонкам
  xor   ax,ax
  mov al, [bx][si]
  pusha
  putdigit ;вывод в консоль
  popa
  inc   si
  loop  out23
 
  add   bx,cols
  mov cx, dx
  loop  out13
ret
output Endp

entry PROC

  lea di, res
  lea   bx,array2 ; указываем на начало массива с результатом и обходим его
  mov   cx,rows
out14: ;цикл по строкам
  push cx
  mov   cx,cols
  mov   si,0
  call NewLine
out24: ;цикл по колонкам
  xor   ax,ax
  mov ax, [bx][si]

  putdigitinstr ;конвертируем его элементы в строку

  inc   si
  loop  out24
  
  mov word ptr[di], 13 ;разделяя строки
  inc di
  mov word ptr[di], 10
  inc di

  add   bx,cols
  pop cx
  loop  out14

  xor ax, ax
  xor dx, dx
  xor cx, cx
  xor bx, bx

    mov ah, 3Ch     ;создаём или открываем файл для записи
    lea dx, Filename
    xor cx, cx
    int 21h       
    
    mov handler, ax
    mov bx,handler               
    mov ah,40h    ;записать в файл         
    mov cl, cnt
    lea dx, res 
    sub di, dx ;записываем длину строки
    add cx, di
    lea dx, res ;указываем на строку
    int 21h   
 
    mov ah, 3eh ;закрываем файл
    mov  bx, handler
    int 21h     
ret
entry ENDP

start:
    mov ax, @data
    mov ds, ax
    

    call ReadFile ;читаем из файла матрицу

    call Reverse  ;мы прочитали её справа налево, поэтому здесь перевернём

    call Shift ;выполняем сдвиг

    call Output ;выводим в консоль

    call Entry ;записываем в файл

    mov ah, 4ch
    int 21h
end start