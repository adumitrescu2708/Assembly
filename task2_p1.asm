; @name: Dumitrescu Alexandra
; @group: 323 CA

section .text
	global cmmmc

;; int cmmmc(int a, int b)
;
;; calculate least common multiple fow 2 numbers, a and b

	;; ________
	;; cmmmc()
	;
	; For computing the cmmmc we are using the common rule:
	;			(a * b) = cmmmc(a, b) * cmmdc(a, b)
	; Therefor, we compute the cmmdc (a, b) using the Euclid's algorithm
	; and then divide the product (a * b) with it 


cmmmc:
	
	pop 	ebx 	; using EBX for saving the return address

	pop 	ecx 	; using ECX for saving the first argument,  a
	pop		edx 	; using EDX for saving the second argument, b

	push 	ecx 	; making a copy of the first argument, a
	pop		eax  	; and storing it in EAX

	push 	edx 	; making a copy of the second argument, b
	mul 	edx  	; and compute the product of (a * b)
	pop 	edx  	; and restore the second argument, b

	push 	eax 	; save the product of (a * b) on stack


	;; 	cmmdc()
	; 	Euclid's Algorithm for cmmdc
	;
	;	Given the 2 arguments, a and b, stored in ECX and EAX
	; continue substracting the lower value from the greater value
	; until the 2 values are equal.

cmmdc:
	cmp 	ecx, edx 		; if a > b
	jg 		a_is_greater 	; then a = a - b

	cmp 	ecx, edx 		; if a < b
	jl 		b_is_greater	; then b = b - a

	cmp 	ecx, edx
	je 		compute_cmmmc

a_is_greater:	
	sub 	ecx, edx
	jmp 	cmmdc


b_is_greater:
	sub 	edx, ecx
	jmp 	cmmdc


compute_cmmmc:
	xor edx, edx 	; make edx 0

	pop eax 		; restore (a * b)
	div ecx 		; compute (a * b) / cmmdc(a, b)

	push ebx 		; restore return address

	ret
