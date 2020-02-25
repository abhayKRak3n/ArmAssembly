	AREA AsmTemplate, CODE, READONLY
	IMPORT main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	EXPORT start
start

IO1DIR EQU 0xE0028018
IO1SET EQU 0xE0028014
IO1CLR EQU 0xE002801C
IO1PIN EQU 0xE0028010

start_clac
   BL LED_OFF

   MOV R0,#0           ;RO = FIRST NUMBER
   MOV R1,#0           ;R1 = SECOND NUMVER
   MOV R12,#0          ;R12 = temp (checks if operation is add or sub etc)


   ;CHECK EACH OF THE PINS P.20-23 IF PRESSED
   LDR R2,=IO1PIN
waitingForPressed
   LDR  R3,[R2]
checkP1_20    
   AND  R4,R3,#0x00100000
   CMP  R4,#0
   BNE  checkP1_21
   B  pressed_P1_20  
checkP1_21
   AND  R4,R3,#0x00200000
   CMP  R4,#0
   BNE  checkP1_22
   B  pressed_P1_21
checkP1_22
   AND  R4,R3,#0x00400000
   CMP  R4,#0
   BNE  checkP1_23
   B  pressed_P1_22
checkP1_23
   AND  R4,R3,#0x00800000
   CMP  R4,#0
   BNE  end_Loop
   B  pressed_P1_23
end_Loop  
   B    waitingForPressed



pressed_P1_23  
;MOST RIGHT WILL ENTER NUMBER
   CMP R12,#3     ;if R12 = 3 then clear disp
   BEQ clearDisplay
   ADD R0,R0,#1
;pressed_MostRight2  
   BL  LED_OFF
   BL  expressNumber

pressed_P1_23_while
   LDR R10,=1000000     ;timer
wait2
   subs R10,R10,#1
   BNE wait2
   LDR  R3,[R2]
   AND  R4,R3,#0x00800000        ;if pressed is p23
   CMP  R4,#0
   BEQ  pressed_P1_23_while
   MOV R9,R0
   B    waitingForPressed
 




pressed_P1_22
;SECOND TO RIGHT
   CMP R12,#3
   BEQ clearDisplay
   SUB R0,R0,#1
;pressed_SecondRight2  
   BL  LED_OFF
   BL  expressNumber

pressed_P1_22_while
   LDR R10,=1000000  ;timer
wait
   subs R10,R10,#1
   BNE wait
   LDR  R3,[R2]
   AND  R4,R3,#0x00400000     ;(makes sure that it is pressed once)
   CMP  R4,#0
   BEQ  pressed_P1_22_while
   MOV R9,R0
   B    waitingForPressed
   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
   
pressed_P1_21
;SECOND TO LEFT
   MOV R11,#0
   LDR R8, =0x00F42400
pressed_P1_21_while
   LDR R10,=1000000    			 ;timer
   ADD  R11,R11,#1
wait3
   subs R10,R10,#1
   ADD  R11,R11,#1
   BNE wait3
   LDR  R3,[R2]
   AND  R4,R3,#0x00200000    	;check if p_21
   CMP  R4,#0
   BEQ  pressed_P1_21_while
   CMP  R11,R8                  ;press more than 2seconds (longpress)
   BHS  P1_21_longPressed

   CMP R12,#1     				;if R12 = 1 THEN DO ADDITTION
   BEQ calculate_add
   CMP R12,#2     				;IF R12 = 2 THEN DO SUBTRACTION
   BEQ calculate_sub
   CMP R12,#3     				;ELSE RESET
   BEQ waitingForPressed
 
   MOV R1,R0
   MOV R0,#0
   MOV R12,#1     			   ;addittion
   BL  LED_OFF
   B   pressed_SecondLeft_end


calculate_add       		   ;calc addittion
   ADD R0,R0,R1	
   BL  expressNumber
   MOV R12,#3
pressed_SecondLeft_end  
   B   waitingForPressed

P1_21_longPressed
   MOV R0, R1
   MOV R1, #0
   MOV R12,#0
   BL  LED_OFF
   B   waitingForPressed
   
   
   
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
   
   
pressed_P1_20
   ;LEFTMOST
   MOV R11,#0;timer
   LDR R8, =0x00F42400
pressed_P1_20_while
   LDR R10,=1000000        		;timer
   ADD  R11,R11,#1
wait4
   subs R10,R10,#1
   ADD  R11,R11,#1
   BNE wait4
   LDR  R3,[R2]        
   AND  R4,R3,#0x00100000        ;check if p1_20 (makes sure that it is pressed once)
   CMP  R4,#0
   BEQ  pressed_P1_20_while
   CMP  R11,R8                  ;press more than 2seconds(longpress)
   BHS  P1_20_longPressed

   CMP R12,#1
   BEQ calculate_add
   CMP R12,#2
   BEQ calculate_sub
   CMP R12,#3
   BEQ waitingForPressed
   MOV R1,R0
   MOV R0,#0
   MOV R12,#2     				;subtraction
   BL  LED_OFF
   B   pressed_MostLeft_end

   
calculate_sub     				;Calc subtraction
   SUB R0,R1,R0
   BL  expressNumber
   MOV R12,#3
pressed_MostLeft_end  
   B   waitingForPressed
   
   
P1_20_longPressed
   B   start_clac   			 ;resets
 

clearDisplay
   BL  LED_OFF
   MOV R12,#0
   LDR R10,=4000000
   
wait5
   SUBS R10,R10,#1
   BNE wait5
   B   waitingForPressed
   



;expressNumber subroutine
;parameters
; R0 -> number to be expressed by the LEDs
expressNumber
   
   STMFD SP!,{R1-R3,R9}
positive_number
   ldr r1,=IO1DIR
   ldr r2,=0x000f0000      ;select P1.19--P1.16
   str r2,[r1]             ;make them outputs
   ldr r1,=IO1SET
   str r2,[r1]             ;set them to turn the LEDs off
   ldr r2,=IO1CLR
; r1 -> SET register
; r2 -> CLEAR register


   ldr r3,=0x00010000      ;start with P1.16.
firstbit
   AND R9,R0,#0x00000008
   CMP R9,#0x00000008
   BNE secondbit
   STR r3,[r2]             ;clear the bit and turn on  LED

secondbit
   MOV r3,r3,lsl #1        ;shift to next bit P1.17
   AND R9,R0,#0x00000004
   CMP R9,#0x00000004
   BNE thirdbit
   STR r3,[r2]             ;clear the bit -> turn on the LED

thirdbit
   MOV r3,r3,lsl #1        ;shift to bit P1.18
   AND R9,R0,#0x00000002
   CMP R9,#0x00000002
   BNE fourthbit
   STR r3,[r2]             ;clear the bit and turn on LED

fourthbit
   MOV r3,r3,lsl #1       ;shift to bit P1.19
   AND R9,R0,#0x00000001
   CMP R9,#0x00000001
   BNE end_expressNumber
   STR r3,[r2]             ;clear the bit and turn on LED

end_expressNumber

	LDMFD SP!,{R1-R3,R9}
	BX R14
;end of subroutine
 


;LED_OFF subroutine
LED_OFF
    STMFD SP ! , {R1-R3 }

	ldr r1,=IO1DIR
	ldr r2,=0x000f0000 		;select P1.19--P1.16
	str r2,[r1]    			;make them outputs
	ldr r1,=IO1SET
	str r2,[r1]    			;set them to turn the LEDs off
	ldr r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register  
	ldr r3,=0x00010000 		;start with P1.16.


	ldr r1,=IO1DIR
	ldr r2,=0x000f0000 			;select P1.19--P1.16
	str r2,[r1] 			;make them outputs
	ldr r1,=IO1SET
	str r2,[r1]				 ;set them to turn the LEDs off
	ldr r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register
	LDMFD SP ! , {R1-R3 }
	BX R14

END