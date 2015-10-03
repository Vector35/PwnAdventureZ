.include "defines.inc"

.code

PROC init_player_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_PLAYER, unarmed_player_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_INTERACT, interact_tiles

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_START
	beq dark
	cmp #MAP_CAVE_INTERIOR
	beq dark
	cmp #MAP_BLOCKY_PUZZLE
	beq dark
	cmp #MAP_BLOCKY_TREASURE
	beq dark

	LOAD_PTR light_player_palette
	jmp loadpal

dark:
	LOAD_PTR dark_player_palette

loadpal:
	lda ptr
	sta player_palette
	lda ptr + 1
	sta player_palette + 1
	jsr load_sprite_palette_0

	LOAD_PTR gun_palette
	jsr load_sprite_palette_2
	LOAD_PTR fire_palette
	jsr load_sprite_palette_3

	jsr update_player_sprite
	rts
.endproc


PROC update_player_sprite
	lda player_damage_flash_time
	beq normalpalette

	and #4
	bne flashoff

	LOAD_PTR player_damage_palette
	lda #4
	jsr load_single_palette

	dec player_damage_flash_time
	jmp palettedone

flashoff:
	dec player_damage_flash_time

normalpalette:
	lda player_palette
	sta ptr
	lda player_palette + 1
	sta ptr + 1
	lda #4
	jsr load_single_palette

palettedone:
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

	lda interaction_type
	cmp #INTERACT_NONE
	beq nointeract

	lda interaction_sprite_y
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
	lda interaction_sprite_x
	clc
	adc #8
	sta sprites + SPRITE_OAM_INTERACT + 3
	adc #8
	sta sprites + SPRITE_OAM_INTERACT + 7
	rts

nointeract:
	lda #$ff
	sta sprites + SPRITE_OAM_INTERACT
	sta sprites + SPRITE_OAM_INTERACT + 4
	rts
.endproc


PROC perform_player_move
	lda #0
	sta arg4

	lda player_direction
	sta temp_direction

	lda knockback_time
	beq normalmove

	lda knockback_control
	sta temp_controller
	jmp noactivate

normalmove:
	lda controller
	sta temp_controller

	lda temp_controller
	and #JOY_A
	beq noactivate

	lda interaction_type
	cmp #INTERACT_NONE
	beq nointeract

	lda attack_held
	bne startmove

	jsr activate_interaction

	lda #1
	sta attack_held
	jmp startmove

nointeract:
	jsr player_attack
	jmp startmove

noactivate:
	lda #0
	sta attack_held

startmove:
	lda attack_cooldown
	beq nocooldown
	dec attack_cooldown
nocooldown:
	lda temp_controller
	and #JOY_UP
	bne up
	lda temp_controller
	and #JOY_DOWN
	bne downpressed
	jmp checkhoriz

downpressed:
	jmp down

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
	lda #DIR_UP
	sta temp_direction
	; Collision detection
	tya
	and #15
	bne noupcollide
	jsr read_collision_up
	bne noupcollide
	ldx player_x
	txa
	and #15
	cmp #8
	bcc upsnapleft
	jmp upsnapright
upmoveinvalid:
	jsr get_player_tile
	stx possible_interaction_tile_x
	dey
	sty possible_interaction_tile_y
	lda player_up_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq upnotinteract
	sta interaction_type
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	beq interactionattop
	dey
interactionattop:
	jsr set_interaction_pos
upnotinteract:
	jmp checkhoriz
upsnapleft:
	lda temp_controller
	and #JOY_LEFT | JOY_RIGHT
	bne upmoveinvalid
	jsr read_collision_up_direct
	beq upmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp left
upsnapright:
	lda controller
	and #JOY_LEFT | JOY_RIGHT
	bne upmoveinvalid
	jsr read_collision_right
	beq upmoveinvalid
	jsr read_collision_up_right
	beq upmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp right
noupcollide:
	; Move OK
	ldy player_y
	dey
	sty player_y
	lda knockback_time
	bne noupdirchange
	lda #DIR_RUN_UP
	sta player_direction
noupdirchange:
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
	lda #DIR_DOWN
	sta temp_direction
	; Collision detection
	tya
	and #15
	bne nodowncollide
	jsr read_collision_down
	bne nodowncollide
	ldx player_x
	txa
	and #15
	cmp #8
	bcc downsnapleft
	jmp downsnapright
downmoveinvalid:
	jsr get_player_tile
	stx possible_interaction_tile_x
	iny
	sty possible_interaction_tile_y
	lda player_down_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq downnotinteract
	sta interaction_type
	jsr get_player_tile
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	iny
	jsr set_interaction_pos
downnotinteract:
	jmp checkhoriz
downsnapleft:
	lda temp_controller
	and #JOY_LEFT | JOY_RIGHT
	bne downmoveinvalid
	jsr read_collision_down_direct
	beq downmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp left
downsnapright:
	lda controller
	and #JOY_LEFT | JOY_RIGHT
	bne downmoveinvalid
	jsr read_collision_right
	beq downmoveinvalid
	jsr read_collision_down_right
	beq downmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp right
nodowncollide:
	; Move OK
	ldy player_y
	iny
	sty player_y
	lda knockback_time
	bne nodowndirchange
	lda #DIR_RUN_DOWN
	sta player_direction
nodowndirchange:
	lda #1
	sta arg4
	jmp checkhoriz

checkhoriz:
	lda temp_controller
	and #JOY_LEFT
	bne left
	lda temp_controller
	and #JOY_RIGHT
	bne rightpressed
	jmp movedone

rightpressed:
	jmp right

left:
	; Check for left of map
	ldx player_x
	bne notleftbounds
	jmp transitionleft
notleftbounds:
	lda #DIR_LEFT
	sta temp_direction
	; Collision detection
	txa
	and #15
	bne noleftcollide
	jsr read_collision_left
	bne noleftcollide
	ldx player_y
	txa
	and #15
	cmp #8
	bcc leftsnaptop
	jmp leftsnapbot
leftmoveinvalid:
	jsr get_player_tile
	dex
	stx possible_interaction_tile_x
	sty possible_interaction_tile_y
	lda player_left_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq leftnotinteract
	sta interaction_type
	jsr get_player_tile
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	dex
	jsr set_interaction_pos
leftnotinteract:
	jmp movedone
leftsnaptop:
	lda temp_controller
	and #JOY_UP | JOY_DOWN
	bne leftmoveinvalid
	jsr read_collision_left_direct
	beq leftmoveinvalid
	lda temp_controller
	and #(~JOY_LEFT) & $ff
	sta temp_controller
	jmp up
leftsnapbot:
	lda controller
	and #JOY_UP | JOY_DOWN
	bne leftmoveinvalid
	jsr read_collision_down
	beq leftmoveinvalid
	jsr read_collision_left_bottom
	beq leftmoveinvalid
	lda temp_controller
	and #(~JOY_LEFT) & $ff
	sta temp_controller
	jmp down
noleftcollide:
	; Move OK
	ldx player_x
	dex
	stx player_x
	lda knockback_time
	bne noleftdirchange
	lda #DIR_RUN_LEFT
	sta player_direction
noleftdirchange:
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
	lda #DIR_RIGHT
	sta temp_direction
	; Collision detection
	txa
	and #15
	bne norightcollide
	jsr read_collision_right
	bne norightcollide
	ldx player_y
	txa
	and #15
	cmp #8
	bcc rightsnaptop
	jmp rightsnapbot
rightmoveinvalid:
	jsr get_player_tile
	inx
	stx possible_interaction_tile_x
	sty possible_interaction_tile_y
	lda player_right_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq rightnotinteract
	sta interaction_type
	jsr get_player_tile
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	inx
	jsr set_interaction_pos
rightnotinteract:
	jmp movedone
rightsnaptop:
	lda temp_controller
	and #JOY_UP | JOY_DOWN
	bne rightmoveinvalid
	jsr read_collision_right_direct
	beq rightmoveinvalid
	lda temp_controller
	and #(~JOY_RIGHT) & $ff
	sta temp_controller
	jmp up
rightsnapbot:
	lda controller
	and #JOY_UP | JOY_DOWN
	bne rightmoveinvalid
	jsr read_collision_down
	beq rightmoveinvalid
	jsr read_collision_right_bottom
	beq rightmoveinvalid
	lda temp_controller
	and #(~JOY_RIGHT) & $ff
	sta temp_controller
	jmp down
norightcollide:
	; Move OK
	ldx player_x
	inx
	stx player_x
	lda knockback_time
	bne norightdirchange
	lda #DIR_RUN_RIGHT
	sta player_direction
norightdirchange:
	lda #1
	sta arg4
	jmp movedone

movedone:
	; Animate player if moving
	lda arg4
	beq notmoving

	lda #INTERACT_NONE
	sta interaction_type

	inc player_anim_frame
	jmp moveanimdone

notmoving:
	lda #7
	sta player_anim_frame

	lda knockback_time
	bne moveanimdone

	lda temp_direction
	and #3
	sta player_direction

moveanimdone:
	lda #0
	rts

transitionleft:
	lda knockback_time
	bne moveanimdone
	jsr fade_out
	dec cur_screen_x
	lda #(MAP_WIDTH - 1) * 16
	sta player_x
	lda #DIR_LEFT
	sta player_direction
	lda #1
	rts

transitionright:
	lda knockback_time
	bne moveanimdone
	jsr fade_out
	inc cur_screen_x
	lda #0
	sta player_x
	lda #DIR_RIGHT
	sta player_direction
	lda #1
	rts

transitionup:
	lda knockback_time
	bne moveanimdone
	jsr fade_out
	dec cur_screen_y
	lda #(MAP_HEIGHT - 1) * 16
	sta player_y
	lda #DIR_UP
	sta player_direction
	lda #1
	rts

transitiondown:
	lda knockback_time
	bne moveanimdone

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


PROC update_player_surroundings
	lda player_x
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	asl
	sta arg0

	lda player_y
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	asl
	sta arg1

	ldx arg0
	dex
	ldy arg1
	jsr set_ppu_addr_to_coord
	lda PPUDATA
	lda PPUDATA
	sta player_left_tile
	lda PPUDATA
	lda PPUDATA
	lda PPUDATA
	sta player_right_tile

	ldx arg0
	ldy arg1
	dey
	jsr set_ppu_addr_to_coord
	lda PPUDATA
	lda PPUDATA
	sta player_up_tile

	ldx arg0
	ldy arg1
	iny
	iny
	jsr set_ppu_addr_to_coord
	lda PPUDATA
	lda PPUDATA
	sta player_down_tile

	rts
.endproc


PROC get_player_tile
	lda player_x
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	tax

	lda player_y
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	tay

	rts
.endproc


PROC check_for_interactive_tile
	and #$fc
	sta temp
	ldx #0
loop:
	lda interactive_tile_values, x
	cmp temp
	beq found
	inx
	cpx #6
	bne loop

	lda #INTERACT_NONE
	rts

found:
	lda interactive_tile_types, x
	cmp #INTERACT_NONE
	bne ok
	rts
ok:
	sta arg0
	pha

	asl
	tax
	lda interaction_descriptors, x
	sta ptr
	lda interaction_descriptors + 1, x
	sta ptr + 1
	ldy #INTERACT_DESC_IS_VALID
	lda (ptr), y
	sta temp
	ldy #INTERACT_DESC_IS_VALID + 1
	lda (ptr), y
	sta temp + 1

	lda arg0
	ldx possible_interaction_tile_x
	ldy possible_interaction_tile_y
	jsr call_temp
	bne invalid

	pla
	rts

invalid:
	pla
	lda #INTERACT_NONE
	rts
.endproc


PROC set_interaction_pos
	txa
	asl
	asl
	asl
	asl
	sta interaction_sprite_x

	tya
	asl
	asl
	asl
	asl
	sta interaction_sprite_y

	rts
.endproc


PROC get_player_direction_bits
	lda controller
	and #JOY_LEFT | JOY_RIGHT | JOY_UP | JOY_DOWN
	beq nodir
	sta temp

	lda controller
	and #JOY_LEFT | JOY_RIGHT
	cmp #JOY_LEFT | JOY_RIGHT
	bne notbothhoriz

	lda temp
	and #JOY_LEFT | JOY_UP | JOY_DOWN
	sta temp

notbothhoriz:
	lda controller
	and #JOY_UP | JOY_DOWN
	cmp #JOY_UP | JOY_DOWN
	bne notbothvert

	lda temp
	and #JOY_LEFT | JOY_RIGHT | JOY_UP
	sta temp

notbothvert:
	lda temp
	rts

nodir:
	lda player_direction
	and #3
	cmp #DIR_LEFT
	bne notleft

	lda #JOY_LEFT
	rts

notleft:
	cmp #DIR_RIGHT
	bne notright

	lda #JOY_RIGHT
	rts

notright:
	cmp #DIR_UP
	bne notup

	lda #JOY_UP
	rts

notup:
	lda #JOY_DOWN
	rts
.endproc


PROC player_attack
	lda attack_cooldown
	beq nocooldown
	rts

nocooldown:
	lda attack_held
	beq notheld
	rts

notheld:
	lda player_x
	clc
	adc #7
	sta arg0
	lda player_y
	clc
	adc #7
	sta arg1
	lda #EFFECT_PLAYER_BULLET
	sta arg2
	jsr get_player_direction_bits
	sta arg3
	jsr create_effect

	cmp #$ff
	beq failed

	sta cur_effect
	jsr player_bullet_tick
	jsr player_bullet_tick

	lda #15
	sta attack_cooldown
	lda #1
	sta attack_held

failed:
	rts
.endproc


PROC activate_interaction
	lda interaction_type
	cmp #INTERACT_NONE
	bne ok
	rts

ok:
	asl
	tax
	lda interaction_descriptors, x
	sta ptr
	lda interaction_descriptors + 1, x
	sta ptr + 1
	ldy #INTERACT_DESC_ACTIVATE
	lda (ptr), y
	sta temp
	ldy #INTERACT_DESC_ACTIVATE + 1
	lda (ptr), y
	sta temp + 1

	jsr get_player_tile
	lda interaction_type
	ldx interaction_tile_x
	ldy interaction_tile_y
	jsr call_temp

	lda #INTERACT_NONE
	sta interaction_type
	rts
.endproc


PROC always_interactable
	lda #0
	rts
.endproc


PROC take_damage
	sta temp

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard
	jmp ok

hard:
	lda temp
	lsr
	clc
	adc temp
	sta temp
	jmp ok

veryhard:
	lda temp
	asl
	sta temp

ok:
	lda player_health
	sec
	sbc temp
	bcc dead
	sta player_health

	lda #30
	sta player_damage_flash_time
	rts

dead:
	lda #0
	sta player_health
	rts
.endproc


PROC bullet_hit_enemy
	lda #10
	jsr enemy_damage

	jsr player_bullet_tick

	ldx cur_effect
	dec effect_x, x
	dec effect_x, x
	dec effect_x, x
	dec effect_y, x
	dec effect_y, x
	dec effect_y, x
	lda #EFFECT_PLAYER_BULLET_DAMAGE
	sta effect_type, x
	lda #SPRITE_TILE_BULLET_DAMAGE
	sta effect_tile, x
	lda #0
	sta effect_time, x

	rts
.endproc


PROC bullet_hit_world
	ldx cur_effect
	dec effect_x, x
	dec effect_y, x
	lda #EFFECT_PLAYER_BULLET_HIT
	sta effect_type, x
	lda #SPRITE_TILE_BULLET_HIT
	sta effect_tile, x
	lda #0
	sta effect_time, x
	rts
.endproc


PROC player_bullet_tick
	ldx cur_effect
	lda effect_direction, x
	and #JOY_LEFT
	beq notleft

	dec effect_x, x
	dec effect_x, x
	dec effect_x, x

notleft:
	lda effect_direction, x
	and #JOY_RIGHT
	beq notright

	inc effect_x, x
	inc effect_x, x
	inc effect_x, x

notright:
	lda effect_direction, x
	and #JOY_UP
	beq notup

	dec effect_y, x
	dec effect_y, x
	dec effect_y, x

notup:
	lda effect_direction, x
	and #JOY_DOWN
	beq notdown

	inc effect_y, x
	inc effect_y, x
	inc effect_y, x

notdown:
	rts
.endproc


PROC player_bullet_hit_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #8
	bne done
	jsr remove_effect
done:
	rts
.endproc


.zeropage
VAR player_x
	.byte 0
VAR player_y
	.byte 0

VAR player_health
	.byte 0


.segment "TEMP"
VAR temp_direction
	.byte 0
VAR temp_controller
	.byte 0

VAR interactive_tile_types
	.byte 0, 0, 0, 0, 0, 0
VAR interactive_tile_values
	.byte 0, 0, 0, 0, 0, 0

VAR player_direction
	.byte 0
VAR player_anim_frame
	.byte 0

VAR player_damage_flash_time
	.byte 0
VAR player_palette
	.word 0

VAR player_left_tile
	.byte 0
VAR player_right_tile
	.byte 0
VAR player_up_tile
	.byte 0
VAR player_down_tile
	.byte 0

VAR interaction_type
	.byte 0
VAR interaction_sprite_x
	.byte 0
VAR interaction_sprite_y
	.byte 0
VAR interaction_tile_x
	.byte 0
VAR interaction_tile_y
	.byte 0

VAR possible_interaction_tile_x
	.byte 0
VAR possible_interaction_tile_y
	.byte 0

VAR attack_held
	.byte 0
VAR attack_cooldown
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

VAR player_damage_palette
	.byte $0f, $20, $10, $2d

VAR gun_palette
	.byte $0f, $00, $10, $20
VAR fire_palette
	.byte $0f, $06, $16, $37

VAR interaction_descriptors
	.word starting_chest_descriptor
	.word blocky_urn 
	.word blocky_bigdoor
	.word blocky_chest

VAR player_bullet_descriptor
	.word player_bullet_tick
	.word nothing
	.word bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_bullet_hit_descriptor
	.word player_bullet_hit_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_BULLET_HIT, 0
	.byte 2
	.byte 0, 0

VAR player_bullet_damage_descriptor
	.word player_bullet_hit_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_BULLET_DAMAGE, 0
	.byte 3
	.byte 0, 0

TILES unarmed_player_tiles, 2, "tiles/characters/player/unarmed.chr", 32
TILES interact_tiles, 2, "tiles/interact.chr", 8
