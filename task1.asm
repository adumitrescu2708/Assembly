; @name: Dumitrescu Alexandra
; @group: 323 CA

section .text
	global sort


; struct node {
;     	int val;
;    	struct node* next;
; };

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list


sort:
	enter 	0, 0

	mov 	ecx, [ebp + 12]		 ; using ECX for storing head of nodes
	xor		esi, esi			 ; using ESI for looping in array


	mov 	eax, esi 			 ; using EAX for storing the position
								 ; of the minimum value in array

	inc 	esi 				 ; start searching for minimum from position 1


	;; ________________________
	;;   find_min_all_nodes()
	;
	;	Usage: 	Search for the minimum in the array
	;	Steps: 	1. In EAX we store the position of the minimum in the array.
	;			   Therefore, this position is initialised with 0.
	;			2. In ESI we keep the current position in the array.
	;				2.1 As minimum is first considered to be on position
	;					0, ESI will start from 1.
	;			3. Each step we compare the value of EAX-th node with ESI-th
	;			   node. If a new minimum is found then the EAX value is
	;			   updated.
	;

find_min_all_nodes:
	mov		edi, [ecx + eax * 8] 		; value of current minimum
	mov		edx, [ecx + esi * 8] 		; value of current node

	cmp		edi, edx 			 		; if current node has a lower value
	jg 		found_new_min_all_nodes		; then update the minimum
updated_min_all_nodes:
	inc 	esi

	cmp 	esi, [ebp + 8] 				; compare current position with the
	jl 		find_min_all_nodes			; number of nodes in array

	cmp		esi, [ebp + 8] 				; stop searching when the end of
	jge		save_min_all_nodes			; array is reached


found_new_min_all_nodes:
	mov		eax, esi 					; update the position of the minimum
	jmp 	updated_min_all_nodes



save_min_all_nodes:

	push 	eax 				; save the minimum's position on stack
	xor		esi, esi 			; using ESI for looping in array

	mov		eax, esi 			; using EAX for storing the maximum
								; value in array

	inc 	esi 				; start searching for maximum 
								; from position 1


	;; _______________________
	;;   find_max_all_nodes()
	;
	;	 Usage:	 Search for the maximum in the array
	;	 Steps:  The algorithm is similar to the one stated above
	;    

find_max_all_nodes:
	mov		edi, [ecx + eax * 8] 		; value of current maximum
	mov		edx, [ecx + esi * 8]		; value of current node

	cmp		edi, edx 					; if current node has a lower value
	jl 		found_new_max_all_nodes		; then update the maximum
updated_max_all_nodes:
	inc 	esi

	cmp 	esi, [ebp + 8] 				; compare the current position with the
	jl 		find_max_all_nodes			; number of nodes in array

	cmp		esi, [ebp + 8]				; stop searching when the end of
	jge		save_max_all_nodes			; array is reached


found_new_max_all_nodes:
	mov		eax, esi 					; update the position of the maximum
	jmp 	updated_max_all_nodes


save_max_all_nodes:

	push	eax 		; saving the maximum's position on stack
	xor		esi, esi 	; using ESI for looping in array

	;; ________________
	;;   sort_nodes()
	;
	;	Usage:
	;	Given the array of nodes, this label is used for taking each element
	; 	in the array, finding its next in the sorted list and update its next
	; 	field.
	;
	;	Steps: 	1. use ESI for taking each node in array
	; 			2. use EDI for looping in array for each node when
	; 			searching for its next node in the sorted list
	; 			3. find the minimum value greater than the ESI-th node's value
	;				3.1 There is no need for searching for the next node
	;					of the maximum-valued node. Its next should remain
	;					NULL. Therefor, we skip step 3 for maximum.
	;			4. update the next field of the ESI-th node in vector with
	;			   the address of 
	;
	;	pseudocode: 	for(each node1 : array) {
	;						for(each node2 : array) {
	;							// find the node having a greater value than
	;							// node1 value but the minimum one
	;
	;							if(node2 > node1 && node2 < minimum)
	;								next_node = node2 && minimum = node2
	;						}
	;					}


sort_nodes:
	xor		edi, edi 		; use EDI for looping in array

	pop		eax 			; use EAX for storing maximum's position in array
	push	eax 			; save back on stack the position

	cmp		esi, eax 		; if the current position is the maximum's position
	je 		skip			; then skip

	jmp		find_min_value 	; otherwise, search for the position in array 
found_min_value: 			; of the next-node to ESI-th node
	

	lea 	edx, [ecx + 8 * eax] 		; store the address of the next node
	mov		[ecx + 8 * esi + 4], edx 	; update the next value of ESI-th
										; element in array

skip:

	inc 	esi

	mov		eax, [ebp + 8]
	sub		eax, 1

	cmp 	esi, eax 			; compare current position with number of nodes
	jle		sort_nodes			; in array

	cmp		esi, eax 			; stop searching when reaching the end of array
	jg		final


	;; __________________
	;;   find_min_value()
	;
	;    Given in ESI the current position in the array, this label 
	; is used for finding the next node's position in the array.
	; 	 Example: If ESI = 2 and 2nd node's value is 3, then this
	; label will store in EAX the position of the node which has
	; the minimum value greater than the current's one (specifically, the node
	; having the value 3)
	;

find_min_value:
	mov		edx, [ecx + 8 * edi] 		; using EDX for value of potentially
										; next node
	mov		ebx, [ecx + 8 * esi] 		; using EBX for value of current node

	cmp		edx, ebx					; if a greater value is found then update
	jg		update_min 					; minimum
updated_next_min:

	inc 	edi

	cmp		edi, [ebp + 8] 				; compare the current position with
	jl		find_min_value 				; the number of nodes in the array

	cmp		edi, [ebp + 8] 				; stop searching when the end of
	jge		found_min_value 			; the array is reached

update_min:
	mov		ebx, [ecx + 8 * eax] 		; using EBX for storing the maximum val

	cmp		edx, ebx 					; if EDX is lower than EBX update result
	jl		found_new_min

	jmp		updated_next_min

found_new_min:
	mov		eax, edi 					; using EAX for storing the position in
	jmp		updated_next_min 			; array of the next node


final:
	pop		ebx 					; restore stack
	pop		eax
	lea 	eax, [ecx + eax * 8] 	; put in EAX the address of head


	leave
	ret
