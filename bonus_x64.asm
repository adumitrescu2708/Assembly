; @name: Dumitrescu Alexandra
; @group: 323 CA

section .text
	global intertwine
	extern puts

;; void intertwine(int *v1, int n1, int *v2, int n2, int *v);
;
;  Take the 2 arrays, v1 and v2 with varying lengths, n1 and n2,
;  and intertwine them
;  The resulting array is stored in v

intertwine:
	enter 	0, 0

	mov		rax, [rbp + 32]		; using RAX for storing v1
	mov 	ebx, [rbp + 20]		; using RBX for storing n1
	mov 	rcx, [rbp + 40]		; using RCX for storing v2
	mov 	edx, [rbp + 24]		; using RDX for storing n2
	mov 	rsi, [rbp + 48]		; using RSI for storing v


	xor 	rdi, rdi			; using RDI for looping in v1 and v2
	xor		rsi, rsi 			; using RSI for looping in v

	;; __________________
	;; loop_both_arrays()
	;
	; Use: 	  1. RDI - index for looping simultaneously in v1 and v2
	;		  2. RSI - index for adding elements in final array v
	;
	; Steps:  1. Copy the value of v1[RDI] in v[RSI]
	; 		  2. Increment RSI
	; 		  3. Copy the value of v2[RDI] in v[RSI]
	;		  4. Increment RSI and RDI
	;  		  5. Continue until the end of one of the arrays is reached
	; 			 meaning RDI is equal to n1 or n2
	; 		  6. Stop copying simultaneously characters from both arrays
	; 			 and copy left characters from the longer array (could be
	;			 v1 or v2)



loop_both_arrays:
	xor		rcx, rcx 						; Initialise RCX with 0

	mov 	ecx, [rax + rdi * 4] 			; Get the value of v1[RDI] in ECX
	mov		rdx, [rbp + 48] 				; Use RDX for restoring v
	mov 	[rdx + rsi * 4], ecx 			; Update v[RSI] with v1[RDI]
	
	mov 	rcx, [rbp + 40] 				; Use RCX for restoring v2
	mov 	rdx, [rbp + 24] 				; Use RDX for restoring n2
	inc 	rsi 							; Increment RSI for looping in v

	xor		rax, rax 						; Initialise RAX with 0
	mov 	eax, [rcx + rdi * 4] 			; Get the value of v2[RDI] in EAX
	mov 	rbx, [rbp + 48] 				; Use RDX for restoring v
	mov 	[rbx + rsi * 4], eax 			; Update v[RSI] with v2[RDI] 

	xor		rbx, rbx
	xor		rdx, rdx

	mov		rax, [rbp + 32] 				; Use RAX for restoring v1
	mov 	ebx, [rbp + 20] 				; Use EBX for restoring n1
	mov 	rcx, [rbp + 40] 				; Use RCX for restoring v2
	mov 	edx, [rbp + 24]					; Use EDX for restoring n2

	inc		rdi 							; Increment looping index in v1
	inc 	rsi 							; v2 and in v


	cmp		rdi, rbx 						; If the current index is equal
	je 		verify_second_array 			; to total number of elements in
											; first array then check if there
											; are elements left in second array

	cmp		rdi, rdx 						; If the current index is equal
	je 		loop_first_array 				; to total number of elements in
 											; second array then check if
 											; there are elements left in
 											; first array
	jmp		loop_both_arrays


verify_second_array:
	cmp		rdi, rdx 						; Verifiy if both arrays have equal
	je 		finish 							; lengths

loop_second_array: 							; Copy elements left in 2nd array
	xor		rax, rax 						; Initialise RAX with 0
	mov 	eax, [rcx + rdi * 4] 			; Use EAX for storing v2[RDI]
	mov 	rbx, [rbp + 48] 				; Use RBX for restoring v

	mov 	[rbx + rsi * 4], eax 			; Update v[RSI] with v2[RDI]

	inc		rsi 							; Increment loop index in v
	inc 	rdi 							; Increment loop index in v2

	cmp		rdi, rdx 						; Stop copying when the end of v2
	je		finish 							; is reached

	jmp		loop_second_array 


loop_first_array: 							; Copy elements left in v1
	xor		rcx, rcx 						; Initialise RCX with 0
	mov 	ecx, [rax + rdi * 4]			; Use ECX for storing v1[RDI]
	mov		rdx, [rbp + 48] 				; Use RDX for restoring v

	mov 	[rdx + rsi * 4], ecx 			; Update v[RSI] with v1[RDI]
	
	inc 	rsi 							; Increment loop index in v
	inc		rdi 							; Increment loop index in v1

	cmp		rdi, rbx 						; Stop copying when the end of v1
	je 		finish							; is reached

	jmp		loop_first_array

finish:
	leave
	ret
