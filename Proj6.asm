TITLE Project 6     (Proj6_majorsal.asm)

; Author: Allison Majors
; Last Modified: 8/14/2024
; Description: This program prompts the user to enter 10 signed integers.
;			  Each user input is read as a string of ASCII digits and is
;			  converted to a SDWORD (using the mGetString macro and readVal
;			  procedure). The user input is also validated to
;			  make sure that they enter a signed number and that the number
;			  is not too large to fit inside a 32-bit register. The 10
;			  SDWORDs are stored in an array, and are converted to their
;		      ASCII string digit representation to be displayed to the screen
;			  using the mDisplayString macro and WriteVal procedure. The
;			  sum and average of the 10 SDWORDs are also displayed. For extra
;			  credit, the user input lines are numbered and a running subtotal
;			  is displayed.

INCLUDE Irvine32.inc

; -------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user to enter a number and reads this value as a string,
; storing the result in userString.
;
; Preconditions: prompt is a string telling the user what to do, 
;				MAXINPUT contains the maximum size the user can
;				enter, userString and numBytesRead addresses are passed in
;
; Postconditions: none
;
; Receives: prompt = string address,
;			MAXINPUT = max size user can enter,
;			userString = string address,
;			numBytesRead = int address,
;			linesCount = number of current input line,
;			period = string address
;
; Returns: userString contains number entered by user, numBytesRead
;		   contains the size of userString
; -------------------------------------------------------------------
mGetString MACRO prompt:REQ, userString:REQ, numBytesRead:REQ, linesCount:REQ, period:REQ
	push	EDX
	push	ECX
	push	EAX

	;**EC: number each line of user input
	push	linesCount
	call	WriteVal
	mov		EDX, period
	call	WriteString

	; prompt user to enter a number
	mov		EDX, prompt
	call	WriteString

	; get input from user and store in userString
	mov		EDX, userString
	mov		ECX, MAXINPUT
	call	ReadString
	mov		[numBytesRead], EAX

	pop		EAX
	pop		ECX
	pop		EDX
ENDM




; -------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a string stored in a specific memory location to the screen.
;
; Preconditions: userString contains string to be printed
;
; Postconditions: none
;
; Receives: userString = string address
;
; Returns: none
; -------------------------------------------------------------------
mDisplayString MACRO userString:REQ
	push	EDX

	; display the string
	mov		EDX, userString
	call	WriteString

	pop		EDX
ENDM




MAXINPUT	=	100
ARRAYSIZE	=	10

.data

programmerName			BYTE	"	Allison Majors ", 0
programTitle			BYTE	"Project6 - Low-level ReadInt and WriteInt implementations", 0
instructions			BYTE	"For this program, you will enter 10 signed integers, and I will ",
								"display the numbers entered as well as their sum and average. The ",
								"numbers must be able to fit inside a 32-bit register.", 0
validIntegersArray		SDWORD	ARRAYSIZE DUP(?)
intPrompt				BYTE	"Enter a signed integer: ", 0
errorMsg				BYTE	"That is either not a signed number or it is too big. Try again.", 0
userString				BYTE	MAXINPUT DUP(?)
userStringLength		DWORD	?
convertedNum			SDWORD  ?
sum						SDWORD	0
sumMsg					BYTE	"The sum of all the valid numbers you entered is: ", 0
subTotalMsg				BYTE	"The running subtotal is: ", 0
displayMsg				BYTE	"The valid numbers you entered are: ", 0
avgMsg					BYTE	"The average of all the valid numbers you entered, truncated to its ",
								"integer value, is: ", 0
comma					BYTE	", ", 0
period					BYTE	". ", 0
exCredOption1		    BYTE	"**EC: User input lines are numbered, only incrementing for ", 
								"valid numbers. Also, a running subtotal for valid numbers is displayed.", 0
linesCount				DWORD	1

.code
main PROC

	; display programmer name, title, and instructions
	push	OFFSET exCredOption1
	push	OFFSET programmerName
	push	OFFSET programTitle
	push	OFFSET instructions
	call	introduction
	
	;-----------------------------------------------
	; Get 10 valid integers from the user. Use a loop
	; and call ReadVal to get the user input 10 times.
	; **EC: input lines are numbered using linesCount
	; and running subtotal is displayed.
	;-----------------------------------------------
	mov				ECX, ARRAYSIZE
	mov				EDI, OFFSET validIntegersArray
_ReadValLoop:
	push			OFFSET linesCount
	push			OFFSET period
	push			OFFSET convertedNum
	push			OFFSET errorMsg
	push			OFFSET intPrompt
	push			OFFSET userString
	push			OFFSET userStringLength
	call			ReadVal
	mov				EBX, convertedNum
	mov				[EDI], EBX				; store the SDWORD in validIntegersArray
	add				EDI, 4

	; **EC: calculate the running subtotal of valid ints thus far
	push			OFFSET linesCount
	push			OFFSET sum
	push			OFFSET validIntegersArray
	call			sumVals

	; **EC: display the running subtotal
	mDisplayString	OFFSET subTotalMsg
	push			sum
	call			WriteVal	
	call			CrLf
	mov				sum, 0

	LOOP			_ReadValLoop
	call			CrLf

	;-----------------------------------------------
	; Display the 10 integers by looping 10 times and
	; calling WriteVal.
	;-----------------------------------------------
	mDisplayString	OFFSET displayMsg		; inform user what is to be displayed
	call			CrLf

	; setup loop
	mov				ESI, OFFSET validIntegersArray
	mov				ECX, ARRAYSIZE
_displayLoop:
	push			[ESI]					; pass SDWORD to WriteVal
	call			WriteVal
	cmp				ECX, 1		
	jne				_printComma
	call			CrLf
	add				ESI, 4
	LOOP			_displayLoop
	jmp				_sum
_printComma:
	mDisplayString	OFFSET comma
	add				ESI, 4
	LOOP			_displayLoop

	;------------------------------------------------
	; Calculate and display the sum of values in validIntegersArray.
	;------------------------------------------------
_sum:
	mDisplayString	OFFSET sumMsg			; display sum msg
	push			OFFSET linesCount
	push			OFFSET sum
	push			OFFSET validIntegersArray
	call			sumVals
	push			sum
	call			WriteVal
	call			CrLf

	;------------------------------------------------
	; Calculate and display the average of values in 
	; validIntegersArray.
	;------------------------------------------------
	mov				EAX, sum
	mov				EBX, ARRAYSIZE
	cdq
	idiv			EBX

	; print average message
	mDisplayString	OFFSET avgMsg

	; display the average
	push			EAX
	call			WriteVal	


	Invoke ExitProcess,0	; exit to operating system
main ENDP




; -------------------------------------------------------------------
; Name: ReadVal
;
; Invokes the mGetString macro to get a number entered by the user in 
; the form of a string. This string is then converted from ASCII digits
; to its integer value (SDWORD). The user's input is validated to make
; sure that only a signed number was entered and nothing else. Additionally,
; the user can't have entered a number too large to fit into a 32-bit
; register. The converted SDWORD gets stored in the global variable convertedNum.
; **EC: The input lines are numbered, only incrementing for valid entries.
;
; Preconditions: convertedNum, userString, and userStringLength exist, 
;				errorMsg is a string containing an error message, intPrompt 
;				is a string prompting the user what to enter, period is a
;				string containing the period symbol followed by a space,
;				linesCount contains the number of valid integers entered
;				thus far
;
; Postconditions: none
;
; Receives: [ebp+32] = reference to linesCount
;			[ebp+28] = reference to period
;			[ebp+24] = reference to convertedNum
;			[ebp+20] = reference to errorMsg
;			[ebp+16] = reference to intPrompt
;			[ebp+12] = reference to userString
;			[ebp+8]	 = reference to userStringLength
;
; Returns: convertedNum contains the converted SDWORD, linesCount contains
;		   the current input line number
; -------------------------------------------------------------------
ReadVal PROC
	LOCAL			sign:SDWORD					; 1=positive number, -1=negative number
	LOCAL			curTotal:DWORD				; tracks converted ascii to dec number
	LOCAL			validLines:DWORD			; counts number of valid numbers for lines
	push			ECX
	push			EAX
	push			EBX
	push			ESI
	push			EDX
	push			EDI
	pushfd

	; **EC: update validLines with the current number of valid input for line labeling
	mov				EAX, [EBP+32]
	mov				EAX, [EAX]
	mov				validLines, EAX

	; get user input in the form of a string of digits with mGetString
	mov				ESI, [EBP+28]				; address of period in ESI
	mov				ECX, [EBP+16]				; address of intPrompt in ECX
	mov				EAX, [EBP+12]				; address of userString in EAX
	mov				EBX, [EBP+8]				; address of userStringLength in EBX
	mGetString		ECX, EAX, EBX, validLines, ESI

	; check for empty input using userStringLength
_emptyCheck:
	mov				EBX, [EBX]					; userStringLength value in EBX
	cmp				EBX, 0
	je				_invalid

	; check for too large a num using userStringLength
	mov				AL, [EAX]					; first char of userString in EDX
	cmp				AL, 45
	je				_tooLargeSignedCheck
	cmp				AL, 43
	je				_tooLargeSignedCheck
	cmp				EBX, 10						; pos num (no sign) is too large
	jg				_invalid
	jmp				_setupConvertNumLoop

	; check if a signed num is too large for a 32-bit register
_tooLargeSignedCheck:
	cmp				EBX, 11
	jg				_invalid

	; ----------------------------------------------------------
	; The following section will convert the userString into an SDWORD
	; (note that the conversion is done using unsigned math and the
	; final result will become signed only at the very end).
	; First, the first character is checked to see if it is '+' or '-'.
	; If it is '-', then we set local var sign=-1.
	; Then, we check every ASCII character to be in the range of
	; 48 to 57. If so, we subtract 48 from the character and then
	; add this value to 10*curTotal, where curTotal is the value
	; received after each of these calculations. After looping through
	; each ASCII character, curTotal should contain the DWORD value.
	; This value is validated to make sure it fits inside a 32-bit
	; register. If valid, we then convert it to a signed integer if
	; the number is supposed to be negative.
	; ----------------------------------------------------------
_setupConvertNumLoop:
	mov				EAX, [EBP+12]				
	mov				ESI, EAX					; put address of userString into ESI
	mov				EBX, [EBP+8]
	mov				ECX, [EBX]					; put userStringLength value into ECX
	mov				curTotal, 0
	mov				sign, 1
	CLD	
	LODSB

	; check first char to see if '+' or '-'
	cmp				AL, 43
	je				_loopAgain					; skip to next ascii char
	cmp				AL, 45
	je				_firstCharNegSign
	jmp				_convertNumLoop

	; the entered number is negative
_firstCharNegSign:
	mov				sign, -1
	jmp				_loopAgain

	; Loop through each ascii char.
	; Check that the ascii char is in the range 48-57. If yes, then
	; convert to integer. If not, print error message and get a new
	; number from the user.
_convertNumLoop:
	cmp				AL, 48
	jb				_invalid
	cmp				AL, 57
	ja				_invalid

	; character is valid- convert to num it represents
	sub				AL, 48			
	movzx			EBX, AL						; store in EBX char-48 
	mov				EAX, 10
	mul				curTotal					; multiply 10 by curTotal
	add				EAX, EBX					; 10*curTotal + (char-48)
	mov				curTotal, EAX				; save new current total (will become the SDWORD)
_loopAgain:
	LODSB
	LOOP			_convertNumLoop

	; validate the number fits inside a 32-bit register
	mov				EAX, curTotal
	cmp				sign, -1
	je				_validateNegNum
	cmp				EAX, 2147483647				; pos num can't be > 2147483647
	ja				_invalid
	jmp				_storeFinalResult

_validateNegNum:
	cmp				EAX, 2147483648				; neg num can't be < -2147483648
	ja				_invalid

	; store curTotal in convertedNum and update linesCount
_storeFinalResult:
	imul			sign						; make the SDWORD negative if it should be
	mov				ECX, [EBP+24]				; address of convertedNum in ECX
	mov				[ECX], EAX
	inc				validLines		
	mov				EAX, validLines
	mov				EBX, [EBP+32]
	mov				[EBX], EAX					; linesCount contains current numbered line
	jmp				_done

	; user entered invalid num- print errorMsg and get new num
_invalid:
	mov				EDX, [EBP+20]
	call			WriteString
	call			CrLf
	mov				ESI, [EBP+28]				
	mov				ECX, [EBP+16]
	mov				EAX, [EBP+12]
	mov				EBX, [EBP+8]
	mGetString		ECX, EAX, EBX, validLines, ESI 
	jmp				_emptyCheck
	
_done:
	popfd
	pop				EDI
	pop				EDX
	pop				ESI
	pop				EBX
	pop				EAX
	pop				ECX
	RET				28
ReadVal ENDP




; -------------------------------------------------------------------
; Name: WriteVal
;
; Given an SDWORD (passed by value), this procedure first converts it to
; a string of ASCII digits. Then, the mDisplayString macro is invoked to 
; display this string of ASCII digits. 
;
; Preconditions: the passed-by-value SDWORD contains a signed integer
;
; Postconditions: none
;
; Receives: [ebp+8] = value of given SDWORD
;
; Returns: none
; -------------------------------------------------------------------
WriteVal PROC
	LOCAL			sign:DWORD						; 1=positive number, -1=negative number
	LOCAL			tempArray[MAXINPUT+1]:BYTE		; store converted nums
	LOCAL			finalResult[MAXINPUT+1]:BYTE	; stores final string (reversed tempArray)
	LOCAL			count:DWORD						; counts num chars in the sdword
	push			EDI
	push			EAX
	push			EBX
	push			EDX
	push			ECX
	push			ESI

	lea				EDI, tempArray					; load address of tempArray into edi
	mov				count, 0

	; Add a null character to the tempArray so that we don't print more than the
	; actual finalResult itself (null char will be at the end of finalResult do to reversal)
	mov				AL, 0
	STOSB
	inc				count

	; If the SDWORD = 0, store '48' in tempArray and jump straight to array reversal.
	mov				EAX, [EBP+8]					; SDWORD in EAX
	cmp				EAX, 0
	jne				_negCheck
	mov				AL, 48
	STOSB
	inc				count
	jmp				_reverseArray

	; Check for negative num
_negCheck:
	mov				EAX, [EBP+8]					; SDWORD in EAX
	cmp				EAX, 0
	jl				_signed
	mov				sign, 1
	CLD
	jmp				_convertToAsciiLoop

	; SDWORD is negative, convert to 2s complement.
	; Also check if SDWORD = -2147483648. Due to the
	; fact that this number can't be negated, we will
	; have to manually store 2147483648 in EAX. The 
	; number will still display as negative, as we will
	; append a negative sign to the Ascii string after the
	; conversion.
_signed:
	cmp				EAX, -2147483648
	je				_specialMinCase
	neg				EAX		
	mov				sign, -1
	CLD
	jmp				_convertToAsciiLoop

_specialMinCase:
	mov				EAX, 2147483648
	mov				sign, -1
	CLD
	
	; ----------------------------------------------------------
	; The following section will convert the SDWORD into a string of
	; ASCII digits. We start by dividing the SDWORD by 10, then adding
	; 48 to the remainder to get the correct ASCII digit. This digit is
	; stored in tempArray. We repeat this process again, using the 
	; previous quotient as the starting dividend. We stop looping when
	; the starting dividend is equal to 0. The local variable 'count'
	; will keep track of the length of the string. At the end of the loop, 
	; tempArray should store the ASCII digits in their reversed order 
	; (in addition to the null character that was put inside tempArray 
	; earlier). If the SDWORD was negative, we store '45' at the end
	; of tempArray. Then, we reverse tempArray so that the string is
	; in the correct order for printing and invoke mDisplayString.
	; ----------------------------------------------------------
_convertToAsciiLoop:
	cmp				EAX, 0							; if dividend=0, we are done
	je				_checkForSign	
	mov				EBX, 10
	mov				EDX, 0
	div				EBX						
	push			EAX								; save quotient (becomes new dividend)
	add				EDX, 48							; add 48 to remainder
	mov				EAX, EDX
	STOSB											; store the remainder+48 in tempArray
	pop				EAX								
	inc				count
	jmp				_convertToAsciiLoop

	; if SDWORD is negative, add on '-' to the end of tempArray
_checkForSign:
	cmp				sign, -1
	jne				_reverseArray
	mov				AL, 45							; store negative sign in tempArray
	STOSB
	inc				count

	; reverse tempArray and store in finalResult
_reverseArray:
	lea				ESI, tempArray
	lea				EDI, finalResult				; EDI points at beginning of finalResult
	dec				ESI
	mov				ECX, count
	add				ESI, ECX						; ESI points at end of tempArray
_reverseArrayLoop:
	STD
	LODSB
	CLD
	STOSB
	LOOP			_reverseArrayLoop

	; display num - send finalResult to mDisplayString
	lea				ESI, finalResult
	mDisplayString	ESI

	pop		ESI
	pop		ECX
	pop		EDX
	pop		EBX
	pop		EAX
	pop		EDI
	RET		4
WriteVal ENDP




; -------------------------------------------------------------------
; Name: introduction
;
; Introduces the programmer name, program title, and program description.
; Also displays extra credit implementation.
;
; Preconditions: instructions is a string that explains the game, 
;				programmerName is a string with the programmer's name,
;				programTitle is a string with the title of the program,
;				exCredOption1 is a string explaining the chosen extra credit
;
; Postconditions: none
;
; Receives: [ebp+20] = reference to exCredOption1
;			[ebp+16] = reference to programmerName
;			[ebp+12] = reference to programTitle
;			[ebp+8]	 = reference to instructions
;
; Returns: none
; -------------------------------------------------------------------
introduction PROC
	push	EBP
	mov		EBP, ESP
	push	EDX

	; display programmer name and program title
	mov		EDX, [EBP+16]
	call	WriteString
	mov		EDX, [EBP+12]
	call	WriteString
	call	CrLf
	call	CrLf

	; display extra credit
	mov		EDX, [EBP+20]
	call	WriteString
	call	CrLf
	call	CrLf

	; describe the game to the user
	mov		EDX, [EBP+8]
	call	WriteString
	call	CrLf
	call	CrLf

	pop		EDX
	pop		EBP
	RET		16
introduction ENDP




; -------------------------------------------------------------------
; Name: sumVals
;
; Sums the values in a given array.
;
; Preconditions: linesCount contains the number of array elements+1, 
;				sum is set to 0, validIntegersArray contains SDWORD 
;				integers
;
; Postconditions: none
;
; Receives: [ebp+16] = reference to size of validIntegersArray
;			[ebp+12] = reference to sum
;			[ebp+8]	 = reference to validIntegersArray
;
; Returns: global var sum contains the sum of all values in the array
; -------------------------------------------------------------------
sumVals PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	ECX
	push	ESI
	push	EBX

	; setup the sum loop
	mov				ECX, [EBP+16]				
	mov				ECX, [ECX]					
	dec				ECX							; array size in ECX
	mov				ESI, [EBP+8]				; address of validIntegersArray in ESI
	mov				EBX, 0						; EBX stores accumulating sum

	; loop through the given array to accumulate the sum of all SDWORDs
_sumValues:
	mov				EAX, [ESI]
	add				EBX, EAX
	add				ESI, 4
	LOOP			_sumValues

	; store the sum in global var sum
	mov				EAX, [EBP+12]
	mov				[EAX], EBX					; global var sum contains final sum

	pop		EBX
	pop		ESI
	pop		ECX
	pop		EAX
	pop		EBP
	RET		12
sumVals ENDP




END main
