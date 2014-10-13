%define SYS_WRITE	4
%define SYS_EXIT	1

%define STDOUT		1

section .bss
buffer:		resb	8

section .data
newline:
			db 0x0a
space:
			db 0x20
hnumber:
			db "hexadecimal number = 0x"
dnumber:
			db "decimal number = "
inputerror:
			db 0x0a, "invalid hexadecimal number", 0x0a
section .text
global _start
;;;-----------------------------------------------------------------------------
;;; main programm
;;;-----------------------------------------------------------------------------
_start:
		nop

		pusha
		mov		eax,	SYS_WRITE
		mov		ebx,	STDOUT
		mov		ecx,	hnumber
		mov		edx,	23
		int		80h
		popa

		pop		edx
		pop		ecx
		dec		edx
		pop		ecx
		dec		edx
		mov		esi,	ecx
		jg		print_error
		push	esi

		call	print_input
		pop		esi
		cmp		edx, byte 8
		jg		print_error
		
		
		pusha
		push	esi
		call	print_newline
		popa
		pop		esi

		pusha
		push	esi
		mov		eax,	SYS_WRITE
		mov		ebx,	STDOUT
		mov		ecx,	dnumber
		mov		edx,	17
		int		80h
		popa
		pop		esi
		
		pusha
		call	prepare_ascii
		call	AtoD
		popa
		
exit:
		mov		eax,	SYS_EXIT
		mov		ebx,	0
		int		80h
;;;-----------------------------------------------------------------------------
;;; Subroutines for convert16to10
;;;-----------------------------------------------------------------------------
prepare_ascii:
		mov		eax,	0
		mov		al,	[esi]
		inc		esi
		
		cmp		eax,	0x30		;; kleiner als 0
		jge		re0					;; wenn nicht gehe zu re0
		call	print_error			;; sonst fehler
		jmp		quit
	re0:
		cmp		eax,	0x39		;; größer als 9?
		jg		re1					;; wenn ja, re1
		jle		re4
	re1:
		cmp		eax,	0x66		;; größer als f?
		jle		re2					;; wenn nicht, überspring den fehler
		call	print_error			;; wenn ja FEHLER
		jmp		quit
	re2:
		cmp		eax,	0x61		;; kleiner als a?
		jge		re3					;; wenn nicht, überspring den fehler
		call	print_error			;; wenn ja FEHLER
		jmp		quit
	re3:
		sub		eax,	0x57
		rol		eax,	28
		shld	edi,	eax,4
		jc		print_error
		cmp		[esi], byte 0
		je		quit
		jmp		next
	re4:
		sub		eax,	0x30
		rol		eax,	28
		shld	edi,	eax,4
		cmp		[esi],	byte 0
		je		quit
		jmp		next
	next:
		mov		ebx,	0
		mov		bl,	[esi]
		inc		esi
		
		cmp		ebx,	0x30		;; kleiner als 0
		jge		re5					;; wenn nicht gehe zu re0
		call	print_error			;; sonst fehler
		jmp		quit
	re5:
		cmp		ebx,	0x39		;; größer als 9?
		jg		re6					;; wenn ja, re1
		jle		re9
	re6:
		cmp		ebx,	0x66		;; größer als f?
		jle		re7					;; wenn nicht, überspring den fehler
		call	print_error			;; wenn ja FEHLER
		jmp		quit
	re7:
		cmp		ebx,	0x61		;; kleiner als a?
		jge		re8					;; wenn nicht, überspring den fehler
		call	print_error			;; wenn ja FEHLER
		jmp		quit
	re8:
		sub		ebx,	0x57
		rol		ebx,	28
		shld	edi, ebx,4
		cmp		[esi], byte 0
		je		quit
		jg		prepare_ascii
		jmp		quit
	re9:
		sub		ebx,	0x30
		rol		ebx,	28
		shld	edi, ebx,4
		cmp		[esi], byte 0
		je		quit
		jg		prepare_ascii
	quit:
		ret
		
AtoD:
		mov		edx,	0xaffe
		mov		eax,	 edi
		push	edx
convert:
		mov		edx,	0
		mov		ebx, 10d
		div		ebx
		add		edx, 0x30
		push	edx
		cmp		eax, byte 0
		jg		convert
	print:
		pop		ecx
		cmp		ecx,	0xaffe
		je		back
		mov		[buffer], ecx
		mov		ecx,	buffer
		call	print_value
		jmp		print
	back:
		call	print_newline
		ret



print_value:
		mov		eax,	4
		mov		ebx,	1
		mov		edx,	4
		int		80h
		ret
		
print_input:

		push eax
		push ebx
		push ecx
		mov		eax,	4
		mov		ebx,	1
		mov		edx,	0
		push	ecx		; keep starting address of string
search_eos:
		cmp	[ecx], byte 0	; end of string (0) reached?
		je	eos_found	; yes, end of loop
		inc	edx		; count
		inc	ecx		; next position in string
		jmp	search_eos	; loop
eos_found:
		pop	ecx		; restore starting address of string
		int		80h
		pop ecx
		pop ebx
		pop eax
		ret
print_newline:
		mov		eax,	4
		mov		ebx,	1
		mov		ecx,	newline
		mov		edx,	1
		int		80h
		ret
print_error:
		mov		eax,	SYS_WRITE
		mov		ebx,	STDOUT
		mov		ecx,	inputerror
		mov		edx,	28
		int		80h
		jmp exit
		ret
