;
; hw6-sol1.asm
;
; Created: 5/5/2018 3:58:35 PM
; Author : Arya
;


; Replace with your application code
.org $0
	rjmp reset
.org $020
	rjmp en
reset:
	ldi r16,high(RAMEND)
	out SPH,r16
	ldi r16,low(RAMEND)
	out SPL,r16
start:
	; set up acsr register
	ldi r17,(0 << ACD)|(0 << ACBG)|(1 << ACIE)|(0 << ACIS1)|(0 << ACIS0)
	out ACSR,r17
	; make pd5 output
	ldi r17,(1 << DDD5)
	out DDRD,r17
	sei
loop:
	rjmp loop
en:
	inc r18
	sbrs r18,0
	ldi r17,(1 << PD5)
	sbrc r18,0
	ldi r17,(0 << PD5)
	out portd,r17
	reti