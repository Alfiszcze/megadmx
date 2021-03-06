# megadmx
Minimalistic DMX & ArtNet projects using the ATmega8

* ArtNet to DMX bridge using an ATmega8 and an ENC28J60
* DMX receiver with PWM outputs using an ATmega8 and a MAX481
* DMX receiver with PWM outputs using an ATtiny13 and a MAX481

In order to properly receive DMX data, the oscillator must run at
8MHz, either by supplying an external clock source or flashing the
fuse bytes to provide this via the internal oscillator.

A target to flash the respective controllers to an 8MHz internal
clock is provided in the respective `makefile`s.

## Hardware Setup

### Bridge
	MAX485 DI	<->	PD1 (UART TX)
	MAX485 DE/RE	<->	HIGH
	LED1		<->	PC5
	LED2		<->	PC4
	ENC CS		<->	PB0
	ENC INT		<->	PB1
	ENC SPI		<->	ATmega SPI
	ATmega SS	<->	HIGH
	ENC RST		<->	HIGH
	ENTER button	<->	PD0
	UP button	<->	PD2
	DOWN button	<->	PD3
	SSD1306 SPI	<->	ATmega SPI
	SSD1306 CS	<->	PC3
	SSD1306 DC	<->	PC2
	SSD1306 RES	<->	PC1

### Receiver (mega8)
	MAX481 RO	<->	PD0 (UART RX)
	MAX481 DI/DE/RE <->	LOW
	DMX ADDR	<->	PC012345 PD567
	PWM OUT		<->	PB123

### Receiver (tiny13)
	MAX481 RO	<->	PB3
	MAX481 DI/DE/RE <->	LOW
	PWM OUT		<->	PB01
	ADDRSWITCH	<->	PB2

	Hold the ADDRSWITCH down to set the channel addresses
	to the first two DMX channels with value > 127
