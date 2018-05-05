;
;
; Created: 4/10/2018 11:31:29 AM
; Author : Arya
;

start:
	ldi r16,(1<<PB5)
	out ddrd,r16; make PC5 output
	ldi r17,(1<<PB3)
	out portd,r17
	rjmp sw1check
sw1check:
	in r15,pind
	sbrc r15,3; if bit is zero skip
	rjmp off
	rjmp on
	
on:
	ldi r16,(1<<PB3)|(1<<PB5)
	out portd,r16
	rjmp sw1check
off:	
        ldi r16,(0<<PB3)
	out portd,r16
	rjmp sw1check