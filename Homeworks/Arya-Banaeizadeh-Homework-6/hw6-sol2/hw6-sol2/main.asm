;
; hw6-sol1.asm
;
; Created: 5/5/2018 3:58:35 PM
; Author : Arya
;


; Replace with your application code
.org $0
	rjmp reset

reset:
	ldi r16,high(RAMEND)
	out SPH,r16
	ldi r16,low(RAMEND)
	out SPL,r16
start:
   ldi r16,2
    ;Timer settings
    ;ldi r16,(1<<WGM00)|(0<<WGM01)|(1<<CS02)|(0<<CS01)|(1<<CS00)|(1<<COM00)|(1<<COM01) for question: 2.1
    ldi r16,(1<<WGM00)|(1<<WGM01)|(1<<CS02)|(0<<CS01)|(1<<CS00)|(1<<COM00)|(1<<COM01) ; for question: 2.2
    out TCCR0,r16
    ;reset time
    ldi r16,0
    out TCNT0,r16
    ;reset the prescaler
    ldi r16,(1<<PSR10)
    out SFIOR,r16
    ;make portb3 output
    sbi DDRB, DDD3
    cbi PORTD, PORTD5
    cbi PORTD, PORTD4
    ; pull up portd6,7
    sbi PORTD, PORTD6
    sbi PORTD, PORTD7
    ; set default value for ocr0
    call setDef
loop:
    sbis pind,7
    call setHigh
    sbis pind,6
    call setLow
    rjmp Loop

setHigh:
    ldi r16,10
    out OCR0,r16
    ret
setLow:
    ldi r16,150
    out OCR0,r16
    ret
setDef:	 
    ldi r16, 0xFF
    out OCR0, r16
    ret