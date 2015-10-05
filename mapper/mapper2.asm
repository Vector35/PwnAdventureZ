.include "../defines.inc"

.segment "FIXED"

PROC reset_mapper
	lda #0
	sta bankswitch_table
	rts
.endproc


PROC bankswitch
	; Must write to a memory location that contains the same value being written due to bus conflicts.
	tay
	sta bankswitch_table, y
	rts
.endproc


PROC has_save_ram
	lda #0
	rts
.endproc


PROC enable_save_ram
	rts
.endproc


PROC disable_save_ram
	rts
.endproc


PROC clear_slot
	rts
.endproc


PROC save_ram_to_slot
	rts
.endproc


PROC restore_ram_from_slot
	rts
.endproc


PROC is_save_slot_valid
	lda #0
	rts
.endproc


PROC validate_saves
	rts
.endproc


PROC generate_minimap_cache
	rts
.endproc


PROC render_minimap
	lda #0
	sta arg1
genyloop:
	lda #0
	sta arg0
genxloop:
	ldx arg0
	ldy arg1
	jsr read_overworld_map_known_bank

	and #$3f
	jsr get_minimap_tile_for_type

	ldx arg0
	ldy arg1
	jsr write_minimap_tile

	ldx arg0
	inx
	stx arg0
	cpx #26
	beq xwrap
	jmp genxloop
xwrap:
	ldy arg1
	iny
	sty arg1
	cpy #22
	beq gendone
	jmp genyloop

gendone:
	; Draw contoured edges for rocks, lakes, and bases
	jsr process_minimap_border_sides

	; Generate cave entrance tiles
	lda #0
	sta arg1
caveyloop:
	lda #0
	sta arg0
cavexloop:
	ldx arg0
	ldy arg1
	jsr read_overworld_map_known_bank

	cmp #MAP_CAVE_INTERIOR
	beq cave
	cmp #MAP_CAVE_INTERIOR + $40
	beq cave
	cmp #MAP_STARTING_CAVE
	beq cave
	cmp #MAP_STARTING_CAVE + $40
	beq cave
	cmp #MAP_BLOCKY_CAVE
	beq cave
	cmp #MAP_BLOCKY_CAVE + $40
	beq cave
	cmp #MAP_LOST_CAVE
	beq cave
	cmp #MAP_LOST_CAVE + $40
	beq cave
	cmp #MAP_MINE_ENTRANCE
	beq cave
	cmp #MAP_MINE_ENTRANCE + $40
	beq cave
	jmp nextcave

cave:
	ldx arg0
	ldy arg1
	iny
	jsr read_overworld_map_known_bank
	and #$3f
	jsr is_map_type_forest
	beq nextcave

	lda #MINIMAP_TILE_CAVE_ENTRANCE
	ldx arg0
	ldy arg1
	jsr write_minimap_tile

nextcave:
	ldx arg0
	inx
	stx arg0
	cpx #26
	beq xwrapcave
	jmp cavexloop
xwrapcave:
	ldy arg1
	iny
	sty arg1
	cpy #22
	beq cavedone
	jmp caveyloop

cavedone:
	rts
.endproc


PROC process_minimap_border_sides
	; Convert borders into the correct tile to account for surroundings.  This will
	; give them a contour along the edges.
	ldy #0
yloop:
	ldx #0
xloop:
	jsr process_minimap_border_sides_for_tile
	inx
	cpx #26
	bne xloop
	iny
	cpy #22
	bne yloop
	rts
.endproc


PROC process_minimap_border_sides_for_tile
	txa
	sta arg0
	tya
	sta arg1

	; If the tile is empty space, don't touch it
	jsr read_minimap_tile
	cmp #MINIMAP_TILE_ROCK + SMALL_BORDER_CENTER
	beq checkrock
	cmp #MINIMAP_TILE_LAKE + SMALL_BORDER_CENTER
	beq checklake
	cmp #MINIMAP_TILE_BASE + SMALL_BORDER_CENTER
	beq checkbase
	jmp done

checkrock:
	lda #MINIMAP_TILE_ROCK
	sta border_tile_base
	lda #MINIMAP_TILE_ROCK + SMALL_BORDER_INTERIOR
	sta border_tile_interior
	jmp solid
checklake:
	lda #MINIMAP_TILE_LAKE
	sta border_tile_base
	lda #MINIMAP_TILE_LAKE + SMALL_BORDER_INTERIOR
	sta border_tile_interior
	jmp solid
checkbase:
	lda #MINIMAP_TILE_BASE
	sta border_tile_base
	lda #MINIMAP_TILE_BASE + SMALL_BORDER_INTERIOR
	sta border_tile_interior
	jmp solid

solid:
	; Create a bit mask based on the 8 surrounding tiles, where the bit is set
	; if the tile is a border wall or outside the map
	lda #0
	sta arg4
	lda #$80
	sta arg5

	lda #$ff
	sta arg3
yloop:
	lda #$ff
	sta arg2
xloop:
	; Skip center as we already know it is solid, and we have only 8 bits
	lda arg2
	cmp #0
	bne notcenter
	lda arg3
	cmp #0
	bne notcenter
	jmp skip

notcenter:
	; Compute X and check for bounds
	lda arg0
	clc
	adc arg2
	cmp #$ff
	beq out
	cmp #26
	beq out
	tax

	; Compute Y and check for bounds
	lda arg1
	clc
	adc arg3
	cmp #$ff
	beq out
	cmp #22
	beq out
	tay

	; Read map and check for a border wall
	jsr read_minimap_tile
	cmp border_tile_base
	bcc next
	cmp border_tile_interior
	beq next

out:
	; Solid, mark the bit
	lda arg4
	ora arg5
	sta arg4

next:
	; Move to next bit
	lda arg5
	lsr
	sta arg5

skip:
	; Go to next tile
	ldx arg2
	inx
	stx arg2
	cpx #2
	bne xloop

	ldy arg3
	iny
	sty arg3
	cpy #2
	bne yloop

	; The bit mask has been generated, look it up in the table to get the proper tile
	ldy arg4
	lda border_tile_for_sides, y
	lsr
	lsr
	clc
	adc border_tile_base

	; Write the new tile to the map
	ldx arg0
	ldy arg1
	jsr write_minimap_tile

done:
	lda arg0
	tax
	lda arg1
	tay
	rts
.endproc


PROC read_minimap_tile
	jsr set_ppu_addr_to_minimap_tile
	lda PPUDATA
	lda PPUDATA
	rts
.endproc


.data
VAR bankswitch_table
	.byte 0, 1, 2, 3, 4, 5, 6, 7

.segment "HEADER"
	.byte "NES", $1a
	.byte 8 ; 128kb program ROM
	.byte 0 ; CHR-RAM
	.byte $21 ; Mapper 2 (UNROM)
	.byte 0
	.byte 0
	.byte 0 ; NTSC
	.byte $10 ; No program RAM (internal RAM only)
