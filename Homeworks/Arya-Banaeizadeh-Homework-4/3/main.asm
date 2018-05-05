;
;
; Created: 4/10/2018 11:31:29 AM
; Author : Arya
;
ldi r17, (1 <<wde)|(1 << wdp2)|(1 << wdp1)|(0 <<wdp0) ; enable watch dog timer and typical time out for 1.1' which is code wdp2=1 wdp1=1 wdp0=0
out wdtcr,r17
start:
	; code
	rjmp start	