;
;
; Created: 4/10/2018 11:31:29 AM
; Author : Arya
;
.def time = r20
.def zero = r26
ldi zero,0
; Initialize the stack pointer
SP_INIT:
	LDI    R22, low(RAMEND)
	OUT    SPL, R22
	LDI    R22, high(RAMEND)
	OUT    SPH, R22
start:
	ldi r16,(1<<PB4)
	out ddrd,r16; make PC4 output
	ldi r17,(1<<PB6)
	out portd,r17
	rjmp sw2check
sw2check:
	in r15,pind
	clz
	ldi time,10
	sbrc r15,6; if bit is zero skip
	rjmp poweroff
	rjmp flash
	
flash:
	clz
	call on
	call delay
	call off
	call delay
	dec time
	cpse time,zero
	rjmp flash
	rjmp sw2check
off:	
    ldi r16,(0<<PB6)
	out portd,r16
	ret
on: 
	ldi r16,(1<<PB4)
	out portd,r16
	ret
poweroff:
    ldi r16,(0<<PB4)
	out portd,r16
	rjmp sw2check
delay:
	clz
	ldi r23,50
	ldi r24,30
	ldi r25,30
	rjmp delay1
delay1:	dec r25
		rjmp compare
delay2:	dec r24
		rjmp compare
delay3:	dec r23
		rjmp compare
compare:
	cpse r25,zero
	rjmp delay1
	ldi r25,30
	cpse r24,zero
	rjmp delay2
	ldi r24,30
	cpse r23,zero
	rjmp delay3
	ret
	