;
; hw6-sol1.asm
;
; Created: 5/5/2018 3:58:35 PM
; Author : Arya
;


; Replace with your application code

reset:
	ldi r16,high(RAMEND)
	out SPH,r16
	ldi r16,low(RAMEND)
	out SPL,r16
start:
    ldi r16,2
    ;Timer settings
    ldi r16,(0<<WGM00)|(1<<WGM01)|(1<<CS02)|(0<<CS01)|(1<<CS00)|(1<<COM00)|(0<<COM01)
    out TCCR0,r16
    ;reset the prescaler
    ldi r16,(1<<PSR10)
    out SFIOR,r16
    
    ldi r16,1
    out OCR0,r16
    ;make portb3 output
    sbi DDRB, DDB3
Loop:
    rjmp Loop
