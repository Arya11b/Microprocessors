;
; hw6-sol1.asm
;
; Created: 5/5/2018 3:58:35 PM
; Author : Arya
;


; Replace with your application code
.org $0
	rjmp reset
.org $012
	rjmp inct
reset:
	ldi r16,high(RAMEND)
	out SPH,r16
	ldi r16,low(RAMEND)
	out SPL,r16
start:
   ldi r16,2
	;Timer settings
    ldi r16,(0<<WGM00)|(1<<WGM01)|(1<<CS02)|(0<<CS01)|(1<<CS00)
	out TCCR0,r16
	;reset the prescaler
	ldi r16,(1<<PSR10)
	out SFIOR,r16
	;activate overflow interrupt
	ldi r16,(1<<TOIE0)
	out TIMSK,r16
	;make portd4,5 output
    sbi DDRD, DDD5
    sbi DDRD, DDD4
    cbi PORTD, PORTD5
    cbi PORTD, PORTD4
    ldi r18,(1<<TIFR)
	sbrs r18,TOV0
	;global interrupt enable
	sei
loop:
    rjmp Loop
inct:
    inc r17
    cpi r17, 16
    breq toggle
    reti
toggle:
    inc r22
    sbrc r22,3; if bit is zero skip
    rjmp on
    sbrs r22,3; if bit is one skip
    rjmp off
    
on:
	ldi r16,(1<<PD5)|(1<<PD4)
	out portd,r16
	reti
off:	
    ldi r16,(0<<PD5)|(0<<PD4)
	out portd,r16
	reti