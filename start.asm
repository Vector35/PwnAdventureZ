.include "defines.inc"

.segment "FIXED"

PROC start
	; Initialize CPU state
	sei
	cld
	ldx #$ff ; Set up stack
	txs
	inx ; X = 0

	; Disable interrupts until we are ready
	stx PPUCTRL  ; Disable NMI
	stx PPUMASK  ; Disable rendering
	stx DMC_FREQ ; Disable IRQ

	; Need to wait for PPU init, wait for the first vblank interval
	bit PPUSTATUS ; Clear initial vblank flag
wait1:
	bit PPUSTATUS
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

	; Ensure mapper has bank #0 at 0x8000-0xc000
	jsr reset_mapper

	; Initialize APU
	lda #$f
	sta SND_CHN

	ldy #$0
apuinit:
	lda apu_init_regs, y
	sta $4000, y
	iny
	cpy #$18
	bne apuinit

	; Wait for PPU to be fully ready
wait2:
	bit PPUSTATUS
	bpl wait2

	; Enable vblank interrupts
	lda PPUSTATUS
	lda #PPUCTRL_ENABLE_NMI
	sta ppu_settings
	sta PPUCTRL

	; Ensure CHR-RAM is cleared
	jsr clear_tiles

	; Start the game
	jsr main
	jmp start

apu_init_regs:
	.byte $30, $08, $00, $00
	.byte $30, $08, $00, $00
	.byte $80, $00, $00, $00
	.byte $30, $00, $00, $00
	.byte $00, $00, $00, $00
	.byte $00, $0f, $00, $40
.endproc


PROC nmi
	pha
	txa
	pha
	tya
	pha

	lda #1
	sta in_nmi

	; Update vblank count so that waiters will wake up
	ldx vblank_count
	inx
	stx vblank_count

	; Don't do anything with sprites when rendering is off
	lda rendering_enabled
	beq no_rendering

	; Copy updated sprites to the PPU using DMA
	lda #0
	sta OAMADDR
	lda #>sprites
	sta OAMDMA

	lda #0
	sta in_nmi

	pla
	tay
	pla
	tax
	pla
	rti

no_rendering:
	; When rendering is disabled, update audio in the NMI handler
	jsr update_audio

	lda #0
	sta in_nmi

	pla
	tay
	pla
	tax
	pla
	rti
.endproc


PROC wait_for_vblank
	pha
	txa
	pha
	tya
	pha

	; Update audio, unless rendering is disabled (in that case the audio update is
	; performed in the NMI handler to simply processing)
	lda rendering_enabled
	beq noaudioupdate
	jsr update_audio

noaudioupdate:
	; Update frames played
	ldx time_played + 5
	inx
	stx time_played + 5
	cpx #59
	bcc timeupdatedone
	lda #0
	sta time_played + 5

	; Update seconds played
	ldx time_played + 4
	inx
	stx time_played + 4
	cpx #59
	bcc timeupdatedone
	lda #0
	sta time_played + 4

	; Update minutes played
	ldx time_played + 3
	inx
	stx time_played + 3
	cpx #9
	bcc timeupdatedone
	lda #0
	sta time_played + 3
	ldx time_played + 2
	inx
	stx time_played + 2
	cpx #5
	bcc timeupdatedone
	lda #0
	sta time_played + 2

	; Update hours played
	ldx time_played + 1
	inx
	stx time_played + 1
	cpx #9
	bcc timeupdatedone
	lda #0
	sta time_played + 1
	ldx time_played
	inx
	stx time_played

timeupdatedone:
	lda PPUSTATUS
	lda vblank_count
loop:
	cmp vblank_count
	beq loop

	pla
	tay
	pla
	tax
	pla
	rts
.endproc


PROC wait_for_frame_count
loop:
	jsr wait_for_vblank
	dex
	bne loop
	rts
.endproc


PROC call_ptr
	jmp (ptr)
.endproc


PROC call_temp
	jmp (temp)
.endproc


PROC irq
	rti
.endproc


PROC zero_unused_stack_page
	tsx
	lda #0
loop:
	dex
	sta $0100, x
	cpx #0
	bne loop
	rts
.endproc


PROC nothing
	rts
.endproc


.zeropage
VAR ptr
	.word 0
VAR temp
	.word 0
VAR arg0
	.byte 0
VAR arg1
	.byte 0
VAR arg2
	.byte 0
VAR arg3
	.byte 0
VAR arg4
	.byte 0
VAR arg5
	.byte 0

VAR rendering_enabled
	.byte 0
VAR ppu_settings
	.byte 0

VAR vblank_count
	.byte 0

VAR in_nmi
	.byte 0


.segment "SPRITE"
; Map generator will use sprite memory as a working buffer, as the screen
; is off during map generation
VAR map_gen_buf
; Define RAM buffer for sprites that will be updated using DMA during vblank
VAR sprites
	.repeat 256
	.byte 0
	.endrepeat


.segment "STACK"
VAR scratch ; 32 bytes of temporary space
	.repeat $20
	.byte 0
	.endrepeat


.segment "VECTORS"
VAR version_hash
	.word 0, 0

	.word nmi
	.word start
	.word irq


.segment "CHR1"
.segment "CHR2"
.segment "CHR3"
.segment "CHR4"
.segment "CHR5"


.segment "CODEIDENT"
VAR current_bank
.byte 0

.segment "CHR1IDENT"
.byte 1

.segment "CHR2IDENT"
.byte 2

.segment "CHR3IDENT"
.byte 3

.segment "CHR4IDENT"
.byte 4

.segment "CHR5IDENT"
.byte 5

.segment "AUDIO0IDENT"
.byte 6

.segment "AUDIO1IDENT"
.byte 7

.segment "AUDIO2IDENT"
.byte 8

.segment "AUDIO3IDENT"
.byte 9

.segment "AUDIO4IDENT"
.byte 10

.segment "AUDIO5IDENT"
.byte 11

.segment "AUDIO6IDENT"
.byte 12

.segment "AUDIO7IDENT"
.byte 13

.segment "EXTRAIDENT"
.byte 14
