// @name: Dumitrescu Alexandra
// @group: 323 CA

/*
 * Don't forget to include "positions.h"
 */

#include "positions.h"

.section .text
.global add_vect

/* 
 * void add_vect(int *v1, int *v2, int n, int *v)
 *
 * add v1 and v2, that have both the length n, and store the result in v3.
 * also, substract from v3 the values provided in positions.S, as described
 * in the task
 */

add_vect:
	pushl 	%ebp
	movl	%esp, %ebp

	movl 	8(%ebp), %eax		// using EAX for storing v1
	movl	12(%ebp), %ebx		// using EBX for storing v2
	movl	20(%ebp), %edx		// using EDX for storing v

	movl	$0, %esi			   // using ESI for looping in v1, v2, v
sum:
	movl	(%eax, %esi, 4), %edi  // Use EDI for storing v1[ESI]
	movl	(%ebx, %esi, 4), %ecx  // Use ECX for storing v2[ESI]

	add 	%edi, %ecx 			   // Compute sum of v1[ESI] + v2[ESI]

	movl	%ecx, (%edx, %esi, 4)  // Put the sum in v[ESI]

	inc 	%esi 				   // Increment loop index in arrays
	cmp		16(%ebp), %esi 		   // Stop looping when end of array is
	jle		sum  				   // reached

	// As the scale factor in position.h is computed for
	// an array of 10 then we check if the number of elements in given
	// array (ECX) is greater than 10, case in which we divide the
	// total number by 10 and otherwise we divide 10 by total number.

compute_correct_scale:
	movl	16(%ebp), %ecx 		// Compare total number of elements with 10

	cmp 	$10, %ecx 			// If total number is lower than 10 then
	jle 	lower_than_10 		// scale = 10 / number_of_elements

	cmp 	$10, %ecx 			// If total number is greater than 10 then
	jg		higher_than_10 		// scale = number_of_elements / 10

lower_than_10:
	movl	$0, %edx 			// Compute scale = 10 / number_of_elements
	movl	$10, %eax
	idiv	%ecx
	movl	%eax, %ecx
	jmp scale_positions_divide

higher_than_10: 				// Compute scale = number_of_elements / 10
	movl	$0, %edx
	movl	%ecx, %eax
	movl	$10, %ebx
	idiv	%ebx
	movl	%eax, %ecx
	jmp scale_positions_mul


	// Once the scale factor is computed we have 2 cases.
	// Case 1.   Arrays length is lower than 10 then the scale
	// 			 factor is 10 / number_of_elements and we divide
	//			 the given position with this scale
	// Case2.    Arrays length is higher than 10 then the scale
	// 			 factor is number_of_elements / 10 and we multiply
	// 			 the given positions with this scale

scale_positions_divide:

	movl	$FIRST_POSITION, %eax 		// Use EAX for storing FIRST_POSITION
	movl	$0, %edx 					// Initialise EDX with 0
	idiv	%ecx 						// Scale FIRST_POSITION (divide it
	movl	20(%ebp), %edx 				// with the scale)
	movl	(%edx, %eax, 4), %ebx 		// Use EBX for v[SCALED_POSITION]
	movl	$FIRST_VALUE, %esi 			// Use ESI for storing FIRST_VALUE
	sub 	%esi, %ebx 					// v[SCALED_POSITION] = 
	movl    %ebx, (%edx, %eax, 4)		// v[SCALED_POSITION] - FIRST_VALUE


	movl	$SECOND_POSITION, %eax 		// Use EAX for storing SECOND_POSITION
	movl	$0, %edx 					// Initialise EDX with 0
	idiv	%ecx 						// Scale SECOND_POSITION (divide it
	movl	20(%ebp), %edx 				// with the scale)
	movl	(%edx, %eax, 4), %ebx 		// Use EBX for v[SCALED_POSITION]
	movl	$SECOND_VALUE, %esi 		// Use ESI for storing SECOND_VALUE
	sub 	%esi, %ebx 					// v[SCALED_POSITION] =
	movl    %ebx, (%edx, %eax, 4) 		// v[SCALED_POSITION] - SECOND_VALUE

	movl	$THIRD_POSITION, %eax 		// Apply same algorithm stated above
	movl	$0, %edx  					// for THIRD_POSITION and THIRD_VALUE
	idiv	%ecx
	movl	20(%ebp), %edx
	movl	(%edx, %eax, 4), %ebx
	movl	$THIRD_VALUE, %esi
	sub 	%esi, %ebx
	movl    %ebx, (%edx, %eax, 4)

	jmp final


scale_positions_mul:

	movl	$FIRST_POSITION, %eax 	// Use EAX for storing FIRST_POSITION
	movl	$0, %edx 				// Initialise EDX with 0
	imul	%ecx 					// Scale FIRST_POSITION (multiply it
	movl	20(%ebp), %edx 			// with the scale)
	movl	(%edx, %eax, 4), %ebx 	// Use EBX for v[SCALED_POSITION]
	movl	$FIRST_VALUE, %esi 		// Use ESI for storing FIRST_VALUE
	sub 	%esi, %ebx 				// v[SCALED_POSITION] = 
	movl    %ebx, (%edx, %eax, 4)	// v[SCALED_POSITION] - FIRST_VALUE


	movl	$SECOND_POSITION, %eax  // Apply same algorithm stated above
	movl	$0, %edx 				// for SECOND_POSITION and SECOND_VALUE
	imul	%ecx
	movl	20(%ebp), %edx
	movl	(%edx, %eax, 4), %ebx
	movl	$SECOND_VALUE, %esi
	sub 	%esi, %ebx
	movl    %ebx, (%edx, %eax, 4)

	movl	$THIRD_POSITION, %eax 	// Apply same algorithm stated above
	movl	$0, %edx 				// for THIRD_POSITION and THIRD_VALUE
	imul	%ecx
	movl	20(%ebp), %edx
	movl	(%edx, %eax, 4), %ebx
	movl	$THIRD_VALUE, %esi
	sub 	%esi, %ebx
	movl    %ebx, (%edx, %eax, 4)

	jmp final

final:

	leave
	ret
