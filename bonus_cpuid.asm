; @name: Dumitrescu Alexandra
; @group: 323 CA


section .text
	global cpu_manufact_id
	global features
	global l2_cache_info

;; void cpu_manufact_id(char *id_string);
;
;  reads the manufacturer id string from cpuid and stores it in id_string

cpu_manufact_id:
	enter 	0, 0

	push	ebx
	mov		eax, 0				; Call CPUID for EAX = 0
	cpuid
	mov 	eax, [ebp + 8] 		; Use EAX for storing the string
	xor		esi, esi 			; Initialise ESI with 0 used for looping in EAX
	xor 	edi, edi 			; Initialise EDI with 0 used for counting 4
								; steps when copying characters from registers
	push	ecx 				; Save results of CPUID on stack
	push 	edx
	push	ebx

	;;
	; The string result is saved in EBX:EDX:ECX
	; Therefore, we loop in the 3 registers and copy each
	; character in the given string

	pop		ebx 				; Restore EBX result
	xor		edi, edi 			; Initialise EDI with 0
	xor		ecx, ecx 			; Initialise ECX with 0
copy_characters_from_ebx:
	mov		cl, bl 				; Copy first character in CL
	mov		[eax + esi], cl 	; Update string[ESI] = character

	inc 	esi 				; Increment index in string
	inc 	edi 				; Increment counter of characters

	shr		ebx, 8 				; Shift right EBX with 8 bits to remove
								; the character
	cmp 	edi, 4 				; Stop copying characters when total
	jne		copy_characters_from_ebx 	; count of characters is 4



	pop		edx 				; Restore EDX result
	xor		edi, edi 			; Initialise EDI with 0
	xor		ebx, ebx 			; Initialise EBX with 0
copy_characters_from_edx:
	mov		bl, dl 				; Copy first character in CL
	mov		[eax + esi], bl 	; Update string[ESI] = character

	inc 	esi 				; Increment index in string
	inc 	edi 				; Increment counter of characters

	shr		edx, 8				; Shift right EDX with 8 bits to remove
								; the character
	cmp 	edi, 4				; Stop copying characters when total
	jne		copy_characters_from_edx	; count of characters is 4



	pop		ecx 				; Restore ECX result
	xor		edi, edi 			; Initialise EDI with 0
	xor		ebx, ebx 			; Initialise EBX with 0
loop_ecx:
	mov		bl, cl 				; Copy first charcter in BL
	mov		[eax + esi], bl 	; Update string[ESI] = character

	inc 	esi 				; Increment index in string
	inc 	edi 				; Increment counter of characters

	shr		ecx, 8 				; Shift right ECX with 8 bits to remove
	cmp 	edi, 4				; the character
	jne		loop_ecx 			; Stop copying when total count of
								; of characters in 4

	jmp		final

final:

	mov 	byte [eax + esi], 0 	; place NULL
	pop		ebx

	leave
	ret


;; void features(char *vmx, char *rdrand, char *avx)
;
;  checks whether vmx, rdrand and avx are supported by the cpu
;  if a feature is supported, 1 is written in the corresponding variable
;  0 is written otherwise
features:
	enter 	0, 0

	push	ebx

	mov 	eax, 1 			; call CPUID for EAX = 1
	cpuid

	mov		ebx, ecx 		; Make a copy of ECX result
	shr		ecx, 5 			; Get the 5th bit
	and		ecx, 1
	mov		edx, [ebp + 8] 	; Use EDX for vmx
	mov		[edx], ecx 		; Copy result in vmx
	

	mov		ecx, ebx 		; Restore ECX
	shr		ecx, 30 		; Get the 30th bit
	and		ecx, 1
	mov		edx, [ebp + 12] ; Use EDX for rdrand
	mov		[edx], ecx 		; Copy result in rdrand

	mov		ecx, ebx 		; Restore ECX
	shr		ecx, 28 		; Get the 28th bit
	and		ecx, 1
	mov		edx, [ebp + 16] ; Use EDX for avx
	mov		[edx], ecx 		; Copy result in avx

	pop		ebx

	leave
	ret

;; void l2_cache_info(int *line_size, int *cache_size)
;
;  reads from cpuid the cache line size, and total cache size for the current
;  cpu, and stores them in the corresponding parameters
l2_cache_info:
	enter 	0, 0
	
	push	ebx

	mov		eax, 80000006h 		; call CPUID for EAX = 80000006h
	cpuid

	xor		edx, edx 			; Copy last CL part of ECX in DL
	mov		dl, cl

	mov		ebx, [ebp + 8]		; Use EBX for line_size
	mov		[ebx], edx 			; Update line_size with result

	shr		ecx, 16 			; Get bits 31-16 for cache_size
	xor		edx, edx
	mov		dx, cx

	mov		ebx, [ebp + 12] 	; Use EBX for cache_size
	mov		[ebx], edx 			; Update cache_size with result

	pop		ebx

	leave
	ret
