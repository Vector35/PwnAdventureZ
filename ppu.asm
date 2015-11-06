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

PROC disable_rendering
	; Wait for vblank to ensure it is safe to use the PPU
	jsr wait_for_vblank

	; Disable rendering but leave NMI on
	lda #0
	sta rendering_enabled

	lda PPUSTATUS
	lda #PPUCTRL_ENABLE_NMI
	sta PPUCTRL
	sta PPUMASK
	rts
.endproc


PROC enable_rendering
	; Set the rendering flag and wait for a vblank, this will upload the sprites
	; and ensure it is safe to turn on the rendering
	lda #1
	sta rendering_enabled
	jsr wait_for_vblank

	; Set PPU settings
	lda PPUSTATUS
	lda ppu_settings
	sta PPUCTRL
	; Enable rendering
	lda #PPUMASK_BACKGROUND | PPUMASK_SPRITES
	sta PPUMASK

	rts
.endproc


PROC wait_for_vblank_if_rendering
	lda rendering_enabled
	beq norender
	jsr wait_for_vblank
norender:
	rts
.endproc


PROC ensure_black_screen
	jsr wait_for_vblank
	ldx #$3f
	stx PPUADDR
	ldx #0
	stx PPUADDR
	lda #$0f
paletteloop:
	sta PPUDATA
	inx
	cpx #$20
	bne paletteloop
	rts
.endproc


PROC clear_tiles
; Should be called with rendering disabled
	jsr ensure_black_screen

	ldx #0
	stx PPUADDR
	ldy #0
	sty PPUADDR
	tya
clearloop:
	sta PPUDATA
	iny
	bne clearloop
	inx
	cpx #$20
	bne clearloop

	rts
.endproc


PROC clear_screen
; Should be called with rendering disabled

	; Clear sprites
	lda #$ff
	ldx #0
clearsprites:
	sta sprites, x
	inx
	bne clearsprites

	jsr ensure_black_screen

	ldx #$20
	stx PPUADDR
	ldy #0
	sty PPUADDR
	tya
clearloop:
	sta PPUDATA
	iny
	bne clearloop
	inx
	cpx #$28
	bne clearloop

	rts
.endproc


PROC clear_alt_screen
; Should be called with rendering disabled

	; Clear sprites
	lda #$ff
	ldx #0
clearsprites:
	sta sprites, x
	inx
	bne clearsprites

	ldx #$24
	stx PPUADDR
	ldy #0
	sty PPUADDR
	tya
clearloop:
	sta PPUDATA
	iny
	bne clearloop
	inx
	cpx #$28
	bne clearloop

	rts
.endproc


PROC set_ppu_addr_to_coord
	; Calculate address of write and set PPU address to it
	lda PPUSTATUS

	tya
	lsr
	lsr
	lsr
	and #$f
	ora #$20
	sta PPUADDR

	tya
	ror
	ror
	ror
	ror
	and #$e0
	sta temp
	txa
	clc
	adc temp
	sta PPUADDR

	rts
.endproc


PROC add_y_to_ptr
	tya
	clc
	adc ptr
	sta ptr
	lda #0
	adc ptr + 1
	sta ptr + 1
	rts
.endproc


PROC write_string
	jsr set_ppu_addr_to_coord

	; Write null terminated string to screen
	ldy #0
strloop:
	lda (ptr), y
	beq done
	sta PPUDATA
	iny
	jmp strloop

done:
	iny
	jsr add_y_to_ptr
	rts
.endproc


PROC write_tiles
	pha
	jsr set_ppu_addr_to_coord
	pla

	tax
	ldy #0
copyloop:
	lda (ptr), y
	sta PPUDATA
	iny
	dex
	bne copyloop

	jsr add_y_to_ptr
	rts
.endproc


PROC write_large_tile
	stx arg0
	sty arg1
	sta arg2

	and #3
	jsr set_tile_palette

	; Write tile data
	lda arg0
	asl
	tax
	lda arg1
	asl
	tay
	jsr set_ppu_addr_to_coord

	lda arg2
	and #$fc
	sta PPUDATA
	ora #$02
	sta PPUDATA

	lda arg0
	asl
	tax
	lda arg1
	asl
	tay
	iny
	jsr set_ppu_addr_to_coord

	lda arg2
	and #$fc
	ora #$01
	sta PPUDATA
	ora #$02
	sta PPUDATA

	rts
.endproc


PROC draw_large_box
	lda ppu_settings
	ora #PPUCTRL_ADD_32
	sta PPUCTRL

	ldx arg0
	lda #$1b
	jsr draw_until_arg3

	ldx arg2
	lda #$1a
	jsr draw_until_arg3

	lda ppu_settings
	sta PPUCTRL

	ldx arg0
	ldy arg1
	jsr set_ppu_addr_to_coord
	lda #$1c
	sta PPUDATA
	lda #$3c
	jsr draw_until_arg2
	lda #$1e
	sta PPUDATA

	ldx arg0
	ldy arg3
	jsr set_ppu_addr_to_coord
	lda #$1d
	sta PPUDATA
	lda #$3e
	jsr draw_until_arg2
	lda #$1f
	sta PPUDATA

	rts

draw_until_arg2:
	ldx arg0
	inx
horizloop:
	sta PPUDATA
	inx
	cpx arg2
	bne horizloop
	rts

draw_until_arg3:
	pha
	ldy arg1
	iny
	jsr set_ppu_addr_to_coord
	pla

	ldy arg1
	iny
vertloop:
	sta PPUDATA
	iny
	cpy arg3
	bne vertloop
	rts
.endproc


PROC set_tile_palette
	pha

	lda PPUSTATUS

	; Compute address of palette for this tile and set the PPU address to it
	tya
	lsr
	lsr
	and #$0c
	ora #$23
	sta ptr + 1
	sta PPUADDR

	tya
	asl
	asl
	and #$38
	ora #$c0
	sta ptr

	txa
	lsr
	clc
	adc ptr
	sta ptr
	sta PPUADDR

	; Read existing palette for surrounding tiles and reset PPU address
	lda PPUDATA
	lda PPUDATA
	sta temp
	lda ptr + 1
	sta PPUADDR
	lda ptr
	sta PPUADDR

	; Update palette for the requested tile
	tya
	and #1
	bne yodd

	txa
	and #1
	bne topright

	lda temp
	and #$fc
	sta temp
	pla
	ora temp
	jmp end

topright:
	lda temp
	and #$f3
	sta temp
	pla
asl2:
	asl
	asl
	ora temp
	jmp end

yodd:
	txa
	and #1
	bne botright

	lda temp
	and #$cf
	sta temp
	pla
	asl
	asl
	jmp asl2

botright:
	lda temp
	and #$3f
	sta temp
	pla
	clc
	ror
	ror
	ror
	ora temp

end:
	sta PPUDATA
	rts
.endproc


PROC set_box_palette
	ldy arg1
yloop:
	ldx arg0
xloop:
	lda arg4
	jsr set_tile_palette

	cpx arg2
	beq xdone
	inx
	jmp xloop
xdone:
	cpy arg3
	beq ydone
	iny
	jmp yloop
ydone:
	rts
.endproc


PROC load_palette
	lda PPUSTATUS
	lda #$3f
	sta PPUADDR
	lda #0
	sta PPUADDR
	tay
loadloop:
	lda (ptr), y
	sta PPUDATA
	sta active_palette, y
	iny
	cpy #$20
	bne loadloop
	rts
.endproc


PROC load_palette_darken
	sta temp

	lda PPUSTATUS
	lda #$3f
	sta PPUADDR
	lda #0
	sta PPUADDR
	tay
loadloop:
	lda (ptr), y
	sec
	sbc temp
	bcs ok
	lda #$0f
ok:
	sta PPUDATA
	iny
	cpy #$20
	bne loadloop
	rts
.endproc


PROC load_single_palette
	tay
	lda PPUSTATUS
	lda #$3f
	sta PPUADDR
	tya
	asl
	asl
	tax
	sta PPUADDR
	ldy #0
loadloop:
	lda (ptr), y
	sta PPUDATA
	sta active_palette, x
	inx
	iny
	cpy #4
	bne loadloop
	jsr add_y_to_ptr
	rts
.endproc


PROC animate_palette
	; Expects 8 pointers to palettes in ptr, current offset in Y, palette to update in arg0
	tya
	clc
	adc #2
	and #$e
	tay

	lda (ptr), y
	sta temp
	iny
	lda (ptr), y
	dey
	sta ptr + 1
	lda temp
	sta ptr

	txa
	pha
	tya
	pha
	lda arg0
	jsr load_single_palette
	pla
	tay
	pla
	tax

	rts
.endproc


PROC fade_in
	jsr wait_for_vblank

	; Set palette to black and enable rendering
	lda #$40
	jsr load_palette_darken
	jsr prepare_for_rendering

	jsr enable_rendering

	; Fade in the palettes over time
	ldx #3
	jsr wait_for_frame_count
	lda #$30
	jsr load_palette_darken
	jsr prepare_for_rendering

	ldx #3
	jsr wait_for_frame_count
	lda #$20
	jsr load_palette_darken
	jsr prepare_for_rendering

	ldx #3
	jsr wait_for_frame_count
	lda #$10
	jsr load_palette_darken
	jsr prepare_for_rendering

	ldx #3
	jsr wait_for_frame_count
	jsr load_palette
	jsr prepare_for_rendering

	rts
.endproc


PROC fade_out
	jsr wait_for_vblank

	; Read existing palette to scratch area
	LOAD_PTR scratch
	ldy #0
loadloop:
	lda active_palette, y
	sta scratch, y
	iny
	cpy #$20
	bne loadloop

	jsr prepare_for_rendering

	; Fade out the palette over time
	ldx #3
	jsr wait_for_frame_count
	lda #$10
	jsr load_palette_darken
	jsr prepare_for_rendering

	ldx #3
	jsr wait_for_frame_count
	lda #$20
	jsr load_palette_darken
	jsr prepare_for_rendering

	ldx #3
	jsr wait_for_frame_count
	lda #$30
	jsr load_palette_darken
	jsr prepare_for_rendering

	ldx #3
	jsr wait_for_frame_count
	lda #$40
	jsr load_palette_darken
	jsr prepare_for_rendering

	; All palettes are now black, disable rendering.
	jsr disable_rendering
.endproc


PROC prepare_for_rendering
	; Address updates change the current nametable, reset it
	lda ppu_settings
	sta PPUCTRL

	; Set scrolling so that (0,0) is top left of renderable part of screen
	lda #256 - 8
	sta PPUSCROLL
	lda #240 - 8
	sta PPUSCROLL
	rts
.endproc


PROC copy_tiles
	tax

	; Switch to bank that contains the tiles
	lda current_bank
	pha

	tya
	jsr bankswitch

	; Set PPU target address
	lda PPUSTATUS
	lda temp + 1
	sta PPUADDR
	lda temp
	sta PPUADDR

	; Copy the tiles into video memory
copyloop:
	ldy #0
tileloop:
	lda (ptr), y
	sta PPUDATA
	iny
	cpy #16
	bne tileloop
	lda ptr
	clc
	adc #16
	sta ptr
	lda ptr + 1
	adc #0
	sta ptr + 1
	dex
	bne copyloop

	; Switch back to old bank
	pla
	jsr bankswitch

	rts
.endproc


.segment "TEMP"

VAR active_palette
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0

VAR disable_sprites
	.byte 0
