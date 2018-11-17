  .model small
  .stack 100h
  .data
       a dw 0 
       b dw 0 
       c dw 0 
       d dw 0 
       dva dw 2 
       rows1 dw 0
       cols1 dw 0
       numeralrows dw 0
       numeralcols dw 0
       reservation dw 0
       numeraldet dw 0
       fromfile db "input.txt" 
       n dw ?
       stringmatrix db "Matrix transposed: $"
       determinant db "Matrix determinant: $"
       stringerrer db "ERROR$"
       buf db  100 dup (?)
       Matrix dw 100 dup (?)
       rows dw ?                      ;Строки  
       cols dw ?	              ;Столбцы
       handle dw ?
  .code

  PROC MATRIX3x3
       PUSH AX 
       PUSH BX 
       PUSH DX 
       PUSH CX
       XOR AX,AX
       MOV SI,0 
       MOV AX,Matrix[SI]
       MOV a,AX  
       MOV AX,8 
       ADD SI,AX
       MOV AX, Matrix[SI]
       IMUL a 
       MOV a,AX
       MOV AX, 16
       MOV SI,0
       ADD SI,ax
       MOV AX, Matrix[SI]
       IMUL a 
       MOV a,AX
       MOV AX, 12  
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI] 
       MOV b,AX
       MOV SI,0
       ADD SI,2 
       MOV AX, Matrix[SI] 
       IMUL b 
       MOV b,AX 
       MOV AX,10 
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI]
       IMUL b 
       MOV b,AX
       MOV AX, 6 
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI] 
       MOV c,AX
       MOV AX,4
       MOV SI,0 
       ADD SI,AX
       MOV AX, Matrix[SI] 
       IMUL c 
       MOV c,AX
       MOV AX, 14 
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI]
       IMUL c 
       MOV c,AX
       MOV AX, a 
       ADD AX,b 
       ADD AX,c 
       MOV d,AX 
       MOV AX,4 
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI] 
       MOV a,AX
       MOV AX,8 
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI] 
       IMUL a 
       MOV a,AX
       MOV AX,12
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI]
       IMUL a 
       MOV a,AX 
       MOV AX,6
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI]
       MOV b,AX
       MOV AX,2
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI] 
       IMUL b 
       MOV b,AX
       MOV AX,16
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI]
       IMUL b 
       MOV b,AX
       MOV AX,14
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI]
       MOV c,AX
       MOV AX,10
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI]
       IMUL c
       MOV c,AX
       MOV AX,0
       MOV SI,0
       ADD SI,AX
       MOV AX, Matrix[SI] 
       IMUL c
       MOV c,AX
       MOV AX, a 
       ADD AX,b 
       ADD AX,c 
       MOV b,AX
       MOV AX,d 
       MOV a,AX
       MOV AX,a 
       SUB AX,b 
       MOV a,AX
       MOV numeraldet,AX
       CALL CONCLUSIONNUMBER 
       POP CX 
       POP DX 
       POP BX 
       POP AX
       RET
  ENDP MATRIX3x3

  PROC MATRIX2x2
       PUSH AX 
       PUSH BX 
       PUSH DX 
       PUSH CX 
       XOR AX,AX
       MOV AX,0 
       MOV SI,0 
       ADD SI,AX
       MOV AX, Matrix[SI]
       MOV a,AX
       MOV AX,2 
       MOV SI,0 
       ADD SI,AX
       MOV AX, Matrix[SI]
       MOV b,AX
       MOV AX,4 
       MOV SI,0 
       ADD SI,AX
       MOV AX, Matrix[SI]
       MOV c,AX
       MOV AX, b 
       IMUL c 
       MOV b,AX
       MOV AX,6 
       MOV SI,0 
       ADD SI,AX
       MOV AX, Matrix[SI]
       IMUL a 
       MOV a,AX
       MOV AX,a 
       SUB AX,b 
       MOV a,AX
       MOV AX,a 
       MOV numeraldet,AX
       CALL CONCLUSIONNUMBER 
       POP CX
       POP DX 
       POP BX
       POP AX 
       RET
  ENDP MATRIX2x2

  PROC MATRIX1x1
       PUSH AX 
       PUSH BX 
       PUSH DX 
       PUSH CX 
       XOR AX,AX
       MOV AX,0 
       MOV SI,0 
       ADD SI,AX
       MOV AX, Matrix[SI] 
       MOV numeraldet,AX
       CALL CONCLUSIONNUMBER 
       POP CX
       POP DX 
       POP BX
       POP AX 
       RET
  ENDP MATRIX1x1

  PROC CONCLUSIONNUMBER 
       PUSH AX
       PUSH BX
       PUSH CX
       PUSH DX 
       MOV reservation,AX
       MOV DX,0 
       MOV BX,0 
       MOV CX,0 
       MOV CX,10
       SHL AX,1 
       JC labl 
       MOV AX,reservation
       conclusion: 
       MOV DX,0
       MOV CX,10
       DIV CX
       PUSH AX
       PUSH DX 
       INC BX
       CMP AX,0 
       JZ conclusionexit
       MOV DX,0 
       JMP conclusion
       labl: 
       MOV AX,reservation
       PUSH AX
       MOV DL,45
       MOV AH,02h
       INT 21h 
       POP AX
       NEG AX
       JMP conclusion
       conclusionexit: 
       MOV CX,BX
       cycle: 
       POP DX 
       POP AX
       ADD DX, 48 
       MOV AH, 02h 
       INT 21h 
       loop cycle
       MOV DL, 10 
       MOV AH, 02h 
       INT 21h 
       MOV DL, 13 
       MOV AH, 02h 
       INT 21h 
       POP AX
       POP BX
       POP CX
       POP DX
       RET
  ENDP CONCLUSIONNUMBER

  PROC CONCLUSIONNUMBERe 
       PUSH AX
       PUSH BX
       PUSH CX
       PUSH DX 
       MOV reservation,AX
       MOV DX,0 
       MOV BX,0 
       MOV CX,0 
       MOV CX,10
       SHL AX,1 
       JC lablLLL 
       MOV AX,reservation
       conclusionE: 
       MOV DX,0
       MOV CX,10
       DIV CX
       PUSH AX
       PUSH DX 
       INC BX
       CMP AX,0 
       JZ conclusionexitE
       MOV DX,0 
       JMP conclusionE
       lablLLL: 
       MOV AX,reservation
       PUSH AX
       MOV DL,45
       MOV AH,02h
       INT 21h 
       POP AX
       NEG AX
       JMP conclusionE
       conclusionexitE: 
       MOV CX,BX
       cycleE: 
       POP DX 
       POP AX
       ADD DX, 48 
       MOV AH, 02h 
       INT 21h 
       loop cycleE
       POP AX
       POP BX
       POP CX
       POP DX
       RET
  ENDP CONCLUSIONNUMBERe

  PROC MATRIXONCONSOLE
       PUSH AX
       PUSH BX
       PUSH CX
       PUSH DX 
       PUSH SI 
       MOV AX,rows 
       MOV rows1,AX 
       MOV AX,cols 
       MOV cols1,AX 
       MOV AX,0
       cycle1: 
       CALL STRINGNEW
       MOV numeralcols,0 
       cycle2:
       MOV AX,cols1 
       MUL numeralcols 
       ADD AX,numeralrows 
       MUL dva 
       MOV SI,0 
       MOV SI,AX 
       MOV AX, Matrix[SI] 
       CALL CONCLUSIONNUMBERe
       MOV DL, 9h 
       MOV AH, 02h 
       INT 21h 
       INC numeralcols
       MOV AX,cols1
       CMP AX,numeralcols
       JNZ cycle2
       DEC rows1
       INC numeralrows
       MOV AX,rows1
       CMP AX,0
       JNZ cycle1
       CALL STRINGNEW
       CALL STRINGNEW
       POP AX
       POP BX
       POP CX
       POP DX 
       POP SI
       RET 
  ENDP MATRIXONCONSOLE
  
  PROC FOPEN
       PUSH AX
       PUSH BX
       PUSH CX
       PUSH DX
       XOR DX,DX
       MOV AH,3Dh            ;Функция DOS 3Dh (открытие файла)
       XOR AL,AL               ;Режим открытия (только чтение)
       LEA DX,fromfile
       XOR CX,CX               ;Нет атрибутов (обычный файл)
       INT 21h
       MOV handle, AX	
       XOR DX, DX
       MOV BX,AX
       MOV AH,3Fh           ;Функция DOS 3Fh (чтение из файла)
       LEA DX,buf
       MOV CX, 95   ;Максимальное кол-во читаемых байтов
       INT 21h	
       XOR BX,BX
       LEA SI,buf
       ADD SI,AX  
       INC SI
       INC SI
       MOV byte ptr [SI], '$'	
       POP DX
       POP CX
       POP BX
       POP AX	
       XOR AX,AX
       MOV AH,3Eh
       MOV BX, handle
       INT 21h                
       RET	
  ENDP FOPEN

  PROC MATRIXFROMFILE
       XOR BP,BP
       XOR DX,DX	
       RETURNN:	
       XOR AX,AX
       lodsb
       CMP AL, '$'
       JZ INEND
       CMP AL, '-'
       JNE NEXT 
       INC BP
       JMP RETURNN
       NEXT:
       CMP AL, '9'
       JG CONTINUEE
       CMP AL, '0'
       JB CONTINUEE
       SUB AX,'0'	
       SHL DX,1	        
       ADD AX, DX
       SHL DX, 2
       ADD DX, AX	
       JMP RETURNN
       CONTINUEE:
       CMP AL,' '
       JNE LABLE
       JMP LABLEL
       LABLE:
       INC SI
       LABLEL:
       MOV AX,DX
       CMP BP, 1
       JNE posit
       NEG AX
       posit:
       MOV [DI],AX
       XOR DX,DX
       INC DI
       INC DI
       XOR BP, BP
       JMP RETURNN
       INEND:
       RET
  ENDP MATRIXFROMFILE

  PROC STRINGNEW
     PUSH AX
     PUSH DX
     MOV AH, 02h
     MOV DL, 13
     INT 21h
     MOV DL, 10
     INT 21h
     POP DX
     POP AX
     RET
  ENDP STRINGNEW

  PROC MATRSTR 
     ADD SI, 6
     PUSH CX
     PUSH SI
     XOR BP, BP
     CMP AX, 0
     JG LABMET
     NEG AX
     INC BP
     LABMET:
     XOR DX,DX
     MOV CX,10
     DIV CX
     MOV byte ptr [SI],'0'
     ADD [SI], DL
     DEC SI
     CMP AX, 0
     JG LABMET
     CMP BP, 0
     JE METKA
     MOV byte ptr [SI],'-'
     XOR BP,BP
     METKA:
     POP SI
     INC SI
     POP CX
     RET
  ENDP MATRSTR

  PROC TAKEELEMENT
	 XOR AX,AX
	 lodsb	;берем cимвол
	 SUB AL,'0'	;получаем цифровое значение
	 RET
  ENDP TAKEELEMENT

  PROC QUANTITYCOLSROWS
	CALL TAKEELEMENT
	MOV rows, AX
	INC SI
 	CALL TAKEELEMENT
	MOV cols, AX
	INC SI
	INC SI
 	RET	
  ENDP QUANTITYCOLSROWS

  PROC DET 
     PUSH AX
     PUSH BX
     PUSH CX
     PUSH DX
     LEA DX,determinant 
     MOV AH,09h 
     INT 21h 
     POP DX
     POP CX
     POP BX
     POP AX
     RET
  ENDP DET

  main:
      MOV AX, @DATA ; íàñòðîèì DS
      MOV DS, AX; íà ðåàëüíûé ñåãìåíò
      MOV es, AX
	
      CALL FOPEN
      LEA SI, buf	
      CALL QUANTITYCOLSROWS
      MOV AX, cols
      CMP AX, rows
      JNE ERRer
      XOR AX, AX
      LEA DI, Matrix
      CALL MATRIXFROMFILE
      LEA SI, Matrix
      CMP rows,3
      JZ THRE 
      CMP rows,2
      JZ TWO
      CMP rows,1
      JZ ONE
      JMP Jump
      THRE :
      CALL STRINGNEW
      CALL DET
      CALL MATRIX3x3
      CALL STRINGNEW
      JMP Jump
      TWO:
      CALL STRINGNEW
      CALL DET
      CALL MATRIX2x2
      CALL STRINGNEW
      JMP Jump
      ONE:
      CALL STRINGNEW
      CALL DET
      CALL MATRIX1x1
      CALL STRINGNEW
      Jump:
      ;MOV AH,9
      ;LEA DX,stringmatrix 
      ;INT 21h
      ;CALL MATRIXONCONSOLE
      JMP lastEXIT 
      ERRer:
      XOR AX, AX
      XOR DX,DX
      MOV AH,9
      LEA DX,stringerrer 
      INT 21h	
      lastEXIT:		
      MOV AX, 4c00h
      INT 21h
  end main
