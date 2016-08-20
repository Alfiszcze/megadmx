.include "../m8def.inc"
.cseg
.org 0
rjmp setup

setup:
		cli
		; Create stack
	        ldi r16, low(RAMEND)
	        out SPL, r16
	        ldi r16, high(RAMEND)
	        out SPH, r16

		; Set up PWM port (PB)
		ldi r16, 0b00001110
		out DDRB, r16
		ldi r16, 0x00
		out PORTB, r16

		; Set up UART/INPUT port (PD)
		ldi r16, 0b00000000
		out DDRD, r16
		ldi r16, 0b11100001
		out PORTD, r16

		; Set up INPUT port (PC)
		ldi r16, 0b00000000
		out DDRC, r16
		ldi r16, 0b00111111
		out PORTC, r16

		; Set up UART
		ldi r16, 1
		out UBRRL, r16
		ldi r16, (1 << RXEN)
		;out UCSRB, r16
		;ldi r16, (1 << URSEL) | (1 << UCSZ1)
		ldi r16, (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1) | (1 << USBS)
		out UCSRC, r16
		
		; Set up PWM channels

		sei

		; Run the main loop
		rjmp main

; 	Production main loop
main:
		rcall read_addr
		; Wait for BREAK
		rcall scan_break
main_reent:
		; In MAB, enable RX
		ldi r16, (1 << RXEN)	; 1C
		out UCSRB, r16		; 1C
		; MAB is at minimum 4 usec -> 32 cycles
		; Read startcode
		; Read bytes until address
		; Read bytes until framing error
		; Disengage RX
		ldi r16, 0		; 1C
		out UCSRB, r16		; 1C
		; Run rescan_break
		rcall rescan_break
		rjmp main_reent

scan_break:
		; 8 cycles per usec
		; 88 usec BREAK
		; => 704 cycles
		; -1 cycle setup
		ldi r17, 0		; 1C
scan_break_1:
		nop			; 1C
		nop			; 1C
		nop			; 1C
		nop			; 1C
		inc r17			; 1C
		sbis PINB, 0		; 1C (2C @ skip)
		rjmp scan_break_1	; 2C
		cpi r17, 88		; 1C
		; Test whether break condition met
		; else wait for next break and do it again
		brlo scan_break		; 1C if false, 2 if true
		; Return 4 cycles into MAB
		ret			; 4C

rescan_break:
		; First stop bit framing error, already 40 usec into BREAK
		; If any data in next 48 usec, run scan_break
		; Wait 384 cycles, then return for MAB
		ret

read_addr:
		; Clear address high byte
		ldi r16, 0
		mov r1, r16
		in r16, PINC
		in r17, PIND
		lsl r17
		brcc read_addr_1
		ldi r16, 1
		mov r1, r16
read_addr_1:
		andi r16, 0b00111111
		andi r17, 0b11000000
		or r16, r17
		mov r2, r16
		ret