;
; hw6-sol1.asm
;
; Created: 5/5/2018 3:58:35 PM
; Author : Arya
;

; Replace with your application code
.equ	LCD_RS	= 1
.equ	LCD_RW	= 2
.equ	LCD_E	= 3
.equ	addr	= 0x200

.def	temp	= r16
.def	argument= r17		;argument for calling subroutines
.def	return	= r18		;return value from subroutines

.def	ones = r22
.def	tens = r23
.def	huns = r24

; Replace with your application code
.org $0
	rjmp reset
.org $001C
	rjmp en
reset:
	ldi r16,high(RAMEND)
	out SPH,r16
	ldi r16,low(RAMEND)
	out SPL,r16
start:
	;q2
	; set up acsr register
	rcall lcd_init
	ldi r17,(1 << ACD)
	out ACSR,r17
	ldi r17,(1<<ADEN)|(1<<ADATE)|(1<<ADIE)
	out ADCSRA,r17
	in r17,ADMUX
	andi r17,0b11100000
	out ADMUX,r17
	; set sleep mode
	in R16,MCUCR
	ori R16,(1<<SE)|(1<<SM0)|(0<<SM1)|(0<<SM2)
	out MCUCR,R16
	sei

wait: 
	call adc1
	rjmp wait
adc1:
	in r17,ADCSRA
	ori r17,(1<<ADSC)
	out ADCSRA,r17
	call wfc
	in r20,ADCL
	in r21,ADCH
	ret
en:	ldi ones,0
	ldi tens,0
	ldi huns,0
	rcall	LCD_wait
	ldi	argument, 0x80	;now let the cursor go to line 0, col 0 (address 0)
	rcall	LCD_command	;for setting a cursor address, bit 7 of the commands has to be set

	call setnum
	call print
	reti
wfc:
	ldi R16,(1<<ADSC)
	in R17,ADCSRA;ADSC
	and R16,R17
	cpi R16,(1<<ADSC)
	breq wfc
	ret
setnum:
	cpi r20,0
	brne o1
	ret
o1:	dec r20
	inc ones
	cpi ones,10
	breq setten
	brne setnum
setten:
	ldi ones,0
	inc tens
	cpi tens,10
	breq sethun
	brne setnum
	ret
sethun:
	ldi tens,0
	inc huns
	brne setnum
	ret
print:
	cpi huns,1
	brne o2
	ldi argument,'1'
	call lcd_putchar
o2:	cpi huns,2
	brne o3
	ldi argument,'2'
	call lcd_putchar
o3:	cpi huns,3
	brne o4
	ldi argument,'3'
	call lcd_putchar
o4:	cpi huns,4
	brne o5
	ldi argument,'4'
	call lcd_putchar
o5:	cpi huns,5
	brne o6
	ldi argument,'5'
	call lcd_putchar
o6:	cpi huns,6
	brne o7
	ldi argument,'6'
	call lcd_putchar
o7:	cpi huns,7
	brne o8
	ldi argument,'7'
	call lcd_putchar
o8:	cpi huns,8
	brne o9
	ldi argument,'8'
	call lcd_putchar
o9:	cpi huns,9
	brne o10
	ldi argument,'9'
	call lcd_putchar

	
o10:	cpi tens,0
	brne o11
	ldi argument,'0'
	call lcd_putchar
o11:	cpi tens,1
	brne o12
	ldi argument,'1'
	call lcd_putchar
o12:	cpi tens,2
	brne o13
	ldi argument,'2'
	call lcd_putchar
o13:	cpi tens,3
	brne o14
	ldi argument,'3'
	call lcd_putchar
o14:	cpi tens,4
	brne o15
	ldi argument,'4'
	call lcd_putchar
o15:	cpi tens,5
	brne o16
	ldi argument,'5'
	call lcd_putchar
o16:	cpi tens,6
	brne o17
	ldi argument,'6'
	call lcd_putchar
o17:	cpi tens,7
	brne o18
	ldi argument,'7'
	call lcd_putchar
o18:	cpi tens,8
	brne o19
	ldi argument,'8'
	call lcd_putchar
o19:	cpi tens,9
	brne o20
	ldi argument,'9'
	call lcd_putchar

	
o20:	cpi ones,0
	brne o21
	ldi argument,'0'
	call lcd_putchar
o21:	cpi ones,1
	brne o22
	ldi argument,'1'
	call lcd_putchar
o22:	cpi ones,2
	brne o23
	ldi argument,'2'
	call lcd_putchar
o23:	cpi ones,3
	brne o24
	ldi argument,'3'
	call lcd_putchar
o24:	cpi ones,4
	brne o25
	ldi argument,'4'
	call lcd_putchar
o25:	cpi ones,5
	brne o26
	ldi argument,'5'
	call lcd_putchar
o26:	cpi ones,6
	brne o27
	ldi argument,'6'
	call lcd_putchar
o27:	cpi ones,7
	brne o28
	ldi argument,'7'
	call lcd_putchar
o28:	cpi ones,8
	brne o29
	ldi argument,'8'
	call lcd_putchar
o29:	cpi ones,9
	brne o30
	ldi argument,'9'
	call lcd_putchar
o30:	ret

;LCD now:
;|&		  | (&: cursor, blinking)
;|		  |
	
	rcall	LCD_wait
	ldi	argument, 'A'	;write 'A' to the LCD char data RAM
	rcall	LCD_putchar
	
;|A&		  |
;|		  |
	
	rcall	LCD_wait
	ldi	argument, 0x80	;now let the cursor go to line 0, col 0 (address 0)
	rcall	LCD_command	;for setting a cursor address, bit 7 of the commands has to be set
	
;|A		  | (cursor and A are at the same position!)
;|		  |
	
	rcall	LCD_wait
	rcall	LCD_getchar	;now read from address 0
	
;|A&		  | (cursor is also incremented after read operations!!!)
;|		  |
	
	push	return		;save the return value (the character we just read!)
	
	rcall	LCD_delay
	pop	argument	;restore the character
	rcall	LCD_putchar	;and print it again

;|AA&		  | (A has been read from position 0 and has then been written to the next pos.)
;|		  |
		
loop:	rjmp loop	

lcd_command8:	;used for init (we need some 8-bit commands to switch to 4-bit mode!)
	in	temp, DDRC		;we need to set the high nibble of DDRC while leaving
					;the other bits untouched. Using temp for that.
	sbr	temp, 0b11110000	;set high nibble in temp
	out	DDRC, temp		;write value to DDRC again
	in	temp, PORTC		;then get the port value
	cbr	temp, 0b11110000	;and clear the data bits
	cbr	argument, 0b00001111	;then clear the low nibble of the argument
					;so that no control line bits are overwritten
	or	temp, argument		;then set the data bits (from the argument) in the
					;Port value
	out	PORTC, temp		;and write the port value.
	sbi	PORTC, LCD_E		;now strobe E
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	in	temp, DDRC		;get DDRC to make the data lines input again
	cbr	temp, 0b11110000	;clear data line direction bits
	out	DDRC, temp		;and write to DDRC
ret

lcd_putchar:
	push	argument		;save the argmuent (it's destroyed in between)
	in	temp, DDRC		;get data direction bits
	sbr	temp, 0b11110000	;set the data lines to output
	out	DDRC, temp		;write value to DDRC
	in	temp, PORTC		;then get the data from PORTC
	cbr	temp, 0b11111110	;clear ALL LCD lines (data and control!)
	cbr	argument, 0b00001111	;we have to write the high nibble of our argument first
					;so mask off the low nibble
	or	temp, argument		;now set the argument bits in the Port value
	out	PORTC, temp		;and write the port value
	sbi	PORTC, LCD_RS		;now take RS high for LCD char data register access
	sbi	PORTC, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	pop	argument		;restore the argument, we need the low nibble now...
	cbr	temp, 0b11110000	;clear the data bits of our port value
	swap	argument		;we want to write the LOW nibble of the argument to
					;the LCD data lines, which are the HIGH port nibble!
	cbr	argument, 0b00001111	;clear unused bits in argument
	or	temp, argument		;and set the required argument bits in the port value
	out	PORTC, temp		;write data to port
	sbi	PORTC, LCD_RS		;again, set RS
	sbi	PORTC, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	cbi	PORTC, LCD_RS
	in	temp, DDRC
	cbr	temp, 0b11110000	;data lines are input again
	out	DDRC, temp
ret

lcd_command:	;same as LCD_putchar, but with RS low!
	push	argument
	in	temp, DDRC
	sbr	temp, 0b11110000
	out	DDRC, temp
	in	temp, PORTC
	cbr	temp, 0b11111110
	cbr	argument, 0b00001111
	or	temp, argument

	out	PORTC, temp
	sbi	PORTC, LCD_E
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	pop	argument
	cbr	temp, 0b11110000
	swap	argument
	cbr	argument, 0b00001111
	or	temp, argument
	out	PORTC, temp
	sbi	PORTC, LCD_E
	nop
	nop
	nop
	cbi	PORTC, LCD_E
	in	temp, DDRC
	cbr	temp, 0b11110000
	out	DDRC, temp
ret

LCD_getchar:
	in	temp, DDRC		;make sure the data lines are inputs
	andi	temp, 0b00001111	;so clear their DDR bits
	out	DDRC, temp
	sbi	PORTC, LCD_RS		;we want to access the char data register, so RS high
	sbi	PORTC, LCD_RW		;we also want to read from the LCD -> RW high
	sbi	PORTC, LCD_E		;while E is high
	nop
	in	temp, PinD		;we need to fetch the HIGH nibble
	andi	temp, 0b11110000	;mask off the control line data
	mov	return, temp		;and copy the HIGH nibble to return
	cbi	PORTC, LCD_E		;now take E low again
	nop				;wait a bit before strobing E again
	nop	
	sbi	PORTC, LCD_E		;same as above, now we're reading the low nibble
	nop
	in	temp, PinD		;get the data
	andi	temp, 0b11110000	;and again mask off the control line bits
	swap	temp			;temp HIGH nibble contains data LOW nibble! so swap
	or	return, temp		;and combine with previously read high nibble
	cbi	PORTC, LCD_E		;take all control lines low again
	cbi	PORTC, LCD_RS
	cbi	PORTC, LCD_RW
ret					;the character read from the LCD is now in return

LCD_getaddr:	;works just like LCD_getchar, but with RS low, return.7 is the busy flag
	in	temp, DDRC
	andi	temp, 0b00001111
	out	DDRC, temp
	cbi	PORTC, LCD_RS
	sbi	PORTC, LCD_RW
	sbi	PORTC, LCD_E
	nop
	in	temp, PinD
	andi	temp, 0b11110000
	mov	return, temp
	cbi	PORTC, LCD_E
	nop
	nop
	sbi	PORTC, LCD_E
	nop
	in	temp, PinD
	andi	temp, 0b11110000
	swap	temp
	or	return, temp
	cbi	PORTC, LCD_E
	cbi	PORTC, LCD_RW
ret

LCD_wait:				;read address and busy flag until busy flag cleared
	rcall	LCD_getaddr
	andi	return, 0x80
	brne	LCD_wait
	ret


LCD_delay:
	clr	r2
	LCD_delay_outer:
	clr	r3
		LCD_delay_inner:
		dec	r3
		brne	LCD_delay_inner
	dec	r2
	brne	LCD_delay_outer
ret

LCD_init:
	
	ldi	temp, 0b00001110	;control lines are output, rest is input
	out	DDRC, temp
	
	rcall	LCD_delay		;first, we'll tell the LCD that we want to use it
	ldi	argument, 0x20		;in 4-bit mode.
	rcall	LCD_command8		;LCD is still in 8-BIT MODE while writing this command!!!

	rcall	LCD_wait
	ldi	argument, 0x28		;NOW: 2 lines, 5*7 font, 4-BIT MODE!
	rcall	LCD_command		;
	
	rcall	LCD_wait
	ldi	argument, 0x0F		;now proceed as usual: Display on, cursor on, blinking
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x01		;clear display, cursor -> home
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x06		;auto-inc cursor
	rcall	LCD_command
ret
	
	
