TITLE Project 5     (Proj5_majorsal.asm)

; Author: Allison Majors
; Last Modified: 8/1/2024
; OSU email address: majorsal@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5                Due Date: 8/11/2024
; Description: This program populates an array of ARRAYSIZE elements with random numbers in
;			   the range [LO..HI]. The unsorted array is printed, then the array is sorted.
;			   Then, the median of the array is found and printed to the screen. Then, the
;			   sorted array is displayed. The program then counts the number of occurrences
;			   of each random number in the array and stores these values in a separate
;			   array. This array is then displayed.

INCLUDE Irvine32.inc

; (insert macro definitions here)

ARRAYSIZE	=   200
LO			=	15
HI			=	50

.data

programmerName			BYTE	"	Allison Majors ", 0
programTitle			BYTE	"Project5 - Operations with a Randomized Array", 0
instructions			BYTE	"This program generates 200 random numbers [15..50] and ",
								"stores them in an array. The (unsorted) array is displayed. ",
								"Then, the program sorts this array and displays the ",
								"median and sorted array. Then, the program counts and ",
								"displays the frequency of each occuring number in the array. ",
								"Lastly, a goodbye message displays.", 0
randArray				DWORD	ARRAYSIZE DUP(?)
randArrayLength			DWORD	LENGTHOF randArray
counts					DWORD	HI-LO+1 DUP(?)
countsLength			DWORD	LENGTHOF counts
unsortedDisplayMessage	BYTE	"This is your randomized array unsorted: ", 0
sortedDisplayMessage	BYTE	"This is your randomized array sorted: ", 0
medianDisplayMessage	BYTE	"The median value of the randomized array is: ", 0
countsDisplayMessage	BYTE	"The frequency of each randomized number ordered from smallest ",
								"to largest is: ", 0


.code
main PROC

	; display programmer name, title, and instructions
	push	OFFSET programmerName
	push	OFFSET programTitle
	push	OFFSET instructions
	call	introduction

	; fill randArray with random numbers [LO..HI]
	call	Randomize				; generate random seed
	push	OFFSET randArray
	call	fillArray

	; display unsorted array
	push	randArrayLength
	push	OFFSET unsortedDisplayMessage
	push	OFFSET randArray
	call	displayList

	; sort randArray
	push	OFFSET randArray
	call	sortList

	; display the median of randArray
	push	OFFSET medianDisplayMessage
	push	OFFSET randArray
	call	displayMedian

	; display sorted array
	push	randArrayLength
	push	OFFSET sortedDisplayMessage
	push	OFFSET randArray
	call	displayList

	; count and display the occurrence of each num [LO..HI] in randArray
	push	OFFSET randArray
	push	OFFSET counts
	call	countList

	; display the counts array
	push	countsLength
	push	OFFSET countsDisplayMessage
	push	OFFSET counts
	call	displayList

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; -------------------------------------------------------------------
; Name: introduction
;
; Introduces the programmer name, program title, and program description.
;
; Preconditions: instructions is a string that explains the game, 
;				programmerName is a string with the programmer's name,
;				programTitle is a string with the title of the program
;
; Postconditions: none
;
; Receives: [ebp+16] = reference to programmerName
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

	; describe the game to the user
	mov		EDX, [EBP+8]
	call	WriteString
	call	CrLf
	call	CrLf

	pop		EDX
	pop		EBP
	RET		12
introduction ENDP



; -------------------------------------------------------------------
; Name: fillArray
;
; Generates random values from [LO..HI] and stores these values in the
; array randArray.
;
; Preconditions: randArray exists, it is assumed that randArray
;				stores DWORDs
;
; Postconditions: none
;
; Receives: [ebp+8] = reference to randArray, constants LO, HI, 
;			ARRAYSIZE
;
; Returns: randArray is filled with random values in the range [LO..HI]
; -------------------------------------------------------------------
fillArray PROC
	push	EBP
	mov		EBP, ESP
	push	ECX
	push	EDI
	push	EAX

	mov		ECX, ARRAYSIZE
	mov		EDI, [EBP+8]			; address of randArray in EDI

	; Generate a random integer [LO..HI] and store in randArray,
	; increment EDI to move to the next open spot in memory for the array.
_fillArrayLoop:
	mov		EAX, HI
	inc		EAX
	call	RandomRange

	; check that the random number is >= LO, if not then get new num
	cmp		EAX, LO
	jl		_fillArrayLoop

	; random num is in valid range, store it in randArray
	mov		[EDI], EAX
	add		EDI, 4
	LOOP	_fillArrayLoop			; get next random num

	pop		EAX
	pop		EDI
	pop		ECX
	pop		EBP
	RET		4
fillArray ENDP



; -------------------------------------------------------------------
; Name: sortList
;
; Uses bubble sort to sort an unsorted array of numbers.
;
; Preconditions: given array is populated with numbers, it is assumed
;				the given array stores DWORDs
;
; Postconditions: none
;
; Receives: [ebp+8] = reference to array, CONSTANT ARRAYSIZE
;
; Returns: given array is sorted
; -------------------------------------------------------------------
sortList PROC
	push	EBP
	mov		EBP, ESP
	push	EDI
	push	EBX
	push	EDX
	push	EAX
	push	ECX

	mov		EDI, [EBP+8]				; address of array stored in EDI

	; set up loop counters
	mov		EBX, 1				
	mov		EDX, 1		
	
	; The _outerLoop and _innerLoop mimick that of loop 'i' and loop 'j'
	; in a traditional high-level language bubble sort.
	; If _outerLoop's counter, EBX, equals ARRAYSIZE, then we have "bubbled up"
	; every necessary element and are done sorting.
_outerLoop:
	cmp		EBX, ARRAYSIZE
	je		_done

	; For _innerLoop, compare each element with the one immediately following it.
	; If the first element is greater than the second, then swap them by calling
	; exchangeElements.
	; If _innerLoop's counter, EDX, equals ARRAYSIZE, then this loop is over and we
	; increment _outerLoop's counter, EBX, and put the start of the array back in EDI
	; before starting _outerLoop again.
_innerLoop:
	cmp			EDX, ARRAYSIZE
	jl			_compare
	inc			EBX				
	mov			EDI, [EBP+8]			; address of randArray in EDI
	mov			EDX, 1					; reset _innerLoop's counter
	jmp			_outerLoop

	; Compare the first element with the second element. If the first element is
	; greater, then swap them.
_compare:
	mov		EAX, [EDI]					; EAX stores first element
	add		EDI, 4
	mov		ECX, [EDI]					; ECX stores second element
	sub		EDI, 4					
	cmp		EAX, ECX
	jg		_swap
	jmp		_innerLoopAgain				; no need to swap, move to next num

	; Swap the two elements. Send their addresses to exchangeElements.
_swap:
	push		EDI						; send address of first element
	mov			ECX, EDI
	add			ECX, 4
	push		ECX						; send address of second element
	call		exchangeElements

	; Before jumping to _innerLoop, increment _innerLoop's counter, EDX, 
	; and also point to the next element in the array by adding to the address in EDI.
_innerLoopAgain:
	inc			EDX			
	add			EDI, 4				
	jmp			_innerLoop
	
_done:
	pop		ECX
	pop		EAX
	pop		EDX
	pop		EBX
	pop		EDI
	pop		EBP
	RET		4
sortList ENDP



; -------------------------------------------------------------------
; Name: exchangeElements
;
; Swaps two elements in an array.
;
; Preconditions: array is populated with values in memory
;
; Postconditions: none
;
; Receives: [ebp+12] = reference to first element,
;			[ebp+8] = reference to second element
;
; Returns: first element and second element are swapped
; -------------------------------------------------------------------
exchangeElements PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EBX
	push	ECX
	push	EDX
	
	; store the addresses of both elements
	mov		EAX, [EBP+12]			
	mov		EBX, [EBP+8]			

	; deference the addresses to get the actual numbers
	mov		ECX, [EAX]
	mov		EDX, [EBX]

	; swap the elements
	mov		[EBX], ECX
	mov		[EAX], EDX
	
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBP
	RET		8
exchangeElements ENDP



; -------------------------------------------------------------------
; Name: displayMedian
;
; Finds the median of randArray. If ARRAYSIZE is an even number, the
; median is the average (using round half up rounding) of the two 
; middle elements. If ARRAYSIZE is odd, then the median is the middle
; element.
;
; Preconditions: randArray is populated with values in memory and is 
;				sorted, medianDisplayMessage is a string with message 
;				to be printed, typeRandArray stores the type of randArray,
;				it is assumed both arrays store DWORD elements
;
; Postconditions: none
;
; Receives: [ebp+8] = reference to array, 
;			[ebp+12] = reference to medianDisplayMessage,
;			CONSTANT ARRAYSIZE
;
; Returns: none
; -------------------------------------------------------------------
displayMedian PROC
	push	EBP
	mov		EBP, ESP
	push	EDX
	push	ESI
	push	EAX
	push	EBX
	push	ECX

	mov		ESI, [EBP+8]				; address of randArray in ESI

	; print medianDisplayMessage to the screen
	mov		EDX, [EBP+12]				; address of medianDisplayMessage in EDX
	call	WriteString

	; Check if array has even or odd num of elements by dividing ARRAYSIZE 
	; by 2.
	mov		EAX, ARRAYSIZE
	mov		EDX, 0
	mov		EBX, 2
	div		EBX
	cmp		EDX, 0
	je		_evenNumElements

	; Odd num elements- median is the middle element.
	; Divide ARRAYSIZE by 2 to get the middle element's index, then multiply 
	; its index by 4 to get correct address.
	mov		EAX, ARRAYSIZE
	mov		EDX, 0
	mov		EBX, 2
	div		EBX
	mov		ECX, 4		
	mul		ECX
	mov		EAX, [ESI+EAX]				; middle element in EAX
	jmp		_displayMedian

	; Even num elements- median is the average of the two middle elements.
	; To get the two middle elements, first divide ARRAYSIZE by 2 to get the second
	; middle element's index. 
_evenNumElements:
	mov		EAX, ARRAYSIZE
	mov		EDX, 0
	mov		EBX, 2
	div		EBX

	; Get second middle element (multiply its index by 4 to reach correct
	; address).
	mov		ECX, 4		
	mul		ECX
	mov		EDX, [ESI+EAX]				; save 2nd mid element in EDX

	; Get first middle element (subtract 4 from the 2nd mid element's
	; address to get correct address).
	mov		ECX, 4
	sub		EAX, ECX
	mov		EBX, [ESI+EAX]				; save 1st mid element in EBX

	; divide the sum of the two mid elements by 2 to get their average
	mov		EAX, EDX
	add		EAX, EBX						
	mov		EDX, 0
	mov		EBX, 2
	div		EBX

	; round average up if needed
	cmp		EDX, 1
	jne		_displayMedian
	inc		EAX

	; print the median to the screen
_displayMedian:
	call	WriteDec
	call	CrLf
	call	CrLf

	pop		ECX
	pop		EBX
	pop		EAX
	pop		ESI
	pop		EDX
	pop		EBP
	RET		8
displayMedian ENDP



; -------------------------------------------------------------------
; Name: displayList
;
; Displays all the elements in an array, 20 numbers per line with one
; space between each value.
;
; Preconditions: array received contains numbers stored in memory, string 
;				received contains message to be displayed, it is assumed
;				the array received stores DWORD elements
;
; Postconditions: none
;
; Receives: [ebp+8] = reference to array, 
;			[ebp+12] = reference to string containing message to print,
;			[ebp+16] = array length
;
; Returns: none
; -------------------------------------------------------------------
displayList PROC
	push	EBP
	mov		EBP, ESP
	push	ECX
	push	ESI
	push	EAX
	push	EBX
	push	EDX

	; set up counters/store array
	mov		ECX, [EBP+16]			; array length in ECX
	mov		ESI, [EBP+8]			; address of array in ESI
	mov		EBX, 0					; use EBX to count nums displayed
	
	; print string explaining the list to the screen
	mov		EDX, [EBP+12]			; address of string in EDX
	call	WriteString
	call	CrLf

	; Print each number followed by a space to the screen
	; Only display 20 numbers per line.
_displaySingleNum:
	mov		EAX, [ESI]
	call	WriteDec
	mov		AL, " "
	call	WriteChar
	add		ESI, 4
	inc		EBX
	cmp		EBX, 20					; if 20 nums have displayed, go to new line
	jl		_continueLooping
	call	CrLf					
	mov		EBX, 0					; reset counter
_continueLooping:
	LOOP	_displaySingleNum

	call	CrLf
	call	CrLf
	pop		EDX
	pop		EBX
	pop		EAX
	pop		ESI
	pop		ECX
	pop		EBP
	RET		12
displayList ENDP



; -------------------------------------------------------------------
; Name: countList
;
; Counts the number of occurrences of each number in the range [LO..HI]
; in randArray. These occurrences are stored in the array 'counts'.
;
; Preconditions: randArray is populated with values stored in memory and
;				 is sorted, counts exists, it is assumed randArray stores
;				 DWORDs
;
; Postconditions: none
;
; Receives: [ebp+8] = reference to counts,
;			[ebp+12] = reference to randArray,
;			constants LO, HI
;
; Returns: counts array stores the frequency of [LO..HI] numbers as they 
;          exist in randArray
; -------------------------------------------------------------------
countList PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	ESI
	push	EBX
	push	ECX

	mov		EAX, [EBP+8]				; address of counts stored in EAX
	mov		ESI, [EBP+12]				; address of randArray stored in ESI

	; set up loop counters
	mov		EBX, LO	
	mov		ECX, 0						; ecx counts num occurrences

	; Compare every [LO..HI] number with randArray number sequentially.
	; If the numbers match, add to ECX, if not then store the count
	; in counts.
_top:
	cmp		EBX, HI						; check if have iterated through all [LO..HI] nums
	jg		_finished

	; compare [LO..HI] number with randArray number
	cmp		EBX, [ESI]
	jne		_numsNoMatch

	; nums are equal- increment counter (ECX) and point to next randArray num
	inc		ECX
	add		ESI, 4
	jmp		_top

	; Nums not equal- store counter (ECX) in counts, reset ECX, and point to 
	; next [LO..HI] num by incrementing EBX.
_numsNoMatch:
	mov		[EAX], ECX
	add		EAX, 4
	mov		ECX, 0
	inc		EBX
	jmp		_top
	
_finished:
	pop		ECX
	pop		EBX
	pop		ESI
	pop		EAX
	pop		EBP
	RET 8
countList ENDP


END main
