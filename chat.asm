;   This file is part of Pwn Adventure Z.

;   Pwn Adventure Z is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.

;   Pwn Adventure Z is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.

;   You should have received a copy of the GNU General Public License
;   along with Pwn Adventure Z.  If not, see <http://www.gnu.org/licenses/>.

.include "defines.inc"

.segment "FIXED"

PROC show_chat_text
	sta chat_bank
	lda ptr
	sta chat_ptr
	lda ptr + 1
	sta chat_ptr + 1

	lda current_bank
	pha
	lda #^do_show_chat_text
	jsr bankswitch
	jsr do_show_chat_text & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC write_chat_string
	lda current_bank
	pha
	lda chat_bank
	jsr bankswitch
	jsr write_string
	pla
	jsr bankswitch
	rts
.endproc


PROC read_chat_byte
	lda current_bank
	pha
	lda chat_bank
	jsr bankswitch
	ldy #0
	lda (ptr), y
	sta temp
	pla
	jsr bankswitch
	lda temp
	rts
.endproc


.segment "UI"

PROC do_show_chat_text
	; Copy the area that will contain the chat box to the secondary screen
	lda #14
	sta arg1

saveloop:
	jsr wait_for_vblank

	ldx #0
	ldy arg1
	jsr set_ppu_addr_to_coord

	lda PPUDATA

	ldy #0
savereadrowloop:
	lda PPUDATA
	sta scratch, y
	iny
	cpy #32
	bne savereadrowloop

	ldx #0
	lda arg1
	clc
	adc #32
	tay
	jsr set_ppu_addr_to_coord

	ldy #0
savewriterowloop:
	lda scratch, y
	sta PPUDATA
	iny
	cpy #32
	bne savewriterowloop

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy arg1
	iny
	sty arg1
	cpy #22
	bne saveloop

	; Save attributes
	ldy #0
	lda #$23
	sta PPUADDR
	lda #$c0
	sta PPUADDR
	lda PPUDATA
savepalloop1:
	lda PPUDATA
	sta scratch, y
	iny
	cpy #32
	bne savepalloop1

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy #0
	lda #$27
	sta PPUADDR
	lda #$c0
	sta PPUADDR
savewritepalloop1:
	lda scratch, y
	sta PPUDATA
	iny
	cpy #32
	bne savewritepalloop1

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy #0
	lda #$23
	sta PPUADDR
	lda #$e0
	sta PPUADDR
	lda PPUDATA
savepalloop2:
	lda PPUDATA
	sta scratch, y
	iny
	cpy #64
	bne savepalloop2

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy #0
	lda #$27
	sta PPUADDR
	lda #$e0
	sta PPUADDR
savewritepalloop2:
	lda scratch, y
	sta PPUDATA
	iny
	cpy #32
	bne savewritepalloop2

	jsr prepare_for_rendering
	jsr wait_for_vblank

	; Draw chat box
	lda #2
	sta arg0
	lda #14
	sta arg1
	lda #27
	sta arg2
	lda #21
	sta arg3
	jsr draw_large_box

	jsr prepare_for_rendering

	; Clear inside of box
	lda #15
	sta arg1
clearloop:
	jsr wait_for_vblank
	LOAD_PTR clear_chat_box_str
	ldx #3
	ldy arg1
	jsr write_string
	jsr prepare_for_rendering

	ldy arg1
	iny
	sty arg1
	cpy #21
	bne clearloop

	; Set palette in box
	lda #7
	sta arg5
palloop:
	jsr wait_for_vblank

	lda #1
	sta arg0
	lda arg5
	sta arg1
	sta arg3
	lda #6
	sta arg2
	lda #3
	sta arg4
	jsr set_box_palette

	jsr prepare_for_rendering
	jsr wait_for_vblank

	lda #7
	sta arg0
	lda arg5
	sta arg1
	sta arg3
	lda #13
	sta arg2
	lda #3
	sta arg4
	jsr set_box_palette

	jsr prepare_for_rendering

	ldy arg5
	iny
	sty arg5
	cpy #11
	bne palloop

	; Draw text
	lda chat_ptr
	sta ptr
	lda chat_ptr + 1
	sta ptr + 1

	jsr wait_for_vblank
	ldx #4
	ldy #16
	jsr write_chat_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	ldx #4
	ldy #17
	jsr write_chat_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	ldx #4
	ldy #18
	jsr write_chat_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	ldx #4
	ldy #19
	jsr write_chat_string
	jsr prepare_for_rendering

	lda ptr
	sta chat_ptr
	lda ptr + 1
	sta chat_ptr + 1

	; Show A sprite
	lda #163
	clc
	adc #7
	sta sprites + SPRITE_OAM_INTERACT
	sta sprites + SPRITE_OAM_INTERACT + 4
	lda #$f9
	sta sprites + SPRITE_OAM_INTERACT + 1
	lda #$fb
	sta sprites + SPRITE_OAM_INTERACT + 5
	lda #3
	sta sprites + SPRITE_OAM_INTERACT + 2
	sta sprites + SPRITE_OAM_INTERACT + 6
	lda #196
	clc
	adc #8
	sta sprites + SPRITE_OAM_INTERACT + 3
	adc #8
	sta sprites + SPRITE_OAM_INTERACT + 7

	; Wait for A to be pressed
waitfordepress:
	jsr wait_for_vblank
	lda controller
	cmp #0
	bne waitfordepress

waitloop:
	jsr wait_for_vblank
	lda controller
	and #JOY_A
	beq waitloop

	lda chat_ptr
	sta ptr
	lda chat_ptr + 1
	sta ptr + 1
	jsr read_chat_byte
	cmp #0
	bne notdone
	jmp done & $ffff

notdone:
	; Clear text in box
	lda #15
	sta arg1
nextclearloop:
	jsr wait_for_vblank
	LOAD_PTR clear_chat_box_str
	ldx #3
	ldy arg1
	jsr write_string
	jsr prepare_for_rendering

	ldy arg1
	iny
	sty arg1
	cpy #21
	bne nextclearloop

	; Draw next screen of text
	lda chat_ptr
	sta ptr
	lda chat_ptr + 1
	sta ptr + 1

	jsr wait_for_vblank
	ldx #4
	ldy #16
	jsr write_chat_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	ldx #4
	ldy #17
	jsr write_chat_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	ldx #4
	ldy #18
	jsr write_chat_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	ldx #4
	ldy #19
	jsr write_chat_string
	jsr prepare_for_rendering

	lda ptr
	sta chat_ptr
	lda ptr + 1
	sta chat_ptr + 1

	jmp waitfordepress & $ffff

done:
	; Restore attributes
	ldy #0
	lda #$27
	sta PPUADDR
	lda #$c0
	sta PPUADDR
	lda PPUDATA
restorepalloop1:
	lda PPUDATA
	sta scratch, y
	iny
	cpy #32
	bne restorepalloop1

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy #0
	lda #$23
	sta PPUADDR
	lda #$c0
	sta PPUADDR
restorewritepalloop1:
	lda scratch, y
	sta PPUDATA
	iny
	cpy #32
	bne restorewritepalloop1

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy #0
	lda #$27
	sta PPUADDR
	lda #$e0
	sta PPUADDR
	lda PPUDATA
restorepalloop2:
	lda PPUDATA
	sta scratch, y
	iny
	cpy #64
	bne restorepalloop2

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy #0
	lda #$23
	sta PPUADDR
	lda #$e0
	sta PPUADDR
restorewritepalloop2:
	lda scratch, y
	sta PPUDATA
	iny
	cpy #32
	bne restorewritepalloop2

	jsr prepare_for_rendering
	jsr wait_for_vblank

	; Restore tiles in saved area
	lda #14
	sta arg1

restoreloop:
	jsr wait_for_vblank

	ldx #0
	lda arg1
	clc
	adc #32
	tay
	jsr set_ppu_addr_to_coord

	lda PPUDATA

	ldy #0
restorereadrowloop:
	lda PPUDATA
	sta scratch, y
	iny
	cpy #32
	bne restorereadrowloop

	ldx #0
	ldy arg1
	jsr set_ppu_addr_to_coord

	ldy #0
restorewriterowloop:
	lda scratch, y
	sta PPUDATA
	iny
	cpy #32
	bne restorewriterowloop

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldy arg1
	iny
	sty arg1
	cpy #22
	bne restoreloop

	jsr prepare_for_rendering
	rts
.endproc


VAR clear_chat_box_str
	.byte "                        ", 0


.segment "TEMP"

VAR chat_ptr
	.word 0
VAR chat_bank
	.byte 0
