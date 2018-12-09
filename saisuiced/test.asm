.model small
.stack 100h
.data
    testMessage db 'Hello Word! Im very cool program for testing lab6', 13, 10, '$'
.code

Start:
  mov ax, @DATA
  mov ds, ax

  mov dx, offset testMessage
  mov ah, 09h
  int 21h

  mov ax, 4C00h
  int 21h
end Start
