.org 0x000
    rjmp SP_INIT
.org 0x0002
    rjmp intCheck
indSP_INIT:
    LDI    R16, low(RAMEND)
    OUT    SPL, R16
    LDI    R16, high(RAMEND)
    OUT    SPH, R16
Start:
init: 
    LDI R24, 0x00
    OUT DDRA, R24 ; PORTA is Input 
    LDI R24, 0b11110000
    OUT DDRB, R24 ; PORTB ddr set
    LDI R24, 0xFF
    OUT DDRC, R24 ; PORTC is Output
    LDI R24, 0x00 ;
    OUT PORTB, R24 ;    
	ldi r16,(1<<INT0) ; set int 0 flags
	out GICR,r16
	ldi r16,(1<<ISC11)|(0<<ISC10)out MCUCR,r16  ; activates on falling edge
	out MCUCR,r16
    sei
    NOP
    NOP
    NOP 
LOOP:
    rjmp LOOP
intCheck:
    in r16,PORTB
    CMPI r16,8
    BREQ PRINT
    RJMP FINDKEY
FINDKEY:
    LDI R20, 0x8 ; R20 will finally contain the No. of the pressed Key
LOOP1: 
    IN R17, PINA ; Read Value from Input Buffer #1
    CMP R17, 0xFF
    BREQ LOOP1 ; If R16=0xFF means that no Key was Pressed
    RCALL Delay20ms ; Call a 20ms Delay if any key was pressed
LOOP2: 
    DEC R20; ;
    LSL R17 ; Shift left the Value read from Keyboard
    BRCC LOOP3 ; Branch if Carry Flag is Cleared, so the pressed Key is detected
    RJMP LOOP2
LOOP3:
    MOV R0, R20; ; Now R0 Contains the No. of pressed key  
    ret
Print: 
    LDI R20, 0x00 ; R20 as a counter for printed bytes
LOOP4:
    OUT PORTA, R17
    CBI PORTB, 4 ; CP=0 
    SBI PORTB, 4 ; CP=1 T1, T2 and T3 times are satisfied
    CBI PORTB, 5 ; STROBE=0 0.5Us=8*62.5ns 
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    SBI PORTB, 5 ; STROBE=1
    INC R20
    CP R20, R16
    BRNE LOOP1 ; Check if Z Flag is 0
    rjmp LOOP
