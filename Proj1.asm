TITLE Project 1     (Proj1_majorsal.asm)

; Author: Allison Majors
; Last Modified: 07/10/2024
; Description: This program displays my name and the program title on the output screen and
;				prompts the user to enter three numbers (A, B, C). The program verifies that
;				these numbers are in strictly descending order. The sums and differences 
;				(A+B, A-B, A+C, A-C, B+C, B-C, A+B+C) are calculated for these input numbers 
;				and displayed to the user. Additionally, this program handles negative results
;				and calculates and displays B-A, C-A, C-B, and C-B-A as well as A/B, A/C, and 
;				B/C. The program will repeat until the user chooses to quit, at which point
;				a goodbye message will display.

INCLUDE Irvine32.inc

.data

	userName			BYTE	"	Allison Majors ", 0
	programTitle		BYTE	"Project1-Basic Logic and Arithmetic Program", 0
	prompt1				BYTE	"Enter 3 numbers (A, B, C) in strictly descending order, ",
								"and I will give you their sums and differences.", 0
	promptA				BYTE	"Enter the first number: ", 0
	promptB				BYTE	"Enter the second number: ", 0
	promptC				BYTE	"Enter the third number: ", 0
	numA				SDWORD	?
	numB				SDWORD  ?
	numC				SDWORD	?
	aPlusB				SDWORD	?
	aMinusB				SDWORD	?
	aPlusC				SDWORD	?
	aMinusC				SDWORD	?
	bPlusC				SDWORD	?
	bMinusC				SDWORD	?
	aPlusBPlusC			SDWORD	?
	plusSign			BYTE	" + ", 0
	minusSign			BYTE	" - ", 0
	equalsSign			BYTE	" = ", 0
	goodbye				BYTE	"Thanks for playing, see ya!", 0

	; the following pertain to the extra credit
	bMinusA				SDWORD	?
	cMinusA				SDWORD	?
	cMinusB				SDWORD	?
	cMinusBMinusA		SDWORD	?
	divisionSign		BYTE	" / ", 0
	remainderPrompt		BYTE	"     remainder: ", 0
	aDivB				SDWORD	?
	aDivBRemainder		SDWORD	?
	aDivC				SDWORD	?
	aDivCRemainder		SDWORD	?
	bDivC				SDWORD	?
	bDivCRemainder		SDWORD	?
	continueMessage		BYTE	"Enter 1 to play again or 0 to quit: ", 0
	userAnswer			DWORD	?
	invalidNumPrompt	BYTE	"Oops, the numbers must be in descending order!", 0
	exCredOption1		BYTE	"**EC: Program repeats until the user chooses to quit.", 0
	exCredOption2		BYTE	"**EC: Program checks that the numbers are in descending order.", 0
	exCredOption3		BYTE	"**EC: Program handles negative results and computes/displays ",
								"B-A, C-A, C-B, and C-B-A.", 0
	exCredOption4		BYTE	"**EC: Program calculates and displays the quotients ",
								"and remainders of A/B, A/C, and B/C.", 0


.code
main PROC
	
	; -----------------------------------------------------------
	; INTRODUCTION: (display name and program title)
	; Also display extra credit implementations.
	; -----------------------------------------------------------
	mov		EDX, OFFSET userName
	call	WriteString
	mov		EDX, OFFSET programTitle
	call	WriteString
	call	CrLf

	; display extra credit implementations
	mov		EDX, OFFSET exCredOption1
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET exCredOption2
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET exCredOption3
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET exCredOption4
	call	WriteString
	call	CrLf


	; -----------------------------------------------------------
	; USER INPUT: Ask user for 3 numbers (A,B,C) in strictly descending order,
	; and store this data in the identifiers numA, numB, numC.
	; **EC: verify numbers are in descending order (display message if invalid).
	; -----------------------------------------------------------
_beginGame:
	; display instructions
	call	CrLf
	mov		EDX, OFFSET prompt1					
	call	WriteString
	call	CrLf

	; get & store A
	mov		EDX, OFFSET promptA					
	call	WriteString
	call	ReadInt
	mov		numA, EAX

	; get & store B
	mov		EDX, OFFSET promptB					
	call	WriteString
	call	ReadInt
	mov		numB, EAX

	; check that B<A
	mov		EAX, numA							
	cmp		EAX, numB
	jle		_invalidNum

	; get & store C
	mov		EDX, OFFSET promptC					
	call	WriteString
	call	ReadInt
	call	CrLf
	mov		numC, EAX

	; check that C<B
	mov		EAX, numB							
	cmp		EAX, numC
	jle		_invalidNum


	; -----------------------------------------------------------
	; CALCULATIONS: Calculate the sums and differences, being
	; A+B, A-B, A+C, A-C, B+C, B-C, and A+B+C.
	; -----------------------------------------------------------
	; calculate A+B
	mov		EAX, numA							
	mov		EBX, numB
	add		EAX, EBX
	mov		aPlusB, EAX			

	; calculate A-B
	mov		EAX, numA							
	mov		EBX, numB
	sub		EAX, EBX
	mov		aMinusB, EAX			
	
	; calculate A+C
	mov		EAX, numA							
	mov		EBX, numC
	add		EAX, EBX
	mov		aPlusC, EAX	

	; calculate A-C
	mov		EAX, numA							
	mov		EBX, numC
	sub		EAX, EBX
	mov		aMinusC, EAX	

	; calculate B+C
	mov		EAX, numB							
	mov		EBX, numC
	add		EAX, EBX
	mov		bPlusC, EAX		

	; calculate B-C
	mov		EAX, numB							
	mov		EBX, numC
	sub		EAX, EBX
	mov		bMinusC, EAX	

	; calculate A+B+C
	mov		EAX, numA							
	mov		EBX, numB
	add		EAX, EBX
	mov		EBX, numC
	add		EAX, EBX
	mov		aPlusBPlusC, EAX


	; -----------------------------------------------------------
	; **EC: CALCULATIONS: calculate B-A, C-A, C-B, C-B-A
	; -----------------------------------------------------------
	; calculate B-A
	mov		EAX, numB							
	mov		EBX, numA
	sub		EAX, EBX
	mov		bMinusA, EAX			

	; calculate C-A
	mov		EAX, numC							
	mov		EBX, numA
	sub		EAX, EBX
	mov		cMinusA, EAX			
	
	; calculate C-B
	mov		EAX, numC							
	mov		EBX, numB
	sub		EAX, EBX
	mov		cMinusB, EAX	

	; calculate C-B-A
	mov		EAX, numC							
	mov		EBX, numB
	sub		EAX, EBX
	mov		EBX, numA
	sub		EAX, EBX
	mov		cMinusBMinusA, EAX


	; -----------------------------------------------------------
	; **EC: CALCULATIONS: calculate A/B, A/C, B/C, storing both the 
	; quotient and remainder.
	; -----------------------------------------------------------
	; calculate A/B
	mov		EAX, numA	
	mov		EBX, numB
	cdq
	idiv	EBX
	mov		aDivB, EAX
	mov		aDivBRemainder, EDX

	; calculate A/C
	mov		EAX, numA
	mov		EBX, numC
	cdq
	idiv	EBX
	mov		aDivC, EAX
	mov		aDivCRemainder, EDX

	; calculate B/C
	mov		EAX, numB	
	mov		EBX, numC
	cdq
	idiv	EBX
	mov		bDivC, EAX
	mov		bDivCRemainder, EDX

	
	; -----------------------------------------------------------
	; OUTPUT RESULTS: Display the results of A+B, A-B, A+C, A-C, B+C, 
	; B-C, A+B+C as an equation.
	; -----------------------------------------------------------
	; display A+B
	mov		EAX, numA							
	call	WriteInt
	mov		EDX, OFFSET plusSign
	call	WriteString
	mov		EAX, numB
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, aPlusB
	call	WriteInt
	call	CrLf

	; display A-B 
	mov		EAX, numA							
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numB
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, aMinusB
	call	WriteInt
	call	CrLf

	; display A+C
	mov		EAX, numA							 
	call	WriteInt
	mov		EDX, OFFSET plusSign
	call	WriteString
	mov		EAX, numC
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, aPlusC
	call	WriteInt
	call	CrLf

	; display A-C
	mov		EAX, numA							 
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numC
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, aMinusC
	call	WriteInt
	call	CrLf

	; display B+C
	mov		EAX, numB							 
	call	WriteInt
	mov		EDX, OFFSET plusSign
	call	WriteString
	mov		EAX, numC
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, bPlusC
	call	WriteInt
	call	CrLf

	; display B-C 
	mov		EAX, numB							
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numC
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, bMinusC
	call	WriteInt
	call	CrLf

	; display A+B+C 
	mov		EAX, numA							
	call	WriteInt
	mov		EDX, OFFSET plusSign
	call	WriteString
	mov		EAX, numB
	call	WriteInt
	mov		EDX, OFFSET plusSign
	call	WriteString
	mov		EAX, numC
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, aPlusBPlusC
	call	WriteInt
	call	CrLf


	; -----------------------------------------------------------
	; **EC: OUTPUT RESULTS: Display the results of B-A, C-A, C-B, 
	; C-B-A as an equation.
	; -----------------------------------------------------------
	; display B-A 
	mov		EAX, numB							
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numA
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, bMinusA
	call	WriteInt
	call	CrLf

	; display C-A 
	mov		EAX, numC						
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numA
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, cMinusA
	call	WriteInt
	call	CrLf

	; display C-B 
	mov		EAX, numC						
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numB
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, cMinusB
	call	WriteInt
	call	CrLf

	; display C-B-A 
	mov		EAX, numC							
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numB
	call	WriteInt
	mov		EDX, OFFSET minusSign
	call	WriteString
	mov		EAX, numA
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, cMinusBMinusA
	call	WriteInt
	call	CrLf


	; -----------------------------------------------------------
	; **EC: OUTPUT RESULTS: display A/B, A/C, B/C with their remainders.
	; -----------------------------------------------------------
	; display A/B quotient and remainder
	mov		EAX, numA							
	call	WriteInt
	mov		EDX, OFFSET divisionSign
	call	WriteString
	mov		EAX, numB
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, aDivB
	call	WriteInt
	call	CrLf
	mov		EDX, OFFSET remainderPrompt
	call	WriteString
	mov		EAX, aDivBRemainder
	call	WriteInt
	call	CrLf

	; display A/C quotient and remainder
	mov		EAX, numA							
	call	WriteInt
	mov		EDX, OFFSET divisionSign
	call	WriteString
	mov		EAX, numC
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, aDivC
	call	WriteInt
	call	CrLf
	mov		EDX, OFFSET remainderPrompt
	call	WriteString
	mov		EAX, aDivCRemainder
	call	WriteInt
	call	CrLf

	; display B/C quotient and remainder
	mov		EAX, numB							
	call	WriteInt
	mov		EDX, OFFSET divisionSign
	call	WriteString
	mov		EAX, numC
	call	WriteInt
	mov		EDX, OFFSET equalsSign
	call	WriteString
	mov		EAX, bDivC
	call	WriteInt
	call	CrLf
	mov		EDX, OFFSET remainderPrompt
	call	WriteString
	mov		EAX, bDivCRemainder
	call	WriteInt
	call	CrLf


	; -----------------------------------------------------------
	; **EC: Ask the user if they want to keep playing or quit.
	; If they want to quit, continue to goodbye message.
	; -----------------------------------------------------------
	call	CrLf
	mov		EDX, OFFSET continueMessage
	call	WriteString
	call	ReadDec
	mov		userAnswer, EAX
	cmp		userAnswer, 1
	je		_beginGame							; restart game
	call	_goodbye							; display goodbye message


	; -----------------------------------------------------------
	; **EC: Tell the user the numbers must be in descending order.
	; Then go back to the beginning of the game.
	; -----------------------------------------------------------
_invalidNum:
	mov		EDX, OFFSET invalidNumPrompt
	call	WriteString
	call	CrLf
	call	_beginGame							; restart game


	; -----------------------------------------------------------
	; GOODBYE: Display a goodbye message to the user.
	; -----------------------------------------------------------
_goodbye:
	call	CrLf
	mov		EDX, OFFSET goodbye
	call	WriteString
	call	CrLf


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
