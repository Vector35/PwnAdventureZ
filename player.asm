.include "defines.inc"

.code

PROC init_player_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_PLAYER, unarmed_player_tiles

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_START
	beq dark
	cmp #MAP_CAVE_INTERIOR
	beq dark

	LOAD_PTR light_player_palette
	jmp loadpal

dark:
	LOAD_PTR dark_player_palette

loadpal:
	jsr load_sprite_palette_0

	jsr update_player_sprite
	rts
.endproc


PROC update_player_sprite
	lda player_anim_frame
	lsr
	lsr
	lsr
	and #1
	sta temp

	lda player_direction
	asl
	ora temp
	asl
	asl
	tax

	lda player_y
	clc
	adc #7
	sta sprites + SPRITE_OAM_PLAYER
	sta sprites + SPRITE_OAM_PLAYER + 4

	lda walking_sprites_for_state, x
	sta sprites + SPRITE_OAM_PLAYER + 1
	lda walking_sprites_for_state + 1, x
	sta sprites + SPRITE_OAM_PLAYER + 2
	lda walking_sprites_for_state + 2, x
	sta sprites + SPRITE_OAM_PLAYER + 5
	lda walking_sprites_for_state + 3, x
	sta sprites + SPRITE_OAM_PLAYER + 6

	lda player_x
	clc
	adc #8
	sta sprites + SPRITE_OAM_PLAYER + 3
	adc #8
	sta sprites + SPRITE_OAM_PLAYER + 7

	rts
.endproc


PROC perform_player_move
	lda controller
	and #JOY_UP
	bne up
	lda controller
	and #JOY_DOWN
	bne down
	jmp checkhoriz

up:
	; Check for cave entrance
	lda entrance_x
	asl
	asl
	asl
	asl
	cmp player_x
	bne notentrance
	lda entrance_y
	asl
	asl
	asl
	asl
	cmp player_y
	bne notentrance
	jmp transitionup
notentrance:
	; Check for top of map
	ldy player_y
	bne nottopbounds
	jmp transitionup
nottopbounds:
	; Collision detection
	tya
	and #15
	bne noupcollide
	jsr read_collision_up
	bne noupcollide
	jmp checkhoriz
noupcollide:
	; Move OK
	ldy player_y
	dey
	sty player_y
	lda #DIR_RUN_UP
	sta player_direction
	lda #1
	sta arg4
	jmp checkhoriz

down:
	; Check for bottom of map
	ldy player_y
	cpy #(MAP_HEIGHT - 1) * 16
	bcc notbotbounds
	jmp transitiondown
notbotbounds:
	; Collision detection
	tya
	and #15
	bne nodowncollide
	jsr read_collision_down
	bne nodowncollide
	jmp checkhoriz
nodowncollide:
	; Move OK
	ldy player_y
	iny
	sty player_y
	lda #DIR_RUN_DOWN
	sta player_direction
	lda #1
	sta arg4
	jmp checkhoriz

checkhoriz:
	lda controller
	and #JOY_LEFT
	bne left
	lda controller
	and #JOY_RIGHT
	bne right
	jmp movedone

left:
	; Check for left of map
	ldx player_x
	bne notleftbounds
	jmp transitionleft
notleftbounds:
	; Collision detection
	txa
	and #15
	bne noleftcollide
	jsr read_collision_left
	bne noleftcollide
	jmp movedone
noleftcollide:
	; Move OK
	ldx player_x
	dex
	stx player_x
	lda #DIR_RUN_LEFT
	sta player_direction
	lda #1
	sta arg4
	jmp movedone

right:
	; Check for right of map
	ldx player_x
	cpx #(MAP_WIDTH - 1) * 16
	bcc notrightbounds
	jmp transitionright
notrightbounds:
	; Collision detection
	txa
	and #15
	bne norightcollide
	jsr read_collision_right
	bne norightcollide
	jmp movedone
norightcollide:
	; Move OK
	ldx player_x
	inx
	stx player_x
	lda #DIR_RUN_RIGHT
	sta player_direction
	lda #1
	sta arg4
	jmp movedone

movedone:
	; Animate player if moving
	lda arg4
	beq notmoving

	inc player_anim_frame
	jmp moveanimdone

notmoving:
	lda #7
	sta player_anim_frame
	lda player_direction
	and #3
	sta player_direction

moveanimdone:
	lda #0
	rts

transitionleft:
	jsr fade_out
	dec cur_screen_x
	lda #(MAP_WIDTH - 1) * 16
	sta player_x
	lda #DIR_LEFT
	sta player_direction
	lda #1
	rts

transitionright:
	jsr fade_out
	inc cur_screen_x
	lda #0
	sta player_x
	lda #DIR_RIGHT
	sta player_direction
	lda #1
	rts

transitionup:
	jsr fade_out
	dec cur_screen_y
	lda #(MAP_HEIGHT - 1) * 16
	sta player_y
	lda #DIR_UP
	sta player_direction
	lda #1
	rts

transitiondown:
	jsr fade_out

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_INTERIOR
	bne notcaveexit

	jsr read_overworld_down
	and #$3f
	cmp #MAP_FOREST
	bne notcaveexit

	; Exiting cave, place player at cave entrance
	inc cur_screen_y
	jsr prepare_map_gen
	jsr gen_forest
	lda top_wall_right_extent
	asl
	asl
	asl
	asl
	sta player_y
	lda top_opening_pos
	clc
	adc #1
	asl
	asl
	asl
	asl
	sta player_x
	lda #DIR_DOWN
	sta player_direction
	lda #1
	rts

notcaveexit:
	; Normal exit down
	inc cur_screen_y
	lda #0
	sta player_y
	lda #DIR_DOWN
	sta player_direction
	lda #1
	rts
.endproc


.zeropage
VAR player_x
	.byte 0
VAR player_y
	.byte 0
VAR player_direction
	.byte 0
VAR player_anim_frame
	.byte 0


.data
VAR walking_sprites_for_state
	; Up
	.byte $1c + 1, $00
	.byte $1e + 1, $00
	.byte $1c + 1, $00
	.byte $1e + 1, $00
	; Left
	.byte $0a + 1, $40
	.byte $08 + 1, $40
	.byte $0a + 1, $40
	.byte $08 + 1, $40
	; Right
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	; Down
	.byte $18 + 1, $00
	.byte $1a + 1, $00
	.byte $18 + 1, $00
	.byte $1a + 1, $00
	; Run Up
	.byte $10 + 1, $00
	.byte $12 + 1, $00
	.byte $14 + 1, $00
	.byte $16 + 1, $00
	; Run Left
	.byte $0a + 1, $40
	.byte $08 + 1, $40
	.byte $0e + 1, $40
	.byte $0c + 1, $40
	; Run Right
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00
	; Run Down
	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

VAR dark_player_palette
	.byte $0f, $2d, $37, $07
VAR light_player_palette
	.byte $0f, $0f, $37, $07

TILES unarmed_player_tiles, 2, "tiles/characters/player/unarmed.chr", 32
