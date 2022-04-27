 	processor 6502									;6507 shares the same instruction set
 	ORG $F000												;place code in ROM starting at this address

Init:
	;Background Color
	LDX #$00												;loads the data to be sent to register X (color 11, hue 2)
	STX $0009												;places the data in register X to the COLUMBK address to set background color

Frame:
	LDX #%00000010									;loads the data to be sent to the register X (D1 is high)
	STX $0000												;places the data in register X to the VSYNC address
	REPEAT 3												;must hold VSYNC value for 3 scan lines
		STX $0002											;uses WSYNC to wait for the next start of the horizontal line
	REPEND
	LDX #0													;clears register X
	STX $0000												;clears the VSYNC signal

	REPEAT 37												;must wait for 37 scan lines
		STX $0002											;uses WSYNC to wait for the next start of the horizontal line
	REPEND

	;try to set horizontal position of sprite somewhere in the middle of the screen
	LDX #8													;loop wait
WaitForHorizontalPosition:
	DEX															;decrements counter
	BNE WaitForHorizontalPosition		;loops while timer hasn't reached zero
	STX $10													;resets player 0 position to this horizontal location

	STX $0001												;clears the VBLANK signal
	LDX #192												;drawing window is composed of 192 scan lines
	LDY #10													;Player sprite is 11 pixels tall

DrawingWindow:
	LDA #0													;clears accumulator
	CPX	#20													;check to see if we can start drawing sprite
	BCS	EndDrawingWindow						;not drawing sprite yet
	CPY #0													;check to see if we're done drawing sprite
	BMI EndDrawingWindow						;done drawing sprite
	LDA EnterpriseColor,Y						;loads sprite scanline color value
	STA $06													;sets player 0 sprite color
	LDA EnterpriseShape,Y						;loads sprite scanline value
	DEY															;next sprite scanline
EndDrawingWindow:
	STA	$1B													;sets player 0 sprite shape
	STX $0002												;uses WSYNC to wait for the next horizontal line
	DEX															;decrement scan line count
	BNE DrawingWindow								;next scan line

	LDX #%00000010									;loads the data to be sent to register X (D1 is high)
	STX $0001												;places the data in register X to the VBLANK address
	REPEAT 30												;must hold VBLANK value for 30 scan lines
		STX $0002											;uses WSYNC to wait for the next start of the horizontal line
	REPEND

	JMP Frame												;restarts Frame loop

;Start sprite data
EnterpriseShape:									;writing sprite in reverse scanline order, to avoid comparison cycles
	.byte %01000010									;all $96
	.byte %01111110									;bit 1 and 6: $04, the rest $08
	.byte %01011010									;bit 1 and 6: $42, bit 3 and 4: $08
	.byte %00011000									;all $08
	.byte %00011000									;all $08
	.byte %01111110									;all these pixels should be $08
	.byte %11111111									;all these pixels should be $08
	.byte %11111111									;same as above, can probably just hole for 2 lines instead of wasting the byte in rom?
	.byte %11111111									;most pixels should be $08, except for middle 2 (bits 3 and 4) which should be $04
	.byte %01111110									;these should also be $08
	.byte %00111100									;all these pixels should be $08
	
EnterpriseColor:
	.byte $96												;red
	.byte $08												;gray
	.byte $42												;blue
	.byte $08												;gray
	.byte $08												;gray
	.byte $08												;gray
	.byte $08												;gray
	.byte $08												;gray
	.byte $08												;gray
	.byte $08												;gray
	.byte $08												;gray

 	ORG $FFFC												;6507 will look in this address to initialize its Program Counter
Reset:
	.word Init 											;set the address to the start of the code
END
