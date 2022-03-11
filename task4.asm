; @name: Dumitrescu Alexandra
; @group: 323 CA

section .text

global expression
global term
global factor


; `factor(char *p, int *i)`
;       Evaluates "(expression)" or "number" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression

factor:
    push    ebp 					; create stack frame
    mov     ebp, esp

    mov		eax, [ebp + 8]			; using EAX for storing string
    mov		ebx, [ebp + 12] 		; using EBX for storing pointer to i
    mov		ecx, [ebx] 				; using ECX for looping in string
    								; starting from i
    xor		esi, esi 				; using ESI for computing result


    cmp 	byte [eax + ecx], 40	; Case first character is a (
    je 		found_expression_factor ; meaning we found an expression

    cmp 	byte [eax + ecx], 40 	; Case first character is not a (
    jne 	search_number			; meaning we found a number



    ;;
    ;; CASE#1 - An expression is found
    ;;

found_expression_factor:
	xor		esi, esi 				; using ESI for counting brackets
	xor		edi, edi 				; using EDI for counting total number of
									; pushes on stack
	inc 	ecx 					; using ECX for looping in input string
	mov 	ebx, ecx 				; using EBX for copy for ECX
	push	0						; push 0 for NULL

	;; ____________________________
	;; find_close_bracket()
	;
	;  Idea: 1. Search for brackets until total counter of brackets
	;		 is -1. Once an opened bracket is found we increment
	;		 the counter and once a closed bracket is found
	;		 we decrement it. 
	;		 2. The position where the closed bracket is found
	;		 indicates the end of the expression

find_close_bracket:
	cmp 	byte [eax + ebx], 40	; found an opened bracket
	je 		found_opened_bracket

	cmp 	byte [eax + ebx], 41 	; found a closed bracket
	je 		found_closed_bracket
updated_brackets_counter:

	inc 	ebx 					; continue searching until the closed
	jmp		find_close_bracket 		; bracket is found

found_opened_bracket:
	inc 	esi 					; increment counter of brackets when opened
	jmp 	updated_brackets_counter; bracket is found	

found_closed_bracket:
	dec 	esi 					; decrement counter of brackets when closed
									; bracket is found
	cmp 	esi, -1 				; compare total counter with -1
	je 		break_string 			; if equal then start breaking string

	jmp 	updated_brackets_counter

	;; _________________
	;; break_string()
	;
	;	Idea:  Given the start index in string ECX and the end index of
	;	expression in EBX, this label is used for computing a new local
	;	string on stack. We copy the characters from the given string
	;	TLDR: 	If (expression) is found, make a new string on stack
	;			with expression and call specific function for the new string
	;
	; 	Steps: 	1. We push on stack 4 characters at a time.
	;				1.1 If the given expression's length is not
	;					multiple of 4 we push NULL characters
	; 			2. The new string obtained above will be
	;			   reversed. Therefore, we will then need a function
	;			   for reversing the string.


put_null_1:
	mov 	byte dl, 0			; copy NULL value on first character
	jmp 	ret_put_null_1

put_null_2:
	mov 	byte dl, 0			; copy NULL value on second character
	jmp 	ret_put_null_2

put_null_3:
	mov 	byte dh, 0 			; copy NULL value on third character
	jmp 	ret_put_null_3	

break_string:
	inc 	edi 				; using EDI for counting total pushes on stack
	xor 	edx, edx 			; using EDX for copying character on stack
								; using ECX for looping in the string
	inc 	ecx 				; second character in the group of 4
	cmp 	ecx, ebx 			; compare current position ECX with position of
								; closed bracket EBX
	jge 	put_null_1 			; if position > end_position copy NULL value
	mov 	dl, [eax + ecx]		; otherwise, copy character from string
ret_put_null_1:
	dec 	ecx 				; restore ECX


	mov		dh, [eax + ecx]		; copy first character in the group of 4
	shl		edx, 16 			; shift the first characters in first
								; half of register EAX


	add 	ecx, 3 				; fourth character in the group of 4
	cmp 	ecx, ebx 			; compare current position ECX with position of
	jge 	put_null_2 			; closed bracket EBX
	mov		dl, [eax + ecx] 	; if position > end_position copy NULL value
ret_put_null_2: 				; otherwise, copy character from string
	sub 	ecx, 3 				; restore ECX

	add 	ecx, 2 				; third character in the group of 4
	cmp 	ecx, ebx 			; compare current position ECX with position of
	jge 	put_null_3			; closed bracket EBX
	mov		dh, [eax + ecx]		; if position > end_position copy NULL value
ret_put_null_3:					; otherwise, copy character from string
	sub 	ecx, 2				; restore ECX


	push 	edx					; push the 4 characters simultaneously

	add 	ecx, 4 				; increment index with 4
	cmp 	ecx, ebx 			; compare current index with end index
	jge 	finish_breaking		; stop when reached a greater or equal value

	jmp		break_string


	;; __________________
	;; finish_breaking()
	;
	; Idea:  1. In order to obtain the final string we need to compute
	; 			the starting address of the new string.
	;		 2. We give EAX the start address of EBP
	;			and then compute [EBP - number_of_pushes_on_stack * 4]


finish_breaking:
	inc 	edi 			; increment counter of pushes

	push 	eax 			; compute in EDI number_of_pushes * 4
	mov 	eax, edi
	mov		dword ebx, 4
	mul 	ebx
	mov 	edi, eax
	pop		eax

	mov		esi, edi 		; using ESI as a copy for EDI
	sub 	esi, 4
	lea 	eax, [ebp] 		; give EAX the start address of EBP

substract_address:
	dec 	edi 			; compute in EAX the [EBP - 4 * nr_of_pushes]
	dec 	eax

	cmp 	edi, 0
	jne 	substract_address

	mov		edi, esi 		; restore value of EDI
	xor		ecx, ecx 		; using ECX for looping in string
	mov		esi, edi

	;; _________________
	;; reverse_string()
	;
	;	Idea: 1. We use ECX as a start index and ESI as an end index
	;				1.1 ECX starts from 0 and ESI from strlen(string)
	;		  2. We use DH as a copy of string[ECX] and BH as a copy of
	;			 string[ESI]. These 2 are used as auxiliars in step 3
	;		  3. Compute swap(string[ECX], string[ESI])
	;		  4. Repeat the process until the 2 positions are not equal
	;

reverse_string:
	xor		edx, edx
	xor		ebx, ebx

	mov		byte dh, [eax + ecx] 		; copy start character
	mov		byte bh, [eax + esi - 1] 	; copy end character

	mov 	byte [eax + esi - 1], dh 	; compute swap(first, second)
	mov		byte [eax + ecx], bh

	inc 	ecx
	dec 	esi

	cmp 	esi, ecx 					; compare start index and end index
	jne 	reverse_string 				; stop reverse when these are equal

	mov		ebx, [ebp + 12] 			; using EBX to restore pointer to i
	push 	edi 						; push EDI on stack
	mov		dword [ebx], 0 				; once a new string is created
	push	ebx 						; i will be 0
	push	eax 						; push new string
	call 	expression 					; call expression(new_string, 0)
	xor 	esi, esi 					; initialise result with 0
	mov 	esi, eax 					; copy the result of expression
	pop		eax 						; restore registers and
	pop		ebx 						; empty stack by removing
	pop		edi 						; memory of local new string
	add		esp, edi

	jmp		final_factor


	;;
	;; CASE#2 - A number is found
	;;

	;; _________________
	;; search_number()
	;
	; Idea: 1. Given the start index from the list of parameters in ECX, 
	; 		   we compute in ESI the resulted number by copying each
	;		   character from string EAX until we find a '+' '-' '/' '*'
	;		   sign or NULL.

search_number:
	jmp		create_number
continue:
	inc 	ecx

	cmp		byte [eax + ecx], 0 	; stop searching when reaching NULL
	je 		final_factor

	cmp 	byte [eax + ecx], 43	; stop searching when reaching '+'
	je 		final_factor

	cmp 	byte [eax + ecx], 45	; stop searching when reaching '-'
	je 		final_factor

	cmp 	byte [eax + ecx], 42	; stop searching when reaching '*'
	je 		final_factor

	cmp     byte [eax + ecx], 47	; stop searching when reaching '/'
	je 		final_factor

	jmp		search_number


create_number:
	push	eax 			; save EAX on stack
	xor		eax, eax 		; compute ESI = ESI * 10
	mov		eax, esi
	mov		edi, 10
	mul		edi
	mov		esi, eax
	pop		eax 			; restore EAX

	xor		edx, edx 		; using DL for storing current character
	mov		dl, [eax + ecx]
	
	add		esi, edx 		; add current character to result and
	sub		esi, 48			; substract ascii code for 0 to obtain
							; the equivalent integer from char

	jmp 	continue


final_factor:
	mov		eax, esi     	; put in EAX the result from ESI    
	xor		esi, esi 		; restore ESI
    leave
    ret






; `term(char *p, int *i)`
;       Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression

term:
    push    ebp
    mov     ebp, esp

    mov		eax, [ebp + 8]  		; using EAX for string
    mov		ebx, [ebp + 12] 		; using EBX for pointer to i
    mov		ecx, [ebx]				; using ECX for looping in string
									; starting from i
    mov 	edx, [ebx]				; using EDX for starting of a factor

    xor		esi, esi 				; using ESI for computing result
    xor 	edi, edi 				; using EDI for counting brackets


    ;; ______________________
    ;; search_for_factors()
    ;
    ; Idea: 1. Each time a character of '*', '/' is found we call the factor
    ;		   method for given string and current position.
    ;				1.1 (Example: a * (b + c) + ... calling factor for a)
    ; 		2. Each time we find a character of '+', '-' or NULL on the
    ;		   next position in string, we verify if a factor could be
    ;		   made.
    ;				2.1 (Example: a * (b + c) + ... calling factor for (b + c))
    ;		3. We stop searching for factors when '+', '-' or NULL occur
    ;		4. Each time a factor is found we 
    ;		


search_for_factors:
	cmp 	byte [eax + ecx], 40				; increment counter of
	je 		found_opened_parantheses			; brackets when ( is found

	cmp 	byte [eax + ecx], 41				; decrement counter of
	je 		found_closed_parantheses			; brackets when ) is found

updated_parantheses_counter:
	cmp 	byte [eax + ecx], 42				; check operation when * is
	je 		found_operation_2					; found

	cmp 	byte [eax + ecx], 47				; check operation when / is
	je 		found_operation_2					; found

	cmp 	byte [eax + ecx + 1], 0 			; check operation when NULL
	je 		found_operation_2					; is found

	cmp 	byte [eax + ecx + 1], 43 			; check operation when + is
	je 		found_operation_2					; found

	cmp 	byte [eax + ecx + 1], 45 			; check operation when - is
	je 		found_operation_2 					; found

checked_for_factor:

	inc 	ecx

	cmp 	byte [eax + ecx], 0 				; stop searching when NULL
	je 		check_final_factor					; is found

	cmp 	byte [eax + ecx], 43 				; stop searching when + is
	je 		check_final_factor					; found

	cmp 	byte [eax + ecx], 45				; stop searching when - is
	je 		check_final_factor					; found

	jmp 	search_for_factors



check_final_factor: 					; When the last character is found
	cmp 	edi, 0						; check if a factor can be computed
	je 		final_term	

	jmp 	search_for_factors

found_opened_parantheses:
	inc 	edi
	jmp		updated_parantheses_counter

found_closed_parantheses:
	dec 	edi
	jmp		updated_parantheses_counter


found_operation_2:
	cmp 	edi, 0				; found a valid factor only if total counter
	je		found_factor 		; of brackets is 0.
								; Example:   a * (c * b) -> c, d are not valid
								; 			 factors, rather (c * b) is one.

	cmp 	edi, 0 				; continue searching if counter is not 0
	jne 	checked_for_factor



	;; _______________
	;; found_factor()
	;
	; Idea: 1. Given the second argument of function, pointer to
	;		   current index in string, we use EBX for the initial position
	;		   in string.
	;		2. In EDX we keep track of the beggining of each factor
	;		   found.
	;			2.1  If EDX = EBX then we found the first factor and
	;				 store the result of factor call in ESI as it is
	;			2.2  If another factor is found then we call factor
	;				 function and decide what operation is applied, * or /
	;				 and update ESI result
	; 		3. Save values of registers on stack and call factor
	;		   function for the same string and position of beggining
	;		   of the found factor.


found_factor:
	cmp 	edx, [ebx] 				; if beggining of factor is equal
	je 		found_first_factor 		; to current position in string
									; we found the first factor.

	mov 	[ebx], edx 				; Otherwise, we call factor and
	push	edi 					; decide what operation must be applied
	push	esi 					; Save values of registers on stack
	push	edx
	push	ecx
	push 	ebx 					; call factor(string, new_position)
	push	eax
	call	factor
	mov 	ecx, [esp] 				; restore string
	mov 	edx, [esp + 12] 		; restore index in string
	mov 	esi, [esp + 16] 		; restore result
	jmp		update_result_factor 	; update result with the result of
updated_result_factor: 				; previous factor function call

	pop		eax 					; Restore registers and empty the
	pop		ebx 					; stack
	pop		ecx
	pop		edx
	add 	esp, 4
	pop		edi

	mov		edx, ecx
	inc 	edx

	jmp		checked_for_factor



update_result_factor:
	cmp 	byte [ecx + edx - 1], 42 		; if a '*' character is found
	je 		update_multiply 				; apply multiply on results

	cmp 	byte [ecx + edx - 1], 47		; if a '/' character is found
	je 		update_div 						; apply division on results




update_multiply:
	mov		ebx, eax 						; Compute ESI = ESI * EAX
	mov 	eax, esi 						; where EAX is result of previous
	mul 	ebx 							; factor function call
	mov		esi, eax
	jmp		updated_result_factor


update_div:
	xor 	edx, edx 						; Compute ESI = ESI / EAX
	mov		ebx, eax 						; where EAX is result of previous
	mov 	eax, esi 						; factor function call
	cmp 	eax, 0 							; If a negative number is found
	jl 		update_sign 					; then apply division on signed
ret_sign: 									; numbers
	idiv 	ebx
	mov		esi, eax
	jmp		updated_result_factor	

update_sign
	cdq
	jmp  	ret_sign

found_first_factor:
	push	edi 				; If the first factor is found then call
	push	ecx 				; factor function and initialise ESI result
	push	ebx 				; with result of factor function.
	push	eax 				; Save registers on stack
	call	factor
	mov		esi, eax 			; Update ESI result
	pop		eax 				; Restore registers
	pop		ebx
	pop		ecx
	pop		edi

	mov		edx, ecx
	inc 	edx

	jmp 	checked_for_factor 	; Continue checking for factors in string


final_term:    
		mov		eax, esi
		xor		esi, esi    
        leave
        ret



; `expression(char *p, int *i)`
;       Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression

expression:
    push    ebp
    mov     ebp, esp

    mov		eax, [ebp + 8]		; using EAX for string
    mov		ebx, [ebp + 12] 	; using EBX for pointer to i
    mov		ecx, [ebx] 			; using ECX for looping in string starting
    							; from position i
    mov		edx, [ebx] 			; using EDX for starting point of a term
    xor		edi, edi 			; using EDI for counting the total paratheses
    xor		esi, esi 			; using ESI for computing result of current
    							; expression

	;; _________________
	;; search_for_terms()
	;
	; Idea: 1. Given the start index from the list of parameters in ECX,
	; 		   we compute in ESI the result of current expression
	;		2. Using EDI for counting total number of brackets. If an
	;		   opened bracket is found then we increase the counter
	;		   and if a closed one occurs we decrement it.
	;		   		2.1  A term is valid when the counter is equal to 0
	;					 Example:   (a + b) + c --> a and b are not
	;								considered proper terms, rather
	;								(a + b) is one
	;		3. When a + or - sign occurs, we check total number
	;		   of brackets and if it is equal to 0 then call
	;		   the term function with the given string and the 
	;		   updated value for i. 

search_for_terms:

	cmp		byte [eax + ecx], 40		; Increment counter of brackets when
	je 		count_opened_parantheses	; an opened one occurs

	cmp		byte [eax + ecx], 41		; Decrement counter of brackets when
	je 		count_closed_parantheses	; a closed one occurs
updated_counter_paranteses:	

	cmp		byte [eax + ecx], 43		; Check if a term is found when +
	je 		found_operation 			; character occurs

	cmp		byte [eax + ecx], 45		; Check if a term is found when -
	je 		found_operation 			; character is found

	cmp 	byte [eax + ecx + 1], 0 	; Check if a term is found before
	je 		found_operation				; the end of the string

updated_term:

	inc 	ecx
		
	cmp 	byte [eax + ecx], 0			; Stop searching for terms when
	je 		final 						; reached the end of the given string

	jmp		search_for_terms

count_opened_parantheses:
	inc 	edi
	jmp		updated_counter_paranteses

count_closed_parantheses:
	dec 	edi
	jmp		updated_counter_paranteses


found_operation:

	cmp 	edi, 0 					; A term is considered to be valid if
	je 		found_term 				; the counter of brackets is 0
									; See previous examples
	cmp 	edi, 0
	jne 	updated_term


	;; ___________________
	;; found_term()
	;
	; 	Steps: 	1. In EDX we keep track of the beggining of each term.
	;			2. Update the value of the second argument address to
	;			   the beggining of the new term and call the function
	;			   for term(string, new_position) 
	;			3. When the call for term function is over, we restore
	;			   the registers and update the ESI result depending on
	;			   the character before the term.
	;			Example:     ..... + (a * c) - ...
	;						We call the term function for (a * c), get
	;						the result in EAX and then check the previous
	;						character (in this case, +) to decide the
	;						proper operation that needs to be applied  


found_term:
	mov		[ebx], edx 				; Update position in string with the
									; position of the beggining of the term
	push	edx 					; Save on stack the values of registers
	push	edi
	push	esi
	push 	ecx
	push	ebx 					; Push second argument, position in string
	push	eax 					; Push first argument, the given string
	call 	term 					; Call term(string, position_of_term)
	mov		edx, [esp] 				; Restore the string
	mov		ecx, [esp + 20] 		; Restore position of term
	mov		esi, [esp + 12] 		; Restore result

	jmp	 	update_result_expression
updated_result_expression:

	pop		eax 					; Restore registers and
	pop		ebx 					; empty the stack
	pop		ecx
	add 	esp, 4
	pop		edi
	pop		edx

	mov		edx, ecx
	inc 	edx
	jmp		updated_term

update_result_expression:
	dec		ecx 				; When the result of a term call is stored in
 								; EAX check what operation needs to be applied,
 								; depending on the previous character before
 								; the found term, - or +
	cmp 	ecx, 0				; If there is no previous character, meaning
	jl		update_sum  		; we found the first term, apply by default sum

	cmp 	byte [edx + ecx], 43 	; If a + sign is found, apply sum
	je 		update_sum

	cmp 	byte [edx + ecx], 45 	; If a - sign is found, apply diff
	je 		update_diff

update_sum:
	add 	esi, eax
	jmp 	updated_result_expression

update_diff:
	sub		esi, eax
	jmp 	updated_result_expression



final:
	mov		eax, esi 		; Store in EAX the final result
    leave
    ret
