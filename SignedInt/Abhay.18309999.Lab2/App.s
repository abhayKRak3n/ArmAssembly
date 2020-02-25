	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	
Start
	LDR R0,=number		;num stored in r0
	LDR R0,[R0]
	CMP R0,0x00000000
	BEQ disp_zero
	
	LDR R8,=0
	CMP R0,#0
	BGE sign
	B   twos_complement

sign
	ldr r3,= 0x000A0000		;show sign if pos
	str r3, [r2]	;output stored in r2
	b delay


twos_complement
	LDR R3,=0X000B0000	;shows if negative
	STR R3,[R2]
	MVN R0,R0
	ADD R0,R0,#1

delay
	ldr r4,=100000000		;delay for output
L1
	sub r4, r4, #1
	cmp r4, #0
	bge L1
	str r3,[r1]
	B  conv_num

conv_num
	LDR R5,=arr
	LDR R6, =0

next1					;calc next divisor 
 	LDR R8,[R5,R6,LSL #2]	
	CMP R0,R8
	BGE Digit_Count
	ADD R6,R6,#1
	B  next1

Digit_Count
	LDR R7,=0

division1
	SUB R0,R0,R8	;subtracting number and billion to get a digit  
	ADD R7,R7,#1
	CMP R0,R8
	BGE division1

display_number		;displaying that number
	MOV R7, R7, LSL #16
	MOV R3, R7
	STR R3,[R2]



delay2
	LDR R4,=100000000
Loop2
	SUB R4, R4, #1
	CMP R4, #0
	BGE Loop2

	STR r3,[r1]


;next_divisor pt 2
	CMP R0, #0
	BNE continue
	CMP R6, #9
	BGT Start

continue
	ADD R6,R6,#1
	LDR R8,[R5,R6, LSL #2]
	B Digit_Count2

Digit_Count2
	MOV R9,R0
	LDR R7,=0

division2
	SUBS R0,R0,R8
	ADD R7,R7,#1
	CMP R0,R8
	BGE division2
	
	
	BPL display_number
	CMP R7,#1
	BNE display_number


disp_zero
	LDR R3,=0x000f0000
	STR R3,[r2]
	MOV R0, R9
	B delay2
	
	
stop	B	stop


;practical 2
	
	
	
;subtracting numbers with 1 billion,1hundred million,etc ,to get each digit, in a loop	
arr DCD 1000000000,100000000,10000000,1000000,100000,10000,1000,100,10,1
	
;sample num used	
number DCD 0x00000419

	END