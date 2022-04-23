 	processor 6502		;6507 shares the same instruction set
 	ORG $F000		;place code in ROM starting at this address

Init:
	;Background Color
	LDX #$B2		;loads the data to be sent to register X (color 11, hue 2)
	STX $0009		;places the data in register X to the COLUMBK address to set background color

	;Audio
	LDX #$A			;loads 10 into register X (will be a divisor of 10 to the 30 kHz frequency)
	STX $0017		;sets the first audio channel to a 3 kHz frequency
	LDX #1			;loads 1 into register X (will signify a pure tone)
	STX $0015		;sets the first audio channel to a pure tone
	JMP StartTone		;starts tone

Frame:
	LDX #%00000010		;loads the data to be sent to the register X (D1 is high)
	STX $0000		;places the data in register X to the VSYNC address
	REPEAT 3		;must hold VSYNC value for 3 scan lines
		STX $0002	;uses WSYNC to wait for the next start of the horizontal line
	REPEND
	LDX #0			;clears register X
	STX $0000		;clears the VSYNC signal

	REPEAT 37		;must wait for 37 scan lines
		STX $0002	;uses WSYNC to wait for the next start of the horizontal line
	REPEND

	STX $0001		;clears the VBLANK signal
	REPEAT 192		;drawing window is composed of 192 scan lines
		STX $0002	;uses WSYNC to wait for the next horizontal line
	REPEND

	LDX #%00000010		;loads the data to be sent to register X (D1 is high)
	STX $0001		;places the data in register X to the VBLANK address
	REPEAT 30		;must hold VBLANK value for 30 scan lines
		STX $0002	;uses WSYNC to wait for the next start of the horizontal line
	REPEND

	DEY			;decrements frame counter in Y register
	BEQ StartTone 		;if counter has reached 0, start tone
	CPY #15			;if counter reached 15 (half second)...
	BEQ StopTone		;...stop tone
	JMP Frame		;restarts Frame loop

StartTone:
	LDY #8			;loads register Y with volume
	STY $0019		;sets the volume on channel 1 from register Y
	LDY #30			;starts frame countdown on register Y (for 30 frames or 1 second)
	JMP Frame

StopTone:
	LDX #0			;sets volume 0 to register X
	STX $0019		;sets volume in channel 0 to value in X (0)
	JMP Frame

 	ORG $FFFC		;6507 will look in this address to initialize its Program Counter
Reset:
	.word Init 		;set the address to the start of the code
END
