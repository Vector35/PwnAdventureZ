.include "defines.inc"

.code

PROC start
	; Initialize CPU state
	sei
	cld
	ldx #$ff ; Set up stack
	txs
	inx ; X = 0

	; Disable interrupts until we are ready
	stx $2000 ; Disable NMI
	stx $2001 ; Disable rendering
	stx $4010 ; Disable IRQ

	; Need to wait for PPU init, wait for the first vblank interval
	bit $2002 ; Clear initial vblank flag
wait1:
	bit $2002
	bpl wait1

	; One vblank interval has passed, but we need to wait another before actually starting to render.  Clear
	; RAM now during this period

	; X is 0, set A to 0 as well and perform a RAM clear
	txa
clearmem:
	sta $0000, x
	sta $0100, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne clearmem

	; Initialize APU
	lda #$f
	sta $4015

	ldy #$0
apuinit:
	lda apu_init_regs, y
	sta $4000, y
	iny
	cpy #$18
	bne apuinit

	; Wait for PPU to be fully ready
wait2:
	bit $2002
	bpl wait2

	; Start the game
	jmp main

apu_init_regs:
	.byte $30, $08, $00, $00
	.byte $30, $08, $00, $00
	.byte $80, $00, $00, $00
	.byte $30, $00, $00, $00
	.byte $00, $00, $00, $00
	.byte $00, $0f, $00, $40
.endproc


PROC nmi
	rti
.endproc


PROC irq
	rti
.endproc


.segment "STACK"

.segment "HEADER"
	.byte "NES", $1a
	.byte 2 ; 32kb program ROM
	.byte 1 ; 8kb character ROM
	.byte 1 ; Mapper 0, horizontal
	.byte 0
	.byte 0
	.byte 0 ; NTSC
	.byte $10 ; No program RAM (internal RAM only)

.segment "VECTORS"

	.word nmi
	.word start
	.word irq

.segment "CHR0"
.segment "CHR1"
