;CS1022 Introduction to Computing II 2018/2019
; Mid-Term Assignment - Connect 4 - SOLUTION
;
; get, put and puts subroutines provided by jones@scss.tcd.ie
;

PINSEL0	EQU	0xE002C000
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014
	
SPACES EQU 42;
ROW  	EQU 6
COLUMNS EQU 7;		

	AREA	globals, DATA, READWRITE
BOARD	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0

;NEW_BOARD	SPACE	SPACES		; N words (4 bytes each)
	
	AREA	RESET, CODE, READONLY
	ENTRY

	; initialise SP to top of RAM
71	LDR	R13, =0x40010000	; initialse SP

	; initialise the console
	BL	inithw

	;
	; your program goes here
	;
	;Initializing the board
		LDR	R4, =BOARD
		;LDR	R5, =NEW_BOARD
		LDR	R6, =0
whInit	CMP	R6,#42
		BHS	eWhInit
		LDR R7,="0";
		;LDRB	R7, [R5, R6]
		STRB	R7, [R4, R6]
		ADD	R6, R6, #1
		B	whInit
eWhInit
	
	
	
	
		;mainline
		LDR R0,=str_go 	;load str go and print it
		BL puts
		BL PRINT_BOARD
	

		LDR R3,=BOARD;
		MOV R9,#0		;R9=Chance counter
		MOV R10,#0		;R10(win) = 0;
L2		CMP R10,#1		;R1O(win)==1 
		BEQ GAME_OVER;
		
		CMP R9,#0		;if R9(chance counter)=0  then chance(of red)
		BEQ L1			;else chance(of yellow)
		LDR R0,=str_yellow
		BL puts
		LDR R0,=str_new
	    BL puts
		BL get
		MOV R1,R0		;R1 = column input
		BL put
		MOV R5,#0x0059
		BL MOVE
		LDR R0,=str_new
	    BL puts
		BL PRINT_BOARD
		BL CHECKD		;check for win condition 
		BL CHECKV
		BL CHECKH
		LDR R6,=1
	
		MOV R9,#0		;chance counter (R9) = 0 (RED)
		B L2
L1
		LDR R0,=str_red
		BL puts;
		LDR R0,=str_new
	    BL puts
		BL get
		MOV R1,R0		;R1=column input
		BL put
		MOV R5,#0x0052
		BL MOVE
		LDR R0,=str_new
	    BL puts;
		BL PRINT_BOARD;
		BL CHECKD		;check for win condition
		BL CHECKV
		BL CHECKH
		LDR R6,=2
	    MOV R9,#1		;chance counter (R9) = 1 (YELLOW)
		B L2
				
GAME_OVER
stop	B	stop


;
; your subroutines go here
;

;
;subroutine to print board
;
PRINT_BOARD PUSH{R4-R10,LR}
	  
	  LDR R0,=str_count;
	  BL puts;
	  
	  LDR R10,=0		;counterForBoard = 0
	  LDR R6,=0			;counter = 0
	  LDR R4,=BOARD
	  ;LDR R4,=0x40000100;
	  LDR R5,=0			;row=0;
	  LDR R6,=7			;size=7
	  LDR R7,=0			;column=0
LO	  
	  ;MOV R0,R6;
	  ;BL put;
	  MUL R8,R5,R6		;R8 = row*size
	  ADD R8,R8,R7		;R8 = R8 + column
	  LDRB R0,[R4,R8]	;R0 = MEM[R4 + R8]
	  BL put
	  LDR R0,=" "		;put " " space on board
	  BL put;
	  ;ADD R4,R4,#1
	  ADD R10,R10,#1	;counterForBoard++
	  CMP R10,#42		;if the whole board is covered 
	  BHS skipL
	  ADD R7,R7,#1		;column++	
	  CMP R7,#7			;check if next column
	  BEQ N1
	  B LO	


N1
	  LDR R0,=str_new;
	  BL puts;
      LDR R7,=0			;column=0
	  ADD R5,R5,#1		;rows++
	 ;ADD R7,R7,#1;
	 ;LDR R6,=0			;column counter
	  B LO;	
skipL POP {R4-R10,PC}
;


;
;Subroutine to make a move
;
MOVE 
	PUSH {R2-R7,LR}
	MOV R7,R5			;R7 = piece(R/Y)

M1	LDR R2, =0			;counter = 0
	SUB R0,R0,#0x30		;convert ascii -> number
	MOV R4,R0			;R4=input 
	SUB R4,R4,#1		;column(input) = column(board)
	LDR R3,=BOARD;
	MOV R5,#0;
	ADD R5,R4,R3		;R5=column + board
	LDRB R6,[R5]
	CMP R6,#"0";
	BNE end1
L3	ADD R4,R4,#7		
	ADD R2,R2,#1		;counter++
	CMP R2,#6
	BEQ end2
	MOV R5,#0
	ADD R5,R4,R3		;R5=board + column
	LDRB R6,[R5]
	CMP R6,#"0";
	BNE store
	B L3
	
end1 LDR R0,=str_full;
	 BL puts
	 BL get
	 B M1

store SUB R4,R4,#7;
	MOV R5,#0
	ADD R5,R4,R3		;R5=board + column
	STRB R7,[R5]				

end2
	STRB R7,[R5]
	POP {R2-R7,PC}



;check for column wise
;checking for 4 lined up Rs or Ys together verticaly.
CHECKV
		PUSH{R2-R10,LR}
	
		MOV R9,#0x0059		;R9="Y"
		MOV R10,#0x0052		;R10="R"
		MOV R2,#0			;length=0

		LDR R3,=BOARD
		MOV R4,#0			;column = 0
		MOV R7,#0			;row = 0
		ADD R4,R3,R4		;R4 = board + column
		ADD R4,R4,R7		;R4 = R4 +row
		
LPV		LDRB R5,[R4]		;load from board @ index0
		
		CMP R5,R10  		;if(r5=='R')
		BEQ RedVertical
		
		CMP R5,R9			;if(r5=='Y')
		BEQ YellowVertical
		
		; if index!=R AND index!=Y
RADDV	ADD R4,R4,#1		;index++
		ADD R8,R3,#41		;last index of board
		CMP R4,R8			;if(column==index[6,7])
		BEQ ENDV			;if(end of board?)
		B LPV				;else(next element)
			

RedVertical	MOV R6,R4			;R6 = R4
		ADD R2,R2,#1		;length++
CHKV	ADD R6,R6,#7		;index++
		LDRB R5,[R6];
		CMP R5,R10			;if(r5=='R')
		BEQ H1V
		;if next index !=0
		MOV R2,#0			;length=0
		B RADDV;
		
H1V		ADD R2,R2,#1		;length++
		CMP R2,#4			;if(lenght==4)
		BEQ WINRV;
		B CHKV


YellowVertical	MOV R6,R4		;R6 = R4
		ADD R2,R2,#1		;length++
CHKYV	ADD R6,R6,#7		;index++
		LDRB R5,[R6]
		CMP R5,R9			;if(r5=='Y')
		BEQ H1YV
		;if next index !=0
		MOV R2,#0			;length = 0
		B RADDV

H1YV	ADD R2,R2,#1		;length++
		CMP R2,#4			;if(lenght==4)
		BEQ WINYV
		B CHKYV

WINRV 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_R
		BL puts;
		B stop

WINYV 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_Y
		BL puts;
		B stop
		
ENDV	POP{R2-R10,PC}
	


;checking row wise
;checking for 4 lined up Rs or Ys together horizontally.



CHECKH	PUSH{R2-R10,LR}
		MOV R9,#0x0059		;R9="Y"
		MOV R10,#0x0052		;R10="R"
		MOV R2,#0			;length=0

		LDR R3,=BOARD;
		MOV R4,#0			;column=0
		MOV R7,#0			;row=0
		ADD R4,R3,R4		;R4=board + column
		ADD R4,R4,R7		;R4=R4 + row
		
LP		LDRB R5,[R4]		;R5-> board @index0
		

		CMP R5,R10			;R5=='R'
		BEQ REDHZ
		
		CMP R5,R9			;R5=='Y'
		BEQ YELLOWHZ
		
		
		; ifindex!=R #AND index!=Y
RADD	ADD R4,R4,#1		;index++
		ADD R8,R3,#41		;last index of board
		CMP R4,R8			;column==index(6,7)
		BEQ HEND			;if(end of board?)
		B LP				;else(next element)
			
REDHZ		MOV R6,R4			;R6 = R4
		ADD R2,R2,#1		;length++
CHKRED		ADD R6,R6,#1		;index++
		LDRB R5,[R6]
		CMP R5,R10			;IF(R5=='R')
		BEQ H1
		;if next index !=0
		MOV R2,#0			;length=0
		B RADD
		
H1		ADD R2,R2,#1		;length++
		CMP R2,#4			;lenght==4?
		BEQ HWINR;
		B CHKRED


YELLOWHZ		MOV R6,R4			;R4 = R6
		ADD R2,R2,#1		;length++
CHKYELLOW	ADD R6,R6,#1		;index++
		LDRB R5,[R6]
		CMP R5,R9			;if(r5=='Y')
		BEQ H1Y
		;if next index !=0
		MOV R2,#0			;length=0
		B RADD

H1Y		ADD R2,R2,#1		;length++
		CMP R2,#4			;if(lenght==4)
		BEQ HWINY
		B CHKYELLOW

HWINR 	LDR R0,=str_new
		BL puts
		LDR R0,=str_R
		BL puts
		B stop

HWINY 	LDR R0,=str_new
		BL puts
		LDR R0,=str_Y
		BL puts;
		B stop
		
HEND	
	POP{R2-R10,PC}
	
	
	
	
;check for diagonal
;checks for 4 lined up Rs or Ys DIAGONALLY.

CHECKD
		PUSH{R2-R10,LR}
		MOV R9,#0x0059		;R9="Y"
		MOV R10,#0x0052		;R10="R"
		MOV R2,#0			;length=0
		MOV R8,#0			;counter=0
		LDR R3,=BOARD
		MOV R4,#0			;column=0
		MOV R7,#0			;row=0
		ADD R4,R3,R4		;R4=board + column
		ADD R4,R4,R7		;R4=R4 + ROW
		
LPD		LDRB R5,[R4]		;loading from board index0
		

		CMP R5,R10			;if(r5=='R')
		BEQ RHZD
		
		CMP R5,R9			;if(r5=='Y')
		BEQ YHZD
		
		
		; IF index!=R AND index!=Y
RADDD		
		ADD R4,R4,#1		;index++
		ADD R8,R8,#1		;counter++
		ADD R8,R3,#21		;index of board (4,1)
		CMP R4,R8			;column==index(4,1)
		BEQ HENDD
		B LPD
			

RHZD	MOV R6,R4		;R6=R4
		ADD R2,R2,#1	;length++
CHKD	ADD R6,R6,#8	;index+=8
		LDRB R5,[R6]
		CMP R5,R10			;r5=='R'?
		BEQ H1D
		;if next index !=0
		MOV R2,#0			;length=0
		B REVDR;
		
H1D		ADD R2,R2,#1		;length++
		CMP R2,#4			;if(lenght==4)
		BEQ HWINRD;
		B CHKD


YHZD	MOV R6,R4		;R6=R4
		ADD R2,R2,#1		;length++
CHKYD	ADD R6,R6,#8		;index+=8
		LDRB R5,[R6]
		CMP R5,R9			;if(R5=='Y')
		BEQ H1YD
		;if next index !=0
		MOV R2,#0			;length=0
		B REVDY

H1YD	ADD R2,R2,#1		;length++
		CMP R2,#4			;lenght==4?
		BEQ HWINYD
		B CHKYD

REVDR	;checks for diagonal from R->L for R
		MOV R6,R4			;R6 = R4
		ADD R2,R2,#1		;length++
CHKD2	ADD R6,R6,#6		;index+=6
		LDRB R5,[R6]
		CMP R5,R10			;if(r5=='R')
		BEQ H2D
		;if next index !=0
		MOV R2,#0			;length=0
		B RADDD
		
H2D		ADD R2,R2,#1		;length++
		CMP R2,#4			
		BEQ HWINRD
		B CHKD2
		
		
REVDY	;checks for diagonal from R->L for Y
		MOV R6,R4
		ADD R2,R2,#1		;length++
CHKYD2	ADD R6,R6,#6		;index+=6
		LDRB R5,[R6]
		CMP R5,R9			;r5=='Y'?
		BEQ H1YD2
		;if next index !=0
		MOV R2,#0			;length=0
		B RADDD

H1YD2	ADD R2,R2,#1		;length++
		CMP R2,#4			
		BEQ HWINYD
		B CHKYD2


HWINRD 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_R
		BL puts;
		B stop

HWINYD 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_Y
		BL puts;
		B stop
		
HENDD	
	POP{R2-R10,PC}

;
; inithw subroutines
; performs hardware initialisation, including console
; parameters:
;	none
; return value:
;	none
;
inithw
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]
	BX	LR

;
; get subroutine
; returns the ASCII code of the next character read on the console
; parameters:
;	none
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
get	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
get0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	get0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; get received data
	BX	LR			; return

;
; put subroutine
; writes a character to the console
; parameters:
;	R0 - ASCII code of the character to write
; return value:
;	none
;
put	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	put			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; output charcter
put0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	put0			; empty (data flushed)
	BX	LR			; return

;
; puts subroutine
; writes the sequence of characters in a NULL-terminated string to the console
; parameters:
;	R0 - address of NULL-terminated ASCII string
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
puts	STMFD	SP!, {R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
puts0	LDRB	R0, [R4], #1		; get character + increment R4
	CMP	R0, #0			; 0?
	BEQ	puts1			; return
	BL	put			; put character
	B	puts0			; next character
puts1	LDMFD	SP!, {R4, PC} 		; pop R4 and PC


;
; hint! put the strings used by your program here ...
str_red
	DCB 0xA,"RED: choose a column for your next move (1-7, q to restart):",0xA, 0xD, 0xA, 0xD, 0

str_yellow
	DCB 0xA,"YELLOW: choose a column for your next move (1-7, q to restart):",0xA, 0xD, 0xA, 0xD, 0
str_game_over
	DCB "GAME OVER",0xA, 0xD, 0xA, 0xD, 0
;

str_go
	DCB	"Let's play Connect4!!",0xA, 0xD, 0xA, 0xD, 0

str_new
	DCB	"",0xA, 0xD, 0x0
str_count
	DCB "1 2 3 4 5 6 7",0xA, 0xD, 0xD, 0
str_full
	DCB "This column is full.Please enter a different column number.",0xA, 0xD, 0xD, 0	

str_win DCB	"WIN",0xA, 0xD, 0xA, 0xD, 0

str_Y	DCB "	Y IS THE WINNER.",0xA, 0xD, 0xA, 0xD, 0
str_R	DCB "	R IS THE WINNER.",0xA, 0xD, 0xA, 0xD, 0

	
	
;NEW_BOARD 	DCD 0,0,0,0,0,0,0
			;DCD 0,0,0,0,0,0,0
			;DCD 0,0,0,0,0,0,0
			;DCD 0,0,0,0,0,0,0
			;DCD 0,0,0,0,0,0,0
			;DCD 0,0,0,0,0,0,0		

	END