.model small
.386
.stack 512
.data
  i dw 0
  b dw 0
  a db 0
  c dw 0
  rez dw 0
  input db 'input.txt',0
  output db 'output.txt',0 
  error_message db 'Error$' 
  handle_input dw 1
  handle_output dw 1
  buffer db 300 dup('$')
  result db 255 dup('$')
  row dw 0
  colum dw 0
  matrix dw 300 dup(0)
  sig dw 0
  date dw 0
  index dw 0
  indexRow dw 0
  indexColum dw 0
  ThisColum dw 0
  BufferArrayElem dw 0
  Enterindex dw 0
  CXforResult dw 0
  sizeResult dw 0
.code

 InResult proc                         ; занесение массива в строку результат
  pusha
  xor dx,dx
  lea di, result
  mov ax,0
  mov cx, index
  mov index,0
  dec cx
  mov ax, cx
  mov bx,2
  div bx
  inc ax
  mov cx,ax
  mov CXforResult, cx
 cicleResult:
  mov bx,index
  mov ax, matrix[bx]
  mov b,ax
  add bx,2
  mov index,bx
  mov bx, EnterIndex
  inc bx
  mov EnterIndex, bx
  MOV DX,0
  MOV BX,0
  MOV CX,0
  SHL AX,1
  JNC Wnext1
  MOV DL, 45
  MOV al, dl
  stosb
  mov dx,sizeResult
  inc dx
  mov sizeResult,dx
  MOV DX, 0
  MOV AX,b
  NEG AX
  JMP Write
 Wnext1:
  MOV DX, 0
  MOV AX, b
 Write:
  MOV CX,10
 DIV CX
 PUSH AX
  PUSH DX
  INC BX
  CMP AX,0
  JZ exitWrite
  MOV DX,0
  JMP Write
 exitWrite:
  MOV CX,BX
 cicle:
  POP dx
  POP AX
  ADD DX, 48
  mov ax,dx
  xor dx,dx
  mov dl,1
  div dl
  stosb
  mov dx,sizeResult
  inc dx
  mov sizeResult,dx
 LOOP cicle
  mov bx, EnterIndex
  mov ax, colum
  cmp ax,bx
  jz EnterSymbol
  xor ax,ax
  mov al,' '
  stosb
  mov dx,sizeResult
  inc dx
  mov sizeResult,dx
  mov cx, CXforResult
   dec cx
   cmp cx,0
   mov CXforResult, cx
   jz EndResult
  jmp cicleResult
  EnterSymbol:
   mov al,13
   stosb
   mov dx,sizeResult
   inc dx
   mov sizeResult,dx
   mov al,10
   stosb
   mov dx,sizeResult
   inc dx
   mov sizeResult,dx
   mov ax,0 
   mov EnterIndex,ax
   mov cx, CXforResult
   dec cx
   cmp cx,0
   
   mov CXforResult,cx
   jz EndResult
 jmp cicleResult
   EndResult:
   mov al,'$'
   stosb
  popa
  RET
 InResult endp

 MatrixSHL proc                                         ; Циклический сдвих строки матрицы на 1 влево
  pusha
    push ax
     mov ax, ThisColum                      
     mov bx, colum                                      ; смещения для массива в bx
     mul bx
     mov bx,2
     mul bx
     mov bx,ax
     mov ax, colum
    dec ax
    mov si,2
    mul si
    mov si,ax
    add bx,si
    mov ax, matrix[bx]
    sub bx,si
    mov BufferArrayElem,ax
    pop ax
    mov cx, colum                 
   cicleColum:
    push cx 
    dec cx
    mov indexColum,cx
    pop cx
    mov dx, indexColum
    cmp dx, 0
    jnz nextCicleColum
     jmp IsNullColum
    nextCicleColum:
     push ax
     push dx
     mov ax, indexColum
     mov si,2
     mul si
     mov si,ax
     mov ax, BufferArrayElem
     dec si
     dec si
     add bx,si
     mov dx, matrix[bx]                       ; помещаем элемент из буффера в его соседа слева, а соседа слева в буффер
     mov BufferArrayElem, dx
     mov matrix[bx], ax
     sub bx,si
     pop dx
     pop ax
    loop cicleColum
     
    IsNullColum:                             ; Если первая строка, то ее элемент нужно в последнюю поместить
     push ax
     push dx
     mov ax, colum
     dec ax
     mov si,2
     mul si
     mov si,ax
     mov ax, BufferArrayElem
     add bx,si
     mov dx, matrix[bx]
     mov BufferArrayElem, dx
     mov matrix[bx], ax
     sub bx,si
     pop dx
     pop ax
   loop ciclecolum
  popa
  ret
 MatrixSHL endp

 transformation proc                          ; функция определяющая, солько раз нужно сдвинуть строку влево
   pusha
     mov cx, row
    cicleRow:
     mov ax, row
     mov bx, cx
     sub ax,bx
     mov ThisColum, ax
     cmp ax, 0
      jnz nextCicleRow
      jmp ciclerowEnd
     nextCicleRow:
      call MatrixSHL
      dec ax
      cmp ax,0
       jnz nextCicleRow
       jmp cicleRowEnd
     cicleRowEnd:
    loop cicleRow
   popa
   ret
 transformation endp
 
 InMatrix proc                                                ; Перевод чисел из буффера в матрицу числовую, т.е. считывание из буффера
   pusha
   MOV AX,0
  MOV sig, AX
  MOV i, AX
  MOV BX,0
  MOV CX,10
  MOV b, 0
 Read:
  lodsb
  MOV CX,i
  INC CX
  MOV i,CX
  MOV BL,36
  CMP AL,BL
  JNZ nextInput
 JMP exitRead
 nextInput:
  mov bl,' '
  cmp al,bl
  jnz next1
  jmp Space
 next1:
  MOV BL,13
  CMP AL,BL
  JNZ next2
  JMP ExitLine
 next2:
  CMP AL,48
  JNC next4
  MOV rez, CX
  MOV CX, i
  CMP CX, 1
  JZ SIGNUM
 SIGNUM:
  MOV rez, CX
  MOV CX, 1
  MOV sig, CX
  JMP Read
 next4:	  	
  SUB AL, 48
  MOV a,AL
  MOV BL,1
  MUL BL
  MOV c,AX
  MOV AX,b
  MOV CX,10
  MUL CX
  ADD AX,c 
  MOV b,AX
  JMP Read

 Space:                                     ; Если встретили пробел то заносим число в массив
  mov ax,b
  mov cx,sig
  cmp cx,1
  jnz next5
  mov cx,0
  mov sig,cx
  neg ax
 next5:
  mov bx,index
  mov matrix[bx], ax
  add bx,2
  mov index, bx
  mov ax, 0
  mov b, ax
  jmp Read 
 ExitLine:
  inc si
  jmp Space
 exitRead:
   mov ax,b
   mov cx,sig
   cmp cx,1
   jnz endNext
   neg ax
 endNext:
   mov bx,index
   mov matrix[bx], ax
   inc bx
   mov index, bx
   mov ax, 0
   mov b, ax
  popa  
  ret
 InMatrix endp

 out_str MACRO str                     ;макросс вывода строки
   push ax
   push dx
   mov ah, 09h
   mov dx, offset str
   int 21h
   pop dx
   pop ax
 endm

 file_close_input proc                  ; функция закрытия файла ввода
   pusha
   mov ah,3Eh
   mov bx,handle_input                  ; передаем хэндл файла
   int 21h
   jnc next3
   out_str error_message                ; вывод сообщения об ошибке, если есть она
   jmp exit
  next3:
   popa
   RET
 file_close_input endp

 file_close_output proc                  ; функция закрытия файла вывода
   pusha
   mov ah,3Eh
   mov bx,handle_output                  ; передаем хэндл файла
   int 21h
   jnc nextClose
   out_str error_message                 ; вывод сообщения об ошибке, если есть она
   jmp exit
  nextClose:
   popa
   RET
 file_close_output endp


main:
  mov ax,@data
  mov ds, ax
  mov es, ax
  
   xor ax,ax
   lea di, result
   mov ah,3Dh                                                ; функция открытия файла
   xor al,al                                                 ; режим открытия: только чтение
   lea dx, input                                             ; название файла для открытия
   xor cx,cx            
   int 21h
   jnc continue1 
   out_str error_message                                     ; сообщение об ошибке
   jmp exit
  continue1:
    mov handle_input, ax                                     ; запоминаем хэндл
    mov bx,ax                                                ; дескриптор файла для считывания
    mov ah,3Fh                                               ; функция чтение из файла
    lea dx,buffer                                            ; то, куда считываем
    mov cx, 300                                              ; макс число считываемых байт
    int 21h
    jnc continue2
    out_str error_message
    call file_close_input
    
  continue2:
    lea bx, buffer                         ; помецаем в конец буффера $
    add bx,ax                              ; в ax число считаных байт
    mov [bx],'$'                           ; добавляем к началу буффера число считаных байт и в конец $
    lea si, buffer                         ; настройка регистра si на buffer
    xor ax,ax
    lodsb                                  ; считаем из буффера N - число строк матрицы
    sub al,'0'
    mov byte ptr [row],al
    inc si
    lodsb                                  ; считаем из буффера M - число столбцов матрицы
    inc si
    inc si
    sub al,'0'
    mov byte ptr [colum],al
    call InMatrix                          ; вносим числа из буффера в матрицу
    call transformation                    ; трансформируем матрицу
    call InResult                          ; заносим матрицу в строку результат
    mov ah, 09h                            ; вывод результата на консоль
    lea dx, result
    int 21h
    xor ax,ax
    xor bx,bx
    xor dx,dx
    mov ah, 3Ch                           ; функция создания файла
    lea dx, output                        ; название создаваемого файла
    xor cx,cx                             ; cx=0 следовательно обычный файл
    int 21h
    jnc continue3 
   out_str error_message                  ; сообщение об ошибке, если такая есть
   jmp exit
  continue3:
   mov handle_output,ax                   ; запоминаем хэндл
   mov bx,ax                              ; в bx дескриптор файла для записи
   mov ah,40h                             ; функция записи в файл
   lea dx,result                          ; в dx строка, которую записываем, т.е. наш результат
   mov cx, sizeResult                     ; в cx количество выводимых символов
   int 21h
   jnc continue4
   out_str error_message                  ; сообщение об ошибке, если такая есть
  continue4:
   call file_close_output                 ; закрытие файла вывода
 exit:
    mov ax, 4c00h
    int 21h
end main
