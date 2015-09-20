.include "defines.inc"

.define SCRATCH_TOP_OPENING_POS    0
.define SCRATCH_BOT_OPENING_POS    1
.define SCRATCH_LEFT_OPENING_POS   2
.define SCRATCH_RIGHT_OPENING_POS  3
.define SCRATCH_TOP_OPENING_SIZE   4
.define SCRATCH_BOT_OPENING_SIZE   5
.define SCRATCH_LEFT_OPENING_SIZE  6
.define SCRATCH_RIGHT_OPENING_SIZE 7
.define SCRATCH_CLUTTER_COUNT      8
.define SCRATCH_CLUTTER_SIZE       9

.code

PROC gen_cave_start
	jsr gen_cave_common
	rts
.endproc


PROC gen_cave_interior
	jsr gen_cave_common
	rts
.endproc


PROC gen_cave_common
	; Load cave tiles
	LOAD_ALL_TILES $080, cave_border_tiles

	; Load cave palette
	LOAD_PTR cave_palette
	jsr load_background_game_palette

	; Generate parameters for map generation
	jsr gen_map_opening_locations

	; Generate the sides of the cave wall
	lda #$80 + CAVE_WALL
	jsr gen_left_wall_large
	lda #$80 + CAVE_WALL
	jsr gen_right_wall_large
	lda #$80 + CAVE_WALL
	jsr gen_top_wall_large
	lda #$80 + CAVE_WALL
	jsr gen_bot_wall_large

	lda #$80 + CAVE_INTERIOR
	jsr gen_walkable_path

	; Create clutter in the middle of the cave
	lda #5
	jsr genrange_cur
	sta clutter_count

clutterloop:
	lda clutter_count
	bne placeclutter
	jmp clutterend
placeclutter:

	lda #4
	jsr genrange_cur
	sta clutter_size

	lda #8
	sta arg5

cluttertry:
	; Generate clutter position
	lda #11
	jsr genrange_cur
	clc
	adc #2
	sta arg0

	lda #8
	jsr genrange_cur
	clc
	adc #2
	sta arg1

	lda clutter_size
	cmp #0
	beq smallclutter

	ldx arg0
	inx
	stx arg2
	ldy arg1
	iny
	sty arg3
	jmp checkclutter

smallclutter:
	lda arg0
	sta arg2
	lda arg1
	sta arg3

checkclutter:
	; Check to ensure clutter isn't blocking anything.  It must be surrounded with the
	; same type of blank space (not critical path, or all critical path) to ensure that
	; it will not block all paths to exits
	ldx arg0
	dex
	ldy arg1
	dey
	jsr read_gen_map
	cmp #0
	beq clutterblank
	cmp #$80 + CAVE_INTERIOR
	bne clutterblock
clutterblank:
	sta arg4

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg1
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg1
	iny
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	ldy arg1
	iny
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg3
	iny
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	; Clutter is not blocking any paths, place it now
	lda #$80 + CAVE_WALL
	jsr fill_map_box
	jmp nextclutter

clutterblock:
	; Clutter was blocking, try again up to a max number of tries
	ldx arg5
	dex
	stx arg5
	beq nextclutter
	jmp cluttertry

nextclutter:
	ldx clutter_count
	dex
	stx clutter_count
	jmp clutterloop
clutterend:

	lda #$80
	jsr process_rock_sides

	rts
.endproc


PROC process_rock_sides
	sta rock_tile_base
	clc
	adc #CAVE_INTERIOR
	sta rock_tile_interior
	lda rock_tile_base
	clc
	adc #CAVE_WALL
	sta rock_tile_wall

	; Convert rock walls into the correct tile to account for surroundings.  This will
	; give them a contour along the edges.
	ldy #0
yloop:
	ldx #0
xloop:
	jsr process_rock_sides_for_tile
	inx
	cpx #MAP_WIDTH
	bne xloop
	iny
	cpy #MAP_HEIGHT
	bne yloop
	rts
.endproc


PROC process_rock_sides_for_tile
	txa
	sta arg0
	tya
	sta arg1

	; If the tile is empty space, don't touch it
	jsr read_gen_map
	cmp rock_tile_wall
	beq solid
	jmp done
solid:

	; Create a bit mask based on the 8 surrounding tiles, where the bit is set
	; if the tile is a cave wall or outside the map
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
	cmp #MAP_WIDTH
	beq out
	tax

	; Compute Y and check for bounds
	lda arg1
	clc
	adc arg3
	cmp #$ff
	beq out
	cmp #MAP_HEIGHT
	beq out
	tay

	; Read map and check for a cave wall
	jsr read_gen_map
	cmp rock_tile_base
	bcc next
	cmp rock_tile_interior
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
	lda arg4
	jsr get_cave_tile_for_sides

	; Write the new tile to the map
	ldx arg0
	ldy arg1
	jsr write_gen_map

done:
	lda arg0
	tax
	lda arg1
	tay
	rts
.endproc


.segment "FIXED"

PROC get_cave_tile_for_sides
	tay

	; Switch to bank that contains the mapping.  Must write to a memory location that
	; contains the same value being written due to bus conflicts.
	lda #2
	sta bankswitch + 2

	lda cave_tile_for_sides, y

	; Switch back to game code bank
	ldy #0
	sty bankswitch

	clc
	adc rock_tile_base
	rts
.endproc


.bss
VAR rock_tile_base
	.byte 0
VAR rock_tile_interior
	.byte 0
VAR rock_tile_wall
	.byte 0


.data
VAR cave_palette
	.byte $0f, $07, $17, $27
	.byte $0f, $07, $17, $27
	.byte $0f, $07, $17, $27
	.byte $0f, $07, $17, $27


TILES cave_border_tiles, 2, "tiles/cave/border.chr", 60

; Place a lookup table for determining which tile to use based on the 8 surrounding tiles.  This
; is represented with a bit field, with $80 representing the top left and $01 representing the
; bottom right.  Place this into the segment with the tiles as it will need to be aligned to
; a 256 byte boundary for access, and we don't want to waste space in the main data segment.
.segment "CHR2"
	.align 256
VAR cave_tile_for_sides
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $00
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $04
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $08
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $0c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $10
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_LEFT, CAVE_INNER_BOT_LEFT ; $14
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $18
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_OUTER_BOT_CENTER ; $1c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $20
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $24
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $28
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $2c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $30
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_LEFT, CAVE_INNER_BOT_LEFT ; $34
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $38
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_OUTER_BOT_CENTER ; $3c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $40
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $44
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $48
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $4c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $50
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $54
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $58
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $5c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $60
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $64
	.byte CAVE_INNER_TOP_RIGHT, CAVE_INNER_TOP_RIGHT, CAVE_INNER_SINGLE, CAVE_OUTER_CENTER_RIGHT ; $68
	.byte CAVE_INNER_TOP_RIGHT, CAVE_INNER_TOP_RIGHT, CAVE_INNER_SINGLE, CAVE_OUTER_CENTER_RIGHT ; $6c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $70
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $74
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $78
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_OUTER_BOT_RIGHT ; $7c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $80
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $84
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $88
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $8c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $90
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_LEFT, CAVE_INNER_BOT_LEFT ; $94
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $98
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_OUTER_BOT_CENTER ; $9c
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $a0
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $a4
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $a8
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_RIGHT ; $ac
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $b0
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_BOT_LEFT, CAVE_INNER_BOT_LEFT ; $b4
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $b8
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_OUTER_BOT_CENTER ; $bc
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $c0
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $c4
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $c8
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $cc
	.byte CAVE_INNER_TOP_LEFT, CAVE_INNER_TOP_LEFT, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $d0
	.byte CAVE_INNER_TOP_LEFT, CAVE_INNER_TOP_LEFT, CAVE_OUTER_CENTER_LEFT, CAVE_OUTER_CENTER_LEFT ; $d4
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $d8
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_OUTER_BOT_LEFT ; $dc
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $e0
	.byte CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $e4
	.byte CAVE_INNER_TOP_RIGHT, CAVE_INNER_TOP_RIGHT, CAVE_INNER_SINGLE, CAVE_OUTER_CENTER_RIGHT ; $e8
	.byte CAVE_INNER_TOP_RIGHT, CAVE_INNER_TOP_RIGHT, CAVE_INNER_SINGLE, CAVE_OUTER_CENTER_RIGHT ; $ec
	.byte CAVE_INNER_TOP_LEFT, CAVE_INNER_TOP_LEFT, CAVE_INNER_SINGLE, CAVE_INNER_SINGLE ; $f0
	.byte CAVE_INNER_TOP_LEFT, CAVE_INNER_TOP_LEFT, CAVE_OUTER_CENTER_LEFT, CAVE_OUTER_CENTER_LEFT ; $f4
	.byte CAVE_OUTER_TOP_CENTER, CAVE_OUTER_TOP_CENTER, CAVE_INNER_SINGLE, CAVE_OUTER_TOP_RIGHT ; $f8
	.byte CAVE_OUTER_TOP_CENTER, CAVE_OUTER_TOP_CENTER, CAVE_OUTER_TOP_LEFT, CAVE_WALL ; $fc
