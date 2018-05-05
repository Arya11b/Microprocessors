;
;
; Created: 4/10/2018 11:31:29 AM
; Author : Arya
;
;
ldi r20, (1 <<wde)|(1 << wdp2)|(1 << wdp1)|(0 <<wdp0) ; enable watch dog timer and typical time out for 1.1' which is code wdp2=1 wdp1=1 wdp0=0
ldi r21, (0<<wde)|(0 << wdp2)|(0 << wdp1)|(0 <<wdp0)
start:
	ldi r16,(1<<PB5)
	out ddrd,r16; make PC5 output
	ldi r17,(1<<PB3)|(1<<PB6)
	out portd,r17
	rjmp sw1check
sw1check:
	in r15,pind
	mov r19,r15
	sbrc r15,3; if bit is zero skip
	rjmp off	
	out wdtcr,r20
	rjmp on
resetwdt:
	out wdtcr,r21
	rjmp enablewd
	
on:
	ldi r16,(1<<PB3)|(1<<PB5)
	out portd,r16
	sbrc r15,6
	rjmp on
	rjmp resetwdt
off:	
        ldi r16,(0<<PB3)
	out portd,r16
	rjmp sw1check
enablewd:
	out wdtcr,r20
checki:
	in r15,pind
	sbrc r15,6
	rjmp checki
	rjmp on