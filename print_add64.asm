;;start of bss section
section .bss
result:		resb	8
buffer:		resb	4
;;; start of data section
section .data
;;; a newline character
newline:
			db 0x0a
space:
			db 0x20

section .text
global _start
;;;-----------------------------------------------------------------------------
;;; main programm
;;;-----------------------------------------------------------------------------
_start:

		nop

		mov		eax,	0x11111111
		mov		ebx,	0x22222222
		mov		ecx,	0x33333333
		mov		edx,	0xffffffff


;;		prints a new line for more style
		pusha						;; save all registers
		call	print_newline
		popa						;; save all registers


;;		first step
		pusha						;; save all registers
		call	print_registers
		call	print_flags
		popa						;; recreate registers

;;		second step
		add		ebx,	edx			;; Add the least significant parts
		pusha						;; save all registers
		pushf						;; save all flags
		pushf						;; save all flags
		call	print_registers
		popf						;; recreate flags
		call	print_flags
		popf						;; recreate flags
		popa						;; recreate registers

;;		third step
		adc		eax,	ecx
		pusha						;; save all registers
		pushf						;; save all flags
		call	print_registers
		popf						;; recreate flags
		call	print_flags
		popa						;; recreate registers

 exit:
		mov		eax,	1
		mov		ebx,	0
		int		80h
;;;-----------------------------------------------------------------------------
;;; Stuff needed for add64
;;;-----------------------------------------------------------------------------
;;; defines needed variables and functions for Task Add64

print_space:
		mov		eax,	4
		mov		ebx,	1
		mov		ecx,	space
		mov		edx,	1
		int		80h
		ret

print_newline:
		mov		eax,	4
		mov		ebx,	1
		mov		ecx,	newline
		mov		edx,	1
		int		80h
		ret

print_value:
		;; prints without new-line character 
		mov		eax,	4			;; write syscall
		mov		ebx,	1			;;fd = 1 (stdout)
		mov		edx,	8			;;count bytes
		int		80h
		ret

convert_value:
		dec		eax					;; decrement eax
		mov		edx, 0x0			;; clear edx

		shld	edx,	ebx,	4	;; shift first value to edx
		rol		ebx,	4			;; roll half a bit
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


print_registers:

		pusha						;; save all registers
		mov		ebx,	eax
		mov		eax,	0x08
		call	convert_value
		call	print_space
		popa						;; recreate registers

		pusha						;; save all registers
		mov		eax,	0x08
		call	convert_value
		call	print_space
		popa						;; recreate registers

		pusha						;; save all registers
		mov		ebx,	ecx
		mov		eax,	0x08
		call	convert_value
		call	print_space
		popa						;; recreate registers

		pusha						;; save all registers
		mov		ebx,	edx
		mov		eax,	0x08
		call	convert_value
		popa						;; recreate registers

		call	print_newline

		ret

print_flags:
		pushf						;; save all flags
		pop		esi
		mov		[buffer],byte	0x6F
		shl		esi,		21
		jnc		re1
sflow:
		sub		[buffer],byte	0x20
re1:
		mov		ecx,	buffer
		call	print_value
		mov		[buffer],byte	0x73
		shl		esi,		4
		jnc		re2
ssign:
		sub		[buffer],byte	0x20
re2:
		mov		ecx,	buffer
		call	print_value
		mov 	[buffer],byte	0x7A
		shl		esi,		1
		jnc		re3
szero:
		sub		[buffer],byte	0x20
re3:
		mov		ecx,	buffer
		call	print_value
		mov		[buffer],byte	0x61
		shl		esi,		2
		jnc		re4
saux:
		sub		[buffer],byte	0x20
re4:
		mov		ecx,	buffer
		call	print_value
		mov		[buffer],byte	0x70
		shl		esi,		2
		jnc		re5
spar:
		sub		[buffer],byte	0x20
re5:
		mov		ecx,	buffer
		call	print_value
		mov		[buffer],byte	0x63
		shl		esi,		2
		jnc		re6
scar:
		sub		[buffer],byte	0x20
re6:
		mov		ecx,	buffer
		call	print_value
		call	print_newline

		ret
