;;; system call
%define SYS_WRITE	4
%define SYS_EXIT	1
;;; file ids
%define STDOUT		1
	
;;start of bss section
section .bss
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
			db "invalid decimal number",0x0a

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

		pop		ecx
		pop		ecx
		pop		ecx
		mov		esi,	ecx
		push esi
		call	print_input
		push	edx			;save length
		cmp		edx , byte 10
		jg 		print_error
		
		pusha
		call	print_newline
		popa
		
		pop edx
		pop esi

		call	read

		pusha
		mov		eax,	SYS_WRITE
		mov		ebx,	STDOUT
		mov		ecx,	hnumber
		mov		edx,	23
		int		80h
		popa

		mov		eax, 0x08
		call	convert_value


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


convert_value:
		dec		eax					;; decrement eax
		mov		edx, 0x0			;; clear edx

		shld	edx,	edi,	4	;; shift first value to edx
		rol		edi,	4			;; roll half a bit
		add		edx,	0x30		;;convert to ascii numbers
		cmp		edx,	0x39		;;check if higher than 9
		jle		noproblem			;;jump if 9 or lower
		add		edx,	0x27		;;convert to chars
noproblem:
		mov		[buffer],	edx
		mov		ecx,	buffer

		pusha						;; save all registers

		call	print_value			;; print value

		popa						;; recreate registers

		cmp		eax,	0x00		;; run 8 times?
		je		return				;; if true, return to mainprogramm
		ja		convert_value		;; if false loop back
return:
		ret



read:
		mov		eax,	0
		mov		al,		[ecx]
		inc		ecx
		sub		eax,	0x30
		cmp		eax,	0x09
		jg		print_error
convert:
		cmp		edx,	10d
		je		re10
		cmp		edx,		9d
		je		re9
		cmp		edx,	8d
		je		re8
		cmp		edx,		7d
		je		re7
		cmp		edx,	6d
		je		re6
		cmp		edx,		5d
		je		re5
		cmp		edx,	4d
		je		re4
		cmp		edx,		3d
		je		re3
		cmp		edx,	2d
		je		re2
		cmp		edx,		1d
		je		back

	re10:
		mov		ebx,	1000000000
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re9:
		mov		ebx,	100000000
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re8:
		mov		ebx,	10000000
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re7:
		mov		ebx,	1000000
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re6:
		mov		ebx,	100000
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re5:
		mov		ebx,	10000
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re4:
		mov		ebx,	1000
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re3:
		mov		ebx,	100
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	re2:
		mov		ebx,	10
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		dec		edx
		jmp		read
	back:
		mov		ebx,	1
		push	edx
		imul	ebx
		pop		edx
		add		edi,	eax
		jc		print_error
		dec		edx
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

print_error:
		mov		eax,	SYS_WRITE
		mov		ebx,	STDOUT
		mov		ecx,	inputerror
		mov		edx,	26
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
