TITLE Project 3    (Proj3_majorsal.asm)

; Author: Allison Majors
; Last Modified: 07/19/2024
; Description:	This program first displays the programmer's name, the program title, and overview of
;				the game to be played. The game works by the user being repeatedly asked to enter a 
;				negative number. If the number entered is not within the range [-200,-100] or [-50,-1], 
;				then the program prompts the user to enter a valid number. The game stops when the user
;				enters a non-negative number. The total count, sum, average, minimum, and maximum of all
;				the valid numbers will be displayed. Lastly, a goodbye message is displayed. For extra 
;				credit, this program also numbers the lines of valid numbers entered and calculates
;				and displays the average of valid numbers rounded to the nearest .01.

INCLUDE Irvine32.inc


LIMIT1   	=	-200
LIMIT2  	=	-100
LIMIT3  	=	-50
LIMIT4		=   -1

.data

programmerName			BYTE	"	Allison Majors ", 0
programTitle			BYTE	"Project3 - Negative Number Accumulator Game with Validation", 0
userName				BYTE	21 DUP(0)
userNamePrompt			BYTE    "Please enter your name: ", 0 
userGreeting			BYTE	"Welcome ", 0
gameDescription 		BYTE	"In this game, I will repeatedly ask you to enter a negative number. ",
								"If the number you enter is not within the range [-200,-100] or ", 
								"[-50,-1], then I will prompt you to enter a valid number. I will ",
								"accumulate your valid numbers, only stopping the game when ", 
								"you enter a non-negative number. I will display to you the count, ",
								"sum, maximum, minimum, and average of all valid numbers entered.", 0
gameInstructions		BYTE	"Please enter numbers within the range [-200, -100] or the range [-50, -1] ",
								"(Enter a non-negative number when done playing)", 0
enterNumberPrompt		BYTE	". Enter a number: ", 0
numberPromptCount		DWORD	1
userNumber				SDWORD	?
invalidNumberMessage	BYTE	"That number is invalid, try again.", 0
validNumsCount			DWORD	?
validNumsCountMessage	BYTE	"The number of valid numbers you entered is: ", 0
maxNum					SDWORD	-201
maxNumMessage			BYTE	"The maximum valid number you entered is: ", 0
minNum					SDWORD	0
minNumMessage			BYTE	"The minimum valid number you entered is: ", 0
sum						SDWORD	0
sumMessage				BYTE	"The sum of the valid numbers you entered is: ", 0
average					SDWORD	?
remainder				SDWORD	?
averageMessage			BYTE	"The rounded average of the valid numbers you entered is: ", 0
noValidNumsMessage		BYTE	"You did not enter any valid numbers.", 0
goodbyeMessage			BYTE	"Thanks for playing, see ya later ", 0
exCredOption1		    BYTE	"**EC: User input lines are numbered, only incrementing for ", 
								"valid numbers.", 0
exCredOption2		    BYTE	"**EC: Program calculates and displays the average as a ",
								"decimal-point number, rounded to the nearest .01", 0
averageExCred			SDWORD	?
tenthPlace				SDWORD	?
hundrethPlace			SDWORD  ?
thousandthPlace			SDWORD	?
exCredRoundedDisplay	BYTE	"The average rounded to the nearest .01 is: ", 0
decimalPoint			BYTE	".", 0


.code
main PROC

	; -----------------------------------------------------------
	; INTRODUCTION: display programmer name, program title, 
	; the overview of the game, and extra credit implementations
	; -----------------------------------------------------------
	; display programmer name and program title
	mov		EDX, OFFSET programmerName
	call	WriteString
	mov		EDX, OFFSET programTitle
	call	WriteString
	call	CrLf

	; describe the game to the user
	mov		EDX, OFFSET gameDescription
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


	; -----------------------------------------------------------
	; INTRODUCTION: Get the user's name and greet the user
	; -----------------------------------------------------------
	; get the user's name as input
	mov		EDX, OFFSET userNamePrompt		
	call	WriteString
	mov		EDX, OFFSET userName
	mov		ECX, SIZEOF userName - 1
	call	ReadString

	; greet the user
	mov		EDX, OFFSET userGreeting
	call	WriteString
	mov		EDX, OFFSET userName
	call	WriteString
	call	CrLf
	call	CrLf


	; -----------------------------------------------------------
	; GAME INPUT: Display instructions for the user and repeatedly prompt the user 
	; to enter a number within [-200, -100] or [-50,-1].
	; **EC: number the lines during user input, only incrementing
	; when a valid number is entered.
	; -----------------------------------------------------------
	; display instructions
	mov		EDX, OFFSET gameInstructions
	call	WriteString
	call	CrLf

_beginGame:
	; prompt the user to enter a number within [-200, -100] or [-50,-1]
	mov		EAX, numberPromptCount
	call	WriteDec
	mov		EDX, OFFSET enterNumberPrompt
	call	WriteString
	call	ReadInt
	mov		userNumber, EAX


	; -----------------------------------------------------------
	; GAME VALIDATION: Check that the input number is negative and
	; is in the defined ranges
	; -----------------------------------------------------------
	; if input is non-negative, then end the game
	cmp		userNumber, 0
	jns		_finished						; check sign flag

	; check if input is < -200, display message if invalid
	cmp		userNumber, LIMIT1
	jl		_invalidNumber

	; Check if input is > -100.
	; If yes, then need to also check if it is in [-50, -1].
	; If no, then consider it a valid number.
	cmp		userNumber, LIMIT2
	jg		_checkLessThanNeg50
	jmp		_validNumber

	; Check if input is < -50.
	; No need to check if input is > -1 because the other limits
	; have been checked and an input of 0 or greater will end the program.
_checkLessThanNeg50:
	cmp		userNumber, LIMIT3
	jge		_validNumber

_invalidNumber:
	; Display a message to the user saying the
	; number they entered is invalid. Then restart the game.
	mov		EDX, OFFSET invalidNumberMessage
	call	WriteString
	call	CrLf
	jmp		_beginGame						; restart game


	; -----------------------------------------------------------
	; GAME CALCULATIONS: Add the valid number to the total count and 
	; sum of all valid numbers thus far. Additionally, check if the 
	; current number is a new maximum or new minimum.
	; -----------------------------------------------------------
_validNumber:
	; Add 1 to the count of valid numbers and (**EC) the count of 
	; valid numbers for numbering the input lines.
	inc		validNumsCount	
	inc		numberPromptCount

	; add the valid number to the running sum
	mov		EAX, userNumber
	mov		EBX, sum
	add		EAX, EBX
	mov		sum, EAX

_checkMax:
	; check for a new max
	mov		EAX, userNumber
	cmp		EAX, maxNum
	jg		_newMax
	jmp		_checkMin

_newMax:
	; store the input number as the new max
	mov		EAX, userNumber
	mov		maxNum, EAX

_checkMin:
	; check for a new min
	mov		EAX, userNumber
	cmp		EAX, minNum
	jl		_newMin
	jmp		_beginGame						; restart game 

_newMin:
	; store the input number as the new min
	mov		EAX, userNumber
	mov		minNum, EAX

	jmp		_beginGame						; restart game


	; -----------------------------------------------------------
	; GAME FINISHED/AVERAGE CALCULATIONS: If no valid numbers were entered, 
	; skip to the end of the program and inform the user. Otherwise, 
	; calculate the average of valid numbers thus far.
	; **EC: calculate the average rounded to the nearest .01.
	; -----------------------------------------------------------
_finished:
	; if no valid numbers were entered, jump to _noValidNums
	mov		EAX, validNumsCount
	cmp		EAX, 0
	je		_noValidNums

	; calculate the average
	mov		EAX, sum
	mov		EBX, validNumsCount
	cdq
	idiv	EBX
	mov		average, EAX

	; round the average up if needed
	mov		remainder, EDX
	neg		remainder
	mov		EAX, remainder
	mov		EBX, 2
	imul	EBX								; multiply remainder by 2
	cmp		EAX, validNumsCount				; compare remainder with divisor
	jbe		_exCredAverage
	dec		average							; round up

_exCredAverage:
	; **EC - rounding to the nearest .01
	; calculate the average (just the whole number value)
	mov		EAX, sum
	mov		EBX, validNumsCount
	cdq
	idiv	EBX
	mov		averageExCred, EAX

	; calculate the first decimal point (tenths place)
	mov		tenthPlace, EDX					; store remainder
	neg		tenthPlace
	mov		EAX, tenthPlace
	mov		EBX, 10
	imul	EBX								; multiply first remainder by 10
	mov		EBX, validNumsCount
	cdq
	idiv	EBX								; divide tenthPlace*10 by validNumsCount
	mov		tenthPlace, EAX					; store tenths place 

	; calculate the second decimal point (hundreths place)
	mov		hundrethPlace, EDX				; remainder of previous division 
	mov		EAX, hundrethPlace
	mov		EBX, 10
	imul	EBX								
	mov		EBX, validNumsCount
	cdq
	idiv	EBX								; divide hundrethPlace*10 by validNumsCount
	mov		hundrethPlace, EAX				; store hundreths place

	; Use the third decimal point (thousandths place) to 
	; determine if the hundreths place needs to be rounded up.
	mov		thousandthPlace, EDX			; remainder of previous division
	mov		EAX, thousandthPlace
	mov		EBX, 2
	imul	EBX
	cmp		EAX, validNumsCount				; compare final remainder with divisor
	jbe		_displayResults
	inc		hundrethPlace					; round up hundrethPlace


	; -----------------------------------------------------------
	; OUTPUT RESULTS: Display the count, sum, maximum (closest to 0),
	; minimum (farthest from 0), and average of valid numbers
	; entered. If no valid numbers were entered, then tell the user
	; as such.
	; **EC: display the average rounded to the nearest .01.
	; -----------------------------------------------------------
_displayResults:
	; display the count of valid numbers
	mov		EDX, OFFSET validNumsCountMessage
	call	WriteString
	mov		EAX, validNumsCount
	call	WriteDec
	call	CrLf

	; display the sum of valid numbers
	mov		EDX, OFFSET sumMessage
	call	WriteString
	mov		EAX, sum
	call	WriteInt
	call	CrLf

	; display the maximum valid number
	mov		EDX, OFFSET maxNumMessage
	call	WriteString
	mov		EAX, maxNum
	call	WriteInt
	call	CrLf

	; display the minimum valid number
	mov		EDX, OFFSET minNumMessage
	call	WriteString
	mov		EAX, minNum
	call	WriteInt
	call	CrLf

	; display the average of all valid numbers
	mov		EDX, OFFSET averageMessage
	call	WriteString
	mov		EAX, average
	call	WriteInt
	call	CrLf

	; **EC - display average rounded to the nearest .01
	mov		EDX, OFFSET exCredRoundedDisplay
	call	WriteString
	mov		EAX, averageExCred
	call	WriteInt
	mov		EDX, OFFSET decimalPoint
	call	WriteString
	mov		EAX, tenthPlace
	call	WriteDec
	mov		EAX, hundrethPlace
	call	WriteDec
	call	CrLf
	jmp		_goodbye

_noValidNums:
	; tell the user that no valid numbers were entered
	mov		EDX, OFFSET noValidNumsMessage
	call	WriteString
	call	CrLf


	; -----------------------------------------------------------
	; GOODBYE: Display a goodbye message to the user.
	; -----------------------------------------------------------
_goodbye:
	; display goodbye message
	call	CrLf
	mov		EDX, OFFSET goodbyeMessage
	call	WriteString
	mov		EDX, OFFSET userName
	call	WriteString




	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
