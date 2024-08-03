TITLE Project 4     (Proj4_majorsal.asm)

; Author: Allison Majors
; Last Modified: 7/25/2024
; OSU email address: majorsal@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  4               Due Date: 07/28/2024
; Description: This program first displays the programmer's name, the program title,
;			   the overview of the game, and extra credit implementations. The user 
;			   is then asked to enter a number [1...4000]. The program validates that 
;			   the user input is within this range and will reprompt the user if the 
;			   number entered is invalid. The program will display the amount of prime 
;			   numbers (in ascending order) equivalent to the number entered by the user
;			   with 10 primes per row and 20 rows per page. Then a goodbye message is 
;			   displayed.

INCLUDE Irvine32.inc

; (insert macro definitions here)

UPPERBOUND	=	4000
LOWERBOUND	=	1

.data

programmerName			BYTE	"	Allison Majors ", 0
programTitle			BYTE	"Project4 - Prime Number Game with Validation", 0
instructions			BYTE	"Enter a number [1...4000], and I will show you that amount",
								" of prime numbers.", 0
inputPrompt				BYTE	"How many prime numbers would you like to display? Enter ",
								"[1...4000]: ", 0
invalidNumMessage		BYTE	"The number you entered is out of range. Try again.", 0
inputNum				SDWORD	?
primeCheck				DWORD	?
validateResult			DWORD	?
singleSpace				BYTE	" ", 0
testingNumber			DWORD	?
counter					DWORD   ?
numPrimesDisplayed		DWORD	0
goodbyeMessage			BYTE	"Thanks for playing, goodbye!", 0

; for extra credit:
exCredOption1		    BYTE	"**EC: Output columns aligned by first digit.", 0
exCredOption2			BYTE	"**EC: Program displays up to 4000 primes, with only",
								" 20 rows per page.", 0
numSpaces				DWORD	?
rowCheck				DWORD	200						; helps check only 20 rows on a page


.code
main PROC

call	introduction
call	getUserData
call	showPrimes
call	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP



; -------------------------------------------------------------------
; Name: introduction
;
; Introduces the programmer name, program title, and game description.
; Also displays extra credit implementations.
;
; Preconditions: instructions is a string that explains the game, 
;				programmerName is a string with the programmer's name,
;				programTitle is a string with the title of the program,
;				exCredOption1 and exCredOption2 are strings explaining 
;				extra credit.
;
; Postconditions: none
;
; Receives: global variables instructions, programmerName, programTitle,
;			exCredOption1, and exCredOption2
;
; Returns: none
; -------------------------------------------------------------------
introduction PROC
	push	EDX

	; display programmer name and program title
	mov		EDX, OFFSET programmerName
	call	WriteString
	mov		EDX, OFFSET programTitle
	call	WriteString
	call	CrLf

	; describe the game to the user
	mov		EDX, OFFSET instructions
	call	WriteString
	call	CrLf

	; display extra credit
	call	CrLf
	mov		EDX, OFFSET exCredOption1
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET exCredOption2
	call	WriteString
	call	CrLf
	call	CrLf

	pop		EDX
	RET
introduction ENDP



; -------------------------------------------------------------------
; Name: getUserData
;
; Prompts the user to enter an integer [1...4000] and stores result in
; global variable inputNum. Calls "validate" proc to determine if 
; integer is within range or not.
; 
; Preconditions: inputPrompt is a string asking the user to enter a number, 
;				 inputNum exists
;
; Postconditions: none
;
; Receives: global variables inputPrompt and validateResult
;
; Returns: user input value for global variable inputNum
; -------------------------------------------------------------------
getUserData PROC
	push	EAX
	push	EDX

	; prompt the user to enter a number within [1...4000]
_promptUserForNum:
	mov		EDX, OFFSET inputPrompt
	call	WriteString
	call	ReadInt
	mov		inputNum, EAX

	; validate that the number is within [1...4000]
	call	validate
	cmp		validateResult, 1
	je		_isValid
	jmp		_promptUserForNum					; get new number input

_isValid:
	pop		EDX
	pop		EAX
	RET
getUserData ENDP



; -------------------------------------------------------------------
; Name: validate
;
; Validates that the integer entered by the user is within the range
; [1...4000].
;
; Preconditions: inputNum has the input integer stored, constant
;				LOWERBOUND stores 1 and UPPERBOUND stores 4000,
;			    validateResult exists
;
; Postconditions: none
;
; Receives: user input value in global variable inputNum, lower limit in
;			constant LOWERBOUND, and upper limit in constant UPPERBOUND
;
; Returns: 1 in global variable validateResult if number is valid or 0 if 
;          number is invalid
; -------------------------------------------------------------------
validate PROC
	push	EDX

	; check that the number is >= 1
	cmp		inputNum, LOWERBOUND
	jl		_invalidNumber

	; check that the number is <= 4000
	cmp		inputNum, UPPERBOUND
	jg		_invalidNumber

	; number is valid, store 1 in validateResult
	mov		validateResult, 1
	jmp		_finished					

	; store 0 in validateResult and display invalid number message
_invalidNumber:
	mov		validateResult, 0
	mov		EDX, OFFSET invalidNumMessage
	call	WriteString
	call	CrLf

_finished:
	pop		EDX
	RET
validate ENDP



; -------------------------------------------------------------------
; Name: showPrimes
;
; Displays the amount of prime numbers that the user wanted to see 
; (based off of inputNum). Calls "isPrime" proc to determine if
; a number is prime or not.
;
; Preconditions: inputNum stores amount of prime numbers to display,
;				rowCheck stores amount of primes to display per page,
;				singleSpace stores a space character,
;				testingNumber and numPrimesDisplayed exist
;
; Postconditions: none
;
; Receives: inputNum, primeCheck, rowCheck, singleSpace as global variables
;
; Returns: none
; -------------------------------------------------------------------
showPrimes PROC
	push	ECX
	push	EBX
	push	EDX
	push	EAX

	; initialize counter/display 2 before starting the loop
	mov		ECX, inputNum
	mov		testingNumber, 2
	jmp		_displaySinglePrime

	; display "inputNum" amount of primes, call isPrime to check a num
_displayPrimeNumsLoop:
	call	isPrime
	cmp		primeCheck, 1
	je		_yesPrime

	; not prime - test next number
	inc		ECX							; need ecx to stay same value if num not prime
	jmp		_restart

	; Only display 10 primes per line.
	; Divide numPrimesDisplayed by 10 to see if we have displayed 10 primes already.
_yesPrime:
	mov		EAX, numPrimesDisplayed
	mov		EDX, 0
	mov		EBX, 10
	div		EBX
	cmp		EDX, 0
	jne		_displaySinglePrime
	call	CrLf						; move to next line if 10 numbers have displayed

	; (**EC): only display 20 rows per page.
	; Divide numPrimesDisplayed by 200 to see if we have displayed 200 
	; primes (20 rows) already.
	mov		EAX, numPrimesDisplayed
	mov		EDX, 0
	div		rowCheck
	cmp		EDX, 0
	jne		_displaySinglePrime
	call	WaitMsg						; 20 rows exist, wait for user to press a key
	call	CrLf

	; print prime number to the screen
_displaySinglePrime:
	mov		EAX, testingNumber
	call	WriteDec

	; (**EC): find number of spaces necessary to keep columns aligned
	call	determineAmountOfSpaces
	mov		EBX, numSpaces
	mov		EDX, OFFSET singleSpace
	inc		numPrimesDisplayed

	; (**EC): print the variable number of spaces 
_printSpaces:
	cmp		EBX, 0
	je		_restart					; stop printing spaces when EBX=0
	call	WriteString
	dec		EBX
	jmp		_printSpaces

	; see if the next number is prime
_restart:
	inc		testingNumber
	LOOP	_displayPrimeNumsLoop

	pop		EAX
	pop		EDX
	pop		EBX
	pop		ECX
	RET
showPrimes ENDP



; -------------------------------------------------------------------
; Name: isPrime
;
; Determines whether or not a given number is prime.
;
; Preconditions: testingNumber stores the number to be tested,
;				counter and primeCheck exist
;
; Postconditions: none
;
; Receives: testingNumber is a global variable
;
; Returns: 1 in global variable primeCheck if number is prime or 0 if 
;          number is not prime
; -------------------------------------------------------------------
isPrime PROC
	push	ECX
	push	EAX
	push	EDX
	push	EBX

	; initialize counter (ECX) to be testingNumber-1
	mov		EAX, testingNumber
	mov		counter, EAX
	dec		counter
	mov		ECX, counter		

	; Divide testingNumber by testingNumber-1 till 2.
	; If the remainder is 0, then we know the number is
	; not prime.
_isPrimeLoop:
	mov		EAX, testingNumber
	mov		EDX, 0
	mov		EBX, ECX
	div		EBX							

	; If remainder is 0, number is not prime
	cmp		EDX, 0						
	je		_return0	

	; stop when divisor reaches 2, otherwise loop again
	cmp		ECX, 2
	je		_return1					; loop over, all divisors tested, number is prime
	LOOP	_isPrimeLoop				; test next divisor

	; Number is not prime, return 0 in primeCheck
_return0:
	mov		primeCheck, 0
	jmp		_done

	; Number is prime, return 1 in primeCheck
_return1:
	mov		primeCheck, 1

_done:
	pop		EBX
	pop		EDX
	pop		EAX
	pop		ECX
	RET
isPrime ENDP



; -------------------------------------------------------------------
; Name: determineAmountOfSpaces (**EC)
;
; Determines based off of the testingNumber how many spaces should be
; printed to the screen. 
;
; Preconditions: testingNumber stores the prime, numSpaces exists
;
; Postconditions: none
;
; Receives: testingNumber is a global variable
;
; Returns: numSpaces is a global variable with the number of spaces 
; needed to be printed
; -------------------------------------------------------------------
determineAmountOfSpaces PROC
	push	EAX

	; Based on the number of digits the the prime number has, find the
	; correct number of spaces the number must be printed alongside
	; in order to make sure all columns stay aligned.
	mov		EAX, testingNumber	
	cmp		EAX, 10
	jl		_sevenSpaces
	cmp		EAX, 100
	jl		_sixSpaces
	cmp		EAX, 1000
	jl		_fiveSpaces
	cmp		EAX, 10000
	jl		_fourSpaces
	jmp		_threeSpaces

_sevenSpaces:
	mov		numSpaces, 7
	jmp		_done
	
_sixSpaces:
	mov		numSpaces, 6
	jmp		_done

_fiveSpaces:
	mov		numSpaces, 5
	jmp		_done

_fourSpaces:
	mov		numSpaces, 4
	jmp		_done

_threeSpaces:
	mov		numSpaces, 3

_done:
	pop		EAX
	RET
determineAmountOfSpaces ENDP



; -------------------------------------------------------------------
; Name: farewell
;
; Say goodbye to the user.
;
; Preconditions: goodbyeMessage is a global variable string
;
; Postconditions: none
;
; Receives: global variable goodbyeMessage
;
; Returns: none
; -------------------------------------------------------------------
farewell PROC
	push	EDX

	; display a goobye message to the user
	call	CrLf
	call	CrLf
	mov		EDX, OFFSET goodbyeMessage
	call	WriteString

	pop		EDX
	RET
farewell ENDP


END main
