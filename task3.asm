; @name: Dumitrescu Alexandra
; @group: 323 CA

section .data
	delimitors: db ' ', '.', ',', 0x0A, 0 ; characters used as delimiters

global get_words
global compare_func
global sort

section .text
	extern strtok
	extern strcpy
	extern strlen
	extern strcmp
	extern qsort

;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix

sort:
    enter 0, 0

    ;; _______
    ;; sort()
    ;
    ;  Calling the qsort function having the following format:
    ; 		qsort(char **words, int number_of_words, int size, int comparator)
    ;
    ;  We implemented a compare function that firstly compares the length of
    ;  the given strings and if equal, sorts alphabetic

	push 	string_compare 			; sending compare function
	push 	dword [ebp + 16] 		; sending size
	push 	dword [ebp + 12] 		; sending number of words
	push	dword [ebp + 8] 		; sending pointer to words array
	call 	qsort 					; calling qsort
	add 	esp, 16 				; restore string
	jmp 	final_sort 				; final


	;;____________________
	;; string_compare()
	;
	;	Usage:  This function is given 2 strings and returns a positive
	;			value if the first string should be the first in 
	;			array when sorting and an negative integer, otherwise
	;	Idea:   The compare function has the following format:
	; 							int compare(void *a, void *b)
	; 		    In out case, qsort will send pointer pointer to char
	;	Steps: 1. Call strlen for the given strings.
	;		   2. Compare the 2 lengths
	;				2.1 If the first string is longer send a positive value
	;				2.2 If the second string is longer send a negative value
	;				2.3 If the strings are equally long call strcmp and send
	;				its result
	;

string_compare:	
	enter 	0, 0

	mov 	eax, [ebp + 8]		; get the pointer to first string
	mov 	eax, [eax]			; using EAX for storing the first string

	push 	eax 				; push first argument - first string 	
	call 	strlen			    ; call strlen(first_string)
	add 	esp, 4 				; restore stack		
	mov 	ebx, eax			; using EBX for storing length of first string


	mov 	eax, [ebp + 12] 	; get the pointer to second string
	mov 	eax, [eax]  		; using EAX for storing second string

	push 	ebx 				; saving the first string's length
	push 	eax 				; push first argument - second string
	call 	strlen				; call strlen(second_string)
	add 	esp, 4				; restore stack
	pop 	ebx					; restore length of first string in EBX

	cmp 	ebx, eax			; compare lengths
	jg 		first_string_result	; if first string is longer send positive answ

	cmp 	ebx, eax 			; compare lengths
	jl 		second_string_result; if second string is longer send negative answ

	cmp 	ebx, eax 			; compare lengths
	je 		equal_length_result ; if strings are equally long,
								; sort alphabetically


equal_length_result:
	mov 	eax, [ebp + 8]		; get the pointer to first string
	mov 	eax, [eax]			; using EAX for restoring the first string

	mov 	ebx, [ebp + 12]		; get the pointer to second string
	mov 	ebx, [ebx]			; using EBX for restoring the second string

	push 	ebx 				; push second argument - second string
	push 	eax 				; push first argument - first string
	call 	strcmp 				; call strcmp(first_string, second_string)
	add 	esp, 8				; restore stack, result will be stored in EAX
	jmp 	result

first_string_result:
	mov 	eax, 1				; sending a positive integer as result
	jmp 	result

second_string_result:
	mov 	eax, -1				; sending a negative integer as result
	jmp 	result

result:
	leave
	ret




final_sort:
    leave
    ret




;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte

	;; ____________
	;; get_words()
	;
	;	Steps:
	;	1. Compute strtok(EBX, delimiters) and then copy the result
	; 	in words[0], using strcpy.
	;
	;	2. Represented by break_string label. This loop is used for
	;	setting the next words_count - 1 words in the words array following
	;	the same algorithm explained above. Instead of calling
	;	strtok(EBX, delimiters), calling strtok(NULL, delimiters).

get_words:
    enter 	0, 0

    mov 	edi, [ebp + 16] 	; using EDI for storing number of words
    mov 	esi, [ebp + 12] 	; using ESI for storing pointer to words array
	mov 	ebx, [ebp + 8]  	; using EBX for storing string
	xor 	ecx, ecx 			; using ECX for looping in words array


	push 	delimitors 			; push second argument - delimitors characters
	push 	ebx 				; push first argument  - string
	call 	strtok 				; calling strtok(string, delimiters)
	add 	esp, 8				; empty the stack

	mov 	esi, [ebp + 12] 	; restore pointer to words array
	xor		ecx, ecx 			; restore counter for looping in words array
	mov 	edi, [esi + ecx]	; get the address for storing the first wors

	push 	eax 				; push second argument, source - result strtok
	push 	edi 				; push first argument, destination
	call 	strcpy				; calling strcpy(words[ECX], first_word)
	add 	esp, 8				; restore stack

	mov		edi, [ebp + 16] 	; restore number of words

	mov 	ecx, 1 				; increment index



break_string:

	push 	ecx 				; saving the current index on stack
	push 	delimitors			; push second argument - delimitors
	push 	0 					; push first argument  - null
	call 	strtok 				; calling strtok(NULL, delimiters)
	add 	esp, 8 				; restore stack
	pop 	ecx 				; restore current index
	mov 	edi, [esi + 4 * ecx]; using EDI for a address of words[ECX]

	push 	ecx 				; saving the current index
	push 	eax 				; push source      - result of strtok
	push 	edi 				; push destination - words[ECX]
	call 	strcpy 				; calling strcpy(words[ECX], word)
	add 	esp, 8				; restore stack
	pop 	ecx 				; restore current index

	inc 	ecx

	cmp 	ecx, [ebp + 16] 	; compare current index with number
	jl 		break_string		; of words

	cmp 	ecx, [ebp + 16] 	; stop breaking string when reaching
	jge 	final 				; the end of words array

final:

    leave
    ret
