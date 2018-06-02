;
; hw5-sol2.asm
;
; Created: 5/4/2018 11:10:51 AM
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

.org 0
rjmp reset

.org 0x0002
	rjmp KeyFind

reset:
	ldi	temp, low(RAMEND)
	out	SPL, temp
	ldi	temp, high(RAMEND)
	out	SPH, temp

start:
	; USART INIT
	; Set the baud rate to 9600 bps
	; focs = 8.0000 MHZ
	ldi r17,51
	ldi r18,0
	out UBRRH,r18
	out UBRRL,r17
	; Enable USART send and recieve + Their interrupts
	ldi r16,(0 << UCSZ2)|(0 << RXEN)|(1 << TXEN)|(1 << TXCIE)|(0 << RXCIE)
	out UCSRB,r16
	; Configure the clock generation, USART polarity modes
	; odd parity
	; stop bits data bits configuration
	ldi r16,(1 << URSEL)|(1 << UPM1)|(1 << UPM0)|(0 << UMSEL)|(1 << USBS)|(0 << UCSZ0)|(0 << UCSZ1)
	out UCSRC,r16	 
	rcall LCD_init
	rjmp write_from_keypad

done:
	rjmp done
write_from_keypad:
        rjmp interrupt_setup
	
interrupt_setup:
	; make PD5 output (1.1)
	ldi r16,(1<<DDD5)
	out ddrd,r16
	;make portd.3 active high (1.1) and portd.2 active low (1.2)
	ldi r16,(1<<PD3)|(0<<PD2)
	out portd,r16
	;make PORTB.3-6 output
	ldi r16,(1<<DDC0)|(1<<DDC1)|(1<<DDC2)
	out DDRB,r16
	ldi r16,(1<<PC3)|(1<<PC4)|(1<<PC5)|(1<<PC6)
	out PORTB,r16
	; enable int1 interrupt
	ldi r16,(1<<INT1)|(1<<INT0)
	out GICR,r16
	;control how the interrupt is enabled
	ldi r16,(0<<ISC11)|(0<<ISC10)|(1<<ISC01)|(1<<ISC00)
	;ldi r16,(0<<ISC11)|(1<<ISC10)
	;ldi r16,(1<<ISC11)|(0<<ISC10)
	;ldi r16,(1<<ISC11)|(1<<ISC10)
	out MCUCR,r16
	sei
	rjmp done
	
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
	in	temp, DDRA		;we need to set the high nibble of DDRA while leaving
					;the other bits untouched. Using temp for that.
	sbr	temp, 0b11110000	;set high nibble in temp
	out	DDRA, temp		;write value to DDRA again
	in	temp, PORTA		;then get the port value
	cbr	temp, 0b11110000	;and clear the data bits
	cbr	argument, 0b00001111	;then clear the low nibble of the argument
					;so that no control line bits are overwritten
	or	temp, argument		;then set the data bits (from the argument) in the
					;Port value
	out	PORTA, temp		;and write the port value.
	sbi	PORTA, LCD_E		;now strobe E
	nop
	nop
	nop
	cbi	PORTA, LCD_E
	in	temp, DDRA		;get DDRA to make the data lines input again
	cbr	temp, 0b11110000	;clear data line direction bits
	out	DDRA, temp		;and write to DDRA
ret

lcd_putchar:
	push	argument		;save the argmuent (it's destroyed in between)
	in	temp, DDRA		;get data direction bits
	sbr	temp, 0b11110000	;set the data lines to output
	out	DDRA, temp		;write value to DDRA
	in	temp, PORTA		;then get the data from PORTA
	cbr	temp, 0b11111110	;clear ALL LCD lines (data and control!)
	cbr	argument, 0b00001111	;we have to write the high nibble of our argument first
					;so mask off the low nibble
	or	temp, argument		;now set the argument bits in the Port value
	out	PORTA, temp		;and write the port value
	sbi	PORTA, LCD_RS		;now take RS high for LCD char data register access
	sbi	PORTA, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PORTA, LCD_E
	pop	argument		;restore the argument, we need the low nibble now...
	cbr	temp, 0b11110000	;clear the data bits of our port value
	swap	argument		;we want to write the LOW nibble of the argument to
					;the LCD data lines, which are the HIGH port nibble!
	cbr	argument, 0b00001111	;clear unused bits in argument
	or	temp, argument		;and set the required argument bits in the port value
	out	PORTA, temp		;write data to port
	sbi	PORTA, LCD_RS		;again, set RS
	sbi	PORTA, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PORTA, LCD_E
	cbi	PORTA, LCD_RS
	in	temp, DDRA
	cbr	temp, 0b11110000	;data lines are input again
	out	DDRA, temp
ret

lcd_command:	;same as LCD_putchar, but with RS low!
	push	argument
	in	temp, DDRA
	sbr	temp, 0b11110000
	out	DDRA, temp
	in	temp, PORTA
	cbr	temp, 0b11111110
	cbr	argument, 0b00001111
	or	temp, argument

	out	PORTA, temp
	sbi	PORTA, LCD_E
	nop
	nop
	nop
	cbi	PORTA, LCD_E
	pop	argument
	cbr	temp, 0b11110000
	swap	argument
	cbr	argument, 0b00001111
	or	temp, argument
	out	PORTA, temp
	sbi	PORTA, LCD_E
	nop
	nop
	nop
	cbi	PORTA, LCD_E
	in	temp, DDRA
	cbr	temp, 0b11110000
	out	DDRA, temp
ret

LCD_getchar:
	in	temp, DDRA		;make sure the data lines are inputs
	andi	temp, 0b00001111	;so clear their DDR bits
	out	DDRA, temp
	sbi	PORTA, LCD_RS		;we want to access the char data register, so RS high
	sbi	PORTA, LCD_RW		;we also want to read from the LCD -> RW high
	sbi	PORTA, LCD_E		;while E is high
	nop
	in	temp, PinD		;we need to fetch the HIGH nibble
	andi	temp, 0b11110000	;mask off the control line data
	mov	return, temp		;and copy the HIGH nibble to return
	cbi	PORTA, LCD_E		;now take E low again
	nop				;wait a bit before strobing E again
	nop	
	sbi	PORTA, LCD_E		;same as above, now we're reading the low nibble
	nop
	in	temp, PinD		;get the data
	andi	temp, 0b11110000	;and again mask off the control line bits
	swap	temp			;temp HIGH nibble contains data LOW nibble! so swap
	or	return, temp		;and combine with previously read high nibble
	cbi	PORTA, LCD_E		;take all control lines low again
	cbi	PORTA, LCD_RS
	cbi	PORTA, LCD_RW
ret					;the character read from the LCD is now in return

LCD_getaddr:	;works just like LCD_getchar, but with RS low, return.7 is the busy flag
	in	temp, DDRA
	andi	temp, 0b00001111
	out	DDRA, temp
	cbi	PORTA, LCD_RS
	sbi	PORTA, LCD_RW
	sbi	PORTA, LCD_E
	nop
	in	temp, PinD
	andi	temp, 0b11110000
	mov	return, temp
	cbi	PORTA, LCD_E
	nop
	nop
	sbi	PORTA, LCD_E
	nop
	in	temp, PinD
	andi	temp, 0b11110000
	swap	temp
	or	return, temp
	cbi	PORTA, LCD_E
	cbi	PORTA, LCD_RW
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
	out	DDRA, temp
	
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

KeyFind:
	
	sbis PINB,3 ;A if zero
	rjmp keyA
	sbis PINB,4 ;B if zero
	rjmp keyB
	sbis PINB,5 ;C if zero
	rjmp keyC
	sbis PINB,6 ;D if zero
	rjmp keyD
	reti
keyA:
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,0
	sbis PINB,3
	call one
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,1
	sbis PINB,3
	call two
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,2
	sbis PINB,3
	call three
	cbi PORTB,0
	cbi PORTB,1
	cbi PORTB,2
	rjmp write
keyB:
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,0
	sbis PINB,4
	call four
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,1
	sbis PINB,4
	call five
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,2
	sbis PINB,4
	call six
	cbi PORTB,0
	cbi PORTB,1
	cbi PORTB,2
	rjmp write
keyC:
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,0
	sbis PINB,5
	call seven
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,1
	sbis PINB,5
	call eight
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,2
	sbis PINB,5
	call nine
	cbi PORTB,0
	cbi PORTB,1
	cbi PORTB,2
	rjmp write
keyD:
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,0
	sbis PINB,6
	call star
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,1
	sbis PINB,6
	call zero
	sbi PORTB,0
	sbi PORTB,1
	sbi PORTB,2
	cbi PORTB,2
	sbis PINB,6
	call square
	cbi PORTB,0
	cbi PORTB,1
	cbi PORTB,2
	rjmp write
	
write:
	out UDR,r19
	cbi PORTB,0
	cbi PORTB,1
	cbi PORTB,2
	reti
one:
	ldi r18,1
	ldi r19,0b00000110
	ldi argument,'1'
	call lcd_putchar
	;out UDR,r18
	ret
two:
	ldi r18,2
	ldi r19,0b01011011
	ldi argument,'2'
	call lcd_putchar
	;out UDR,r18
	ret
three:
	ldi r18,3
	ldi r19,0b01001111
	ldi argument,'3'
	call lcd_putchar
	;out UDR,r18
	ret
four:
	ldi r18,4
	ldi r19,0b01100110
	ldi argument,'4'
	call lcd_putchar
	;out UDR,r18
	ret
five:
	ldi r18,5
	ldi r19,65
	ldi argument,'5'
	call lcd_putchar
	;out UDR,r18
	ret
six:
	ldi r18,6
	ldi r19,0b01111101
	ldi argument,'6'
	call lcd_putchar
	;out UDR,r18
	ret
seven:
	ldi r18,7
	ldi r19,0b00000111
	ldi argument,'7'
	call lcd_putchar
	;out UDR,r18
	ret
eight:
	ldi r18,8
	ldi r19,0b01111111
	ldi argument,'8'
	call lcd_putchar
	;out UDR,r18
	ret
nine:
	ldi r18,9
	ldi r19,0b01101111
	ldi argument,'9'
	call lcd_putchar
	;out UDR,r18
	ret
star:
	ldi r18,10
	ldi r19,0b01110111
	ldi argument,'*'
	call lcd_putchar
	;out UDR,r18
	ret
zero:
	ldi r18,0
	ldi r19,0b00111111
	ldi argument,'0'
	call lcd_putchar
	;out UDR,r18
	ret
square:
	ldi r18,11
	ldi r19,0b01001111
	ldi argument,'#'
	call lcd_putchar
	;out UDR,r18
	ret
	
	
