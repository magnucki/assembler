;;; system call
%define SYS_WRITE	4
%define SYS_EXIT	1
;;; file ids
%define STDOUT		1
	
;;start of bss section
section .bss
bigbuf:		resb	32
buffer:		resb	8
;;; start of data section
section .data
;;; a newline character
newline:
			db 0x0a
space:
			db 0x20
hnumber:
			db "hexadecimal number = 0x"
dnumber:
			db "decimal number = "
inputerror:
			db 0x0a,"invalid decimal number",0x0a

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
		mov		ecx,	dnumber
		mov		edx,	17
		int		80h
		popa

		pop esi
		pop ecx
		pop ecx
		mov esi, ecx
		push esi
		pusha
		call	print_input
		push	edx			;save length
		popa
		pop		edx

		pusha
		call	print_newline
		popa
		pop esi
		mov		ebx,	0
		call	prepare_ascii

		pusha
		mov		eax,	SYS_WRITE
		mov		ebx,	STDOUT
		mov		ecx,	hnumber
		mov		edx,	23
		int		80h
		popa

		call	AtoH

		pusha
		call print_newline
		popa

	exit:
		mov eax, SYS_EXIT
		mov	ebx, 1
		int 80h

;;;-----------------------------------------------------------------------------
;;; Stuff needed for convert10to16
;;;-----------------------------------------------------------------------------





prepare_ascii:
		cmp		[esi],	byte 0
		je		back
		mov		eax,	0
		mov		al,	[esi]
		inc esi

		cmp		eax,	0x40			;größer als 9?
		jge		print_error
		cmp		eax,	0x30
		jl		print_error
		sub		eax,	0x30
		cmp		ebx,	0
		je		stelle0
		cmp		ebx,	1
		je		stelle1
		cmp		ebx,	2
		je		stelle2
		cmp		ebx,	3
		je		stelle3
		cmp		ebx,	4
		je		stelle4
		cmp		ebx,	5
		je		stelle5
		cmp		ebx,	6
		je		stelle6
		cmp		ebx,	7
		je		stelle7
		jg		print_error
	stelle0:
		mov		ecx,	1d
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	stelle1:
		mov		ecx,	10d
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	stelle2:
		mov		ecx,	100d
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	stelle3:
		mov		ecx,	1000d
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	stelle4:
		mov		ecx,	10000d
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	stelle5:
		mov		ecx,	100000d
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	stelle6:
		mov		ecx,	1000000d 
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	stelle7:
		mov		ecx,	100000000d
		imul	ecx
		add		edi,	eax
		inc		ebx
		jmp		prepare_ascii
	back:
		ret

print_value:
		mov		eax,	4
		mov		ebx,	1
		mov		edx,	4
		int		80h
		ret

print_input:
		pusha
		mov		eax,	4
		mov		ebx,	1
		mov		edx,	0
		push	ecx		; keep starting address of string
search_eos:
		cmp	[ecx], byte 0	; end of string (0) reached?
		je	eos_found	; yes, end of loop
		inc	edx		; count
		cmp edx, 10
		je	eos_found
		inc	ecx		; next position in string
		jmp	search_eos	; loop
eos_found:
		pop	ecx		; restore starting address of string
		int		80h
		popa
		ret

print_error:
		mov		eax,	SYS_WRITE
		mov		ebx,	STDOUT
		mov		ecx,	inputerror
		mov		edx,	28
		int		80h
		jmp exit
		ret

print_newline:
		mov		eax,	4
		mov		ebx,	1
		mov		ecx,	newline
		mov		edx,	1
		int		80h
		ret
