; @name: Dumitrescu Alexandra
; @group: 323 CA

section .text
	global par

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression


; 40 = ascii('(') = opened bracket
; 41 = ascii(')') = closed bracket

	;;______
	;; par()
	;
	;  The main idea is to compute the final result (true / false)
	;  using a counter of total brackets. If an opened bracket
	;  is found, then the counter increments and if a close bracket
	;  occurs, the counter decrements. A string is valid if at the end
	;  this counter is 0. If when looping in the string and updating
	;  the counter value a negative counter occurs, return false
	;  meaning that there are more closed brackets then opened ones.
	;		Example: ()))(( -> At the end the counter is 0 but
	;						   the string isn't valid

par:
	pop		ebx 			; using EBX for storing the return address

	pop 	edi 			; using EDI for storing the length of the string
	pop		edx 			; using EDX for storing string

	xor 	esi, esi 		; using ESI for looping in the string
	xor 	ecx, ecx 		; using ECX for counting the opened parantheses

string_loop:
	xor 	eax, eax 			; reset EAX
	push 	word [edx + esi] 	; push ESI-th character from string on stack
	pop 	ax 					; pop it in AX
	and 	eax, 0xFF00 		; mask 
	shr 	eax, 8 				; shift 8 bits to obtain the first character
	push 	word ax 			; Push the first bracket

	xor 	eax, eax 			; reset EAX
	push 	word [edx + esi] 	; push ESI-th character from string on stack
	pop 	ax 					; pop it in AX
	and eax, 0xFF 				; mask
	push word ax 				; obtain the second character

	pop ax 						; restore the second bracket

	cmp ax, 40 					; check if first bracket is open
	je first_bracket_is_open

	cmp ax, 41 					; check if first bracket is closed
	je first_bracket_is_closed

updated_first_bracket:
	xor eax, eax 				; reset EAX

	pop ax 						; restore the first bracket

	cmp ax, 40 					; check if first bracket is open
	je second_bracket_is_open

	cmp ax, 41 					; check if first bracket is closed
	je second_bracket_is_closed

updated_second_bracket:
	cmp ecx, 0
	jl incorrect
	
	add esi, 2 					; stop looping in string when the end of
	cmp esi, edi 				; the string is reached
	jl string_loop 				; increment index ESI with 2 as 2 characters
 								; are computed simultaneously
	cmp esi, edi
	jge final



first_bracket_is_open: 				; If an open bracket occurs increment
	inc ecx 						; total counter of brackets
	jmp updated_first_bracket


first_bracket_is_closed: 			; If a closed bracket occurs decrement
	dec ecx 						; total counter of brackets
	jmp updated_first_bracket	


second_bracket_is_open: 			; If an open bracket occurs increment
	inc ecx 						; total counter of brackets
	jmp updated_second_bracket


second_bracket_is_closed: 			; If a closed bracket occurs decrement
	dec ecx 						; total counter of brackets
	jmp updated_second_bracket




final:
	cmp ecx, 0 			; If total counter of brackets is 0
	je correct 			; the string is valid

	cmp ecx, 0 			; Otherwise, the string is not valid
	jne incorrect

correct:
	push 1 				; Return true value
	pop eax 			; Empty the stack
	jmp stop

incorrect:
	push 0 				; Return false value
	pop eax 			; Empty the stack
	jmp stop


stop:
	push ebx 			; Restore return address
	ret
