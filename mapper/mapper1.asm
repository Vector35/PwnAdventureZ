.include "../defines.inc"

.segment "FIXED"

PROC reset_mapper
	; Reset the mapper write state
	lda #$80
	sta $8000

	; Init settings (8k CHR, 16k PRG, $8000 swap, horizontal)
	lda #$0f
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000

	; Map first bank into $8000, disable save RAM until accessing
	lda #$10
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000

	rts
.endproc


PROC bankswitch
	ora #$10
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	rts
.endproc


PROC has_save_ram
	lda #1
	rts
.endproc


PROC enable_save_ram
	lda #$00
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	rts
.endproc


PROC disable_save_ram
	lda #$10
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	rts
.endproc


PROC clear_slot_0
	jsr enable_save_ram
	ldx #0
	lda #0
clearloop:
	sta $6000, x
	sta $6100, x
	sta $6200, x
	sta $6300, x
	sta $6400, x
	sta $6500, x
	sta $6600, x
	sta $6700, x
	inx
	bne clearloop
	jsr disable_save_ram
	rts
.endproc


PROC clear_slot_1
	jsr enable_save_ram
	ldx #0
	lda #0
clearloop:
	sta $6800, x
	sta $6900, x
	sta $6a00, x
	sta $6b00, x
	sta $6c00, x
	sta $6d00, x
	sta $6e00, x
	sta $6f00, x
	inx
	bne clearloop
	jsr disable_save_ram
	rts
.endproc


PROC clear_slot_2
	jsr enable_save_ram
	ldx #0
	lda #0
clearloop:
	sta $7000, x
	sta $7100, x
	sta $7200, x
	sta $7300, x
	sta $7400, x
	sta $7500, x
	sta $7600, x
	sta $7700, x
	inx
	bne clearloop
	jsr disable_save_ram
	rts
.endproc


PROC clear_slot_3
	jsr enable_save_ram
	ldx #0
	lda #0
clearloop:
	sta $7800, x
	sta $7900, x
	sta $7a00, x
	sta $7b00, x
	sta $7c00, x
	sta $7d00, x
	sta $7e00, x
	sta $7f00, x
	inx
	bne clearloop
	jsr disable_save_ram
	rts
.endproc


PROC save_ram_to_slot_0
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $0000, x
	sta $6000, x
	; Skip stack page
	lda $0200, x
	sta $6200, x
	lda $0300, x
	sta $6300, x
	lda $0400, x
	sta $6400, x
	lda $0500, x
	sta $6500, x
	lda $0600, x
	sta $6600, x
	lda $0700, x
	sta $6700, x
	inx
	bne saveloop

	lda #'P'
	sta $6100
	lda #'w'
	sta $6101
	lda #'n'
	sta $6102
	lda #'Z'
	sta $6103

	jsr disable_save_ram
	rts
.endproc


PROC save_ram_to_slot_1
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $0000, x
	sta $6800, x
	; Skip stack page
	lda $0200, x
	sta $6a00, x
	lda $0300, x
	sta $6b00, x
	lda $0400, x
	sta $6c00, x
	lda $0500, x
	sta $6d00, x
	lda $0600, x
	sta $6e00, x
	lda $0700, x
	sta $6f00, x
	inx
	bne saveloop

	lda #'P'
	sta $6900
	lda #'w'
	sta $6901
	lda #'n'
	sta $6902
	lda #'Z'
	sta $6903

	jsr disable_save_ram
	rts
.endproc


PROC save_ram_to_slot_2
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $0000, x
	sta $7000, x
	; Skip stack page
	lda $0200, x
	sta $7200, x
	lda $0300, x
	sta $7300, x
	lda $0400, x
	sta $7400, x
	lda $0500, x
	sta $7500, x
	lda $0600, x
	sta $7600, x
	lda $0700, x
	sta $7700, x
	inx
	bne saveloop

	lda #'P'
	sta $7100
	lda #'w'
	sta $7101
	lda #'n'
	sta $7102
	lda #'Z'
	sta $7103

	jsr disable_save_ram
	rts
.endproc


PROC save_ram_to_slot_3
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $0000, x
	sta $7800, x
	; Skip stack page
	lda $0200, x
	sta $7a00, x
	lda $0300, x
	sta $7b00, x
	lda $0400, x
	sta $7c00, x
	lda $0500, x
	sta $7d00, x
	lda $0600, x
	sta $7e00, x
	lda $0700, x
	sta $7f00, x
	inx
	bne saveloop

	lda #'P'
	sta $7900
	lda #'w'
	sta $7901
	lda #'n'
	sta $7902
	lda #'Z'
	sta $7903

	jsr disable_save_ram
	rts
.endproc


PROC restore_ram_from_slot_0
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $6000, x
	sta $0000, x
	; Skip stack page
	lda $6200, x
	sta $0200, x
	lda $6300, x
	sta $0300, x
	lda $6400, x
	sta $0400, x
	lda $6500, x
	sta $0500, x
	lda $6600, x
	sta $0600, x
	lda $6700, x
	sta $0700, x
	inx
	bne saveloop

	jsr disable_save_ram
	rts
.endproc


PROC restore_ram_from_slot_1
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $6800, x
	sta $0000, x
	; Skip stack page
	lda $6a00, x
	sta $0200, x
	lda $6b00, x
	sta $0300, x
	lda $6c00, x
	sta $0400, x
	lda $6d00, x
	sta $0500, x
	lda $6e00, x
	sta $0600, x
	lda $6f00, x
	sta $0700, x
	inx
	bne saveloop

	jsr disable_save_ram
	rts
.endproc


PROC restore_ram_from_slot_2
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $7000, x
	sta $0000, x
	; Skip stack page
	lda $7200, x
	sta $0200, x
	lda $7300, x
	sta $0300, x
	lda $7400, x
	sta $0400, x
	lda $7500, x
	sta $0500, x
	lda $7600, x
	sta $0600, x
	lda $7700, x
	sta $0700, x
	inx
	bne saveloop

	jsr disable_save_ram
	rts
.endproc


PROC restore_ram_from_slot_3
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $7800, x
	sta $0000, x
	; Skip stack page
	lda $7a00, x
	sta $0200, x
	lda $7b00, x
	sta $0300, x
	lda $7c00, x
	sta $0400, x
	lda $7d00, x
	sta $0500, x
	lda $7e00, x
	sta $0600, x
	lda $7f00, x
	sta $0700, x
	inx
	bne saveloop

	jsr disable_save_ram
	rts
.endproc


PROC clear_slot
	cmp #1
	beq slot1
	cmp #2
	beq slot2
	cmp #3
	beq slot3
	jmp clear_slot_0
slot1:
	jmp clear_slot_1
slot2:
	jmp clear_slot_2
slot3:
	jmp clear_slot_3
.endproc


PROC save_ram_to_slot
	cmp #1
	beq slot1
	cmp #2
	beq slot2
	cmp #3
	beq slot3
	jmp save_ram_to_slot_0
slot1:
	jmp save_ram_to_slot_1
slot2:
	jmp save_ram_to_slot_2
slot3:
	jmp save_ram_to_slot_3
.endproc


PROC restore_ram_from_slot
	cmp #1
	beq slot1
	cmp #2
	beq slot2
	cmp #3
	beq slot3
	jmp restore_ram_from_slot_0
slot1:
	jmp restore_ram_from_slot_1
slot2:
	jmp restore_ram_from_slot_2
slot3:
	jmp restore_ram_from_slot_3
.endproc


PROC is_save_slot_valid
	; Check offset $100 in save slot (which corresponds to the stack area, which is not
	; copied during save)
	jsr enable_save_ram

	asl
	asl
	asl
	ora #$61
	sta ptr + 1
	lda #0
	sta ptr
	ldy #0
	lda (ptr), y
	cmp #'P'
	bne notvalid
	iny
	lda (ptr), y
	cmp #'w'
	bne notvalid
	iny
	lda (ptr), y
	cmp #'n'
	bne notvalid
	iny
	lda (ptr), y
	cmp #'Z'

notvalid:
	php
	jsr disable_save_ram
	plp
	rts
.endproc


.segment "HEADER"
	.byte "NES", $1a
	.byte 8 ; 128kb program ROM
	.byte 0 ; CHR-RAM
	.byte $12 ; Mapper 1 (SNROM) with battery-backed RAM
	.byte 0
	.byte $01 ; 8kb PRG RAM
	.byte 0 ; NTSC
	.byte 0 ; Program RAM present


.segment "SRAM"
