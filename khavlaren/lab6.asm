intSegment SEGMENT PARA
assume CS:intSegment, DS:intSegment, ES:intSegment, SS:intSegment
org 80h
	cmdLength db ?
	cmdLine db ?
org 100h	
		
EntryPoint:
	JMP Install
	
; Our handler procedure.
custom21Handler PROC
	DIFFERENCE equ 32
	CMP AH, 09h
	JZ ourBusiness
	JMP dword ptr CS:[saved21Vector]

; Start of our handler.
ourBusiness:
	PUSHF
	PUSH AX
	PUSH DX
	PUSH SI
	PUSH CS
	POP ES

	MOV SI, DX
output:
	LODSB
	CMP AL, '$'
	JZ clean
	CMP AL, 'A'
	JB notLetter
	CMP AL, 'Z'
	JA notBigLetter
	ADD AL, DIFFERENCE
	MOV DL, AL
	JMP displaySymbol
	
notBigLetter:
	CMP AL, 'a'
	JB notLetter
	CMP AL, 'z'
	JA notLetter
	SUB AL, DIFFERENCE
	MOV DL, AL
	JMP displaySymbol
	
notLetter:
	MOV DL, AL
	
displaySymbol:
	MOV AH, 02h
	INT 21h
	JMP output
	
clean:
	POP SI
	POP DX
	POP AX
	POPF
	IRET
	
saved21Vector dd ?
custom21Handler ENDP

messageError db 10, 13, "Error: wrong parameters of command line.", 10, 13, '$'
messageInstall db 10, 13, "OuR haNDleR was SucceSSuLly InsTALLed. TrY It noW:", 10, 13, '$'
messageInstalled db 10, 13, "Our handler is already installed.", 10, 13, '$'
messageNotInstalled db 10, 13, "Our handler is not installed.", 10, 13, '$'
messageUnistalled db 10, 13, "Our handler was uninstalled.", 10, 13, '$' 
messageCmdError db 10, 13, "Invalid set of parameters.", 10, 13, '$'
isInstalled dw 7319h

Install:
	MOV AX, 3521h
	INT 21h
	MOV word ptr saved21Vector, BX
	MOV word ptr saved21Vector + 2, ES
	
	CMP cmdLength, 0
	JZ installOnly
	CMP cmdLength, 3
	JNZ parametersError
	
	CMP cmdLine[1], '-'
	JNZ parametersError
	CMP cmdLine[2], 'd'
	JNZ parametersError

	CMP ES:isInstalled, 7319h
	JNZ notInstalledCase
	
; Deleting our handler
	LEA DX, messageUnistalled
	MOV AH, 09h
	INT 21h
	MOV DS, word ptr ES:saved21Vector + 2
	MOV DX, word ptr ES:saved21Vector
	MOV AX, 2521h
	INT 21h
	JMP exit

notInstalledCase:
	LEA DX, messageNotInstalled
	MOV AH, 09h
	INT 21h
	JMP exit
	
parametersError:
	LEA DX, messageCmdError
	MOV AH, 09h
	INT 21h
exit:
	MOV AX, 4c00h
    INT 21h
	
installOnly:
	CMP ES:isInstalled, 7319h
	JNZ firstInstall
	LEA DX, messageInstalled
	MOV AH, 09h
	INT 21h
	JMP exit
	
firstInstall:
	MOV AX, 2521h
	MOV DX, offset custom21Handler
	INT 21h
	LEA DX, messageInstall
	MOV AH, 09h
	INT 21h
	JMP check
	
	maxLine db 250
	leng db ?
    line db 250 dup('$')
	newLine db 10, 13, '$'

; Read and display line to check if program works correctly.
check:
	LEA DX, maxline
    MOV AH, 0ah
    int 21h
    LEA DX, newLine
    MOV AH, 09h
    INT 21h
    LEA DX, line
    MOV AH, 09h
    INT 21h
	
; Leave our handler as residential.
	MOV DX, offset Install
	INT 27h
intSegment ENDS
END EntryPoint