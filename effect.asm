.include "defines.inc"

.code

PROC init_effect_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_BULLET, bullet_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_SPLAT, splat_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_ORB, orb_tiles
;	LOAD_ALL_TILES $100 + SPRITE_TILE_LASER, laser_tiles

	ldx #0
	lda #EFFECT_NONE
loop:
	sta effect_type, x
	inx
	cpx #EFFECT_MAX_COUNT
	bne loop

	rts
.endproc


PROC update_effects
	lda #0
	sta cur_effect

loop:
	ldx cur_effect
	lda effect_type, x
	cmp #EFFECT_NONE
	bne valid
	jmp next

valid:
	; Call the effect's tick function
	lda effect_type, x
	asl
	tay
	lda effect_descriptors, y
	sta ptr
	lda effect_descriptors + 1, y
	sta ptr + 1

	ldy #EFFECT_DESC_TICK
	lda (ptr), y
	sta temp
	ldy #EFFECT_DESC_TICK + 1
	lda (ptr), y
	sta temp + 1
	jsr call_temp

	; Ensure effect is still valid
	ldx cur_effect
	lda effect_type, x
	cmp #EFFECT_NONE
	bne collidepos
	jmp next

collidepos:
	; Compute collision check position
	lda effect_type, x
	asl
	tay
	lda effect_descriptors, y
	sta ptr
	lda effect_descriptors + 1, y
	sta ptr + 1

	lda effect_direction, x
	and #JOY_RIGHT
	bne colliderightpos
	lda effect_x, x
	sta effect_collide_x
	jmp checkvertpos
colliderightpos:
	ldy #EFFECT_DESC_COLLIDE_WIDTH
	lda (ptr), y
	clc
	adc effect_x, x
	sta effect_collide_x

checkvertpos:
	lda effect_direction, x
	and #JOY_DOWN
	bne collidedownpos
	lda effect_y, x
	sta effect_collide_y
	jmp checkcollide
collidedownpos:
	ldy #EFFECT_DESC_COLLIDE_HEIGHT
	lda (ptr), y
	clc
	adc effect_y, x
	sta effect_collide_y

	; Check for enemy collision
checkcollide:
	lda #0
	sta cur_enemy

enemyloop:
	ldx cur_enemy
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq nextenemy

	lda enemy_x, x
	sec
	sbc effect_collide_x
	cmp #$f0
	bcs xoverlapenemy
	jmp nextenemy

xoverlapenemy:
	lda enemy_y, x
	sec
	sbc effect_collide_y
	cmp #$f0
	bcs yoverlapenemy
	jmp nextenemy

yoverlapenemy:
	; Call the enemy collide function
	ldx cur_effect
	lda effect_type, x
	asl
	tay
	lda effect_descriptors, y
	sta ptr
	lda effect_descriptors + 1, y
	sta ptr + 1

	ldy #EFFECT_DESC_ENEMY_COLLIDE
	lda (ptr), y
	sta temp
	ldy #EFFECT_DESC_ENEMY_COLLIDE + 1
	lda (ptr), y
	sta temp + 1
	jsr call_temp

	; Ensure effect is still valid after callback
	ldx cur_effect
	lda effect_type, x
	cmp #EFFECT_NONE
	bne nextenemy
	jmp next

nextenemy:
	ldx cur_enemy
	inx
	stx cur_enemy
	cpx #ENEMY_MAX_COUNT
	bne enemyloop

	; Check for player collision
	lda player_x
	sec
	sbc effect_collide_x
	cmp #$f0
	bcs xoverlapplayer
	jmp noplayercollide

xoverlapplayer:
	lda player_y
	sec
	sbc effect_collide_y
	cmp #$f0
	bcs yoverlapplayer
	jmp noplayercollide

yoverlapplayer:
	; Call the player collide function
	ldx cur_effect
	lda effect_type, x
	asl
	tay
	lda effect_descriptors, y
	sta ptr
	lda effect_descriptors + 1, y
	sta ptr + 1

	ldy #EFFECT_DESC_PLAYER_COLLIDE
	lda (ptr), y
	sta temp
	ldy #EFFECT_DESC_PLAYER_COLLIDE + 1
	lda (ptr), y
	sta temp + 1
	jsr call_temp

	; Ensure effect is still valid after callback
	ldx cur_effect
	lda effect_type, x
	cmp #EFFECT_NONE
	bne noplayercollide
	jmp next

	; Check for world collision
noplayercollide:
	lda effect_collide_x
	lsr
	lsr
	lsr
	lsr
	tax
	lda effect_collide_y
	lsr
	lsr
	lsr
	lsr
	tay
	jsr read_projectile_collision_at
	bne next

	; World collision detected, issue callback
	ldx cur_effect
	lda effect_type, x
	asl
	tay
	lda effect_descriptors, y
	sta ptr
	lda effect_descriptors + 1, y
	sta ptr + 1

	ldy #EFFECT_DESC_WORLD_COLLIDE
	lda (ptr), y
	sta temp
	ldy #EFFECT_DESC_WORLD_COLLIDE + 1
	lda (ptr), y
	sta temp + 1
	jsr call_temp

next:
	ldx cur_effect
	inx
	stx cur_effect
	cpx #EFFECT_MAX_COUNT
	beq done
	jmp loop

done:
	rts
.endproc


PROC update_effect_sprites
	; NES only supports 8 sprites per scan line, so rotate priority of effect sprites
	; to ensure all of them get screen time.  This will create the classic flicker
	; effect when there is a lot going on.
	lda effect_sprite_rotation
	clc
	adc #7
	sta effect_sprite_rotation

	ldx #0
spriteloop:
	lda effect_type, x
	cmp #EFFECT_NONE
	bne ok
	jmp empty

ok:
	asl
	tay
	lda effect_descriptors, y
	sta ptr
	lda effect_descriptors + 1, y
	sta ptr + 1

	ldy #EFFECT_DESC_PALETTE
	lda (ptr), y
	sta arg0

	ldy #EFFECT_DESC_LARGE
	lda (ptr), y
	bne large

	txa
	clc
	adc effect_sprite_rotation
	and #EFFECT_MAX_COUNT - 1
	asl
	asl
	asl
	clc
	adc #SPRITE_OAM_EFFECTS
	tay

	lda effect_y, x
	clc
	adc #7
	sta sprites, y
	lda #$ff
	sta sprites + 4, y

	lda effect_x, x
	clc
	adc #8
	sta sprites + 3, y

	lda effect_tile, x
	clc
	adc #1
	sta sprites + 1, y

	lda arg0
	sta sprites + 2, y
	jmp next

large:
	txa
	clc
	adc effect_sprite_rotation
	and #EFFECT_MAX_COUNT - 1
	asl
	asl
	asl
	clc
	adc #SPRITE_OAM_EFFECTS
	tay

	lda effect_y, x
	clc
	adc #7
	sta sprites, y
	sta sprites + 4, y

	lda effect_x, x
	clc
	adc #8
	sta sprites + 3, y
	adc #8
	sta sprites + 7, y

	lda effect_tile, x
	clc
	adc #1
	sta sprites + 1, y
	adc #2
	sta sprites + 5, y

	lda arg0
	sta sprites + 2, y
	sta sprites + 6, y

	jmp next

empty:
	txa
	clc
	adc effect_sprite_rotation
	and #EFFECT_MAX_COUNT - 1
	asl
	asl
	asl
	clc
	adc #SPRITE_OAM_EFFECTS
	tay
	lda #$ff
	sta sprites, y
	sta sprites + 4, y

next:
	inx
	cpx #EFFECT_MAX_COUNT
	beq done
	jmp spriteloop

done:
	rts
.endproc


.segment "FIXED"

PROC remove_effect
	ldx cur_effect
	lda #EFFECT_NONE
	sta effect_type, x
	rts
.endproc

PROC create_effect
	; Find a free effect slot
	ldx next_effect_spawn_index
loop:
	lda effect_type, x
	cmp #EFFECT_NONE
	beq found
	inx
	cpx next_effect_spawn_index
	beq overwrite
	cpx #EFFECT_MAX_COUNT
	bne loop
	ldx #0
	cpx next_effect_spawn_index
	beq overwrite
	jmp loop

overwrite:
	; Unable to find an effect slot, try to overwrite a lower priority effect
	lda effect_type, x
	cmp arg2
	beq found
	bcs found
	inx
	cpx next_effect_spawn_index
	beq failed
	cpx #EFFECT_MAX_COUNT
	bne overwrite
	ldx #0
	cpx next_effect_spawn_index
	beq failed
	jmp overwrite

failed:
	; Failed to find a valid slot, don't create the effect
	lda #$ff
	rts

found:
	; Found a slot, add the effect
	lda arg0
	sta effect_x, x
	lda arg1
	sta effect_y, x
	lda arg2
	sta effect_type, x
	lda arg3
	sta effect_direction, x
	lda #0
	sta effect_time, x
	lda arg4
	sta effect_data_0, x
	lda arg5
	sta effect_data_1, x

	lda arg2
	asl
	tay
	lda effect_descriptors, y
	sta ptr
	lda effect_descriptors + 1, y
	sta ptr + 1
	ldy #EFFECT_DESC_TILE
	lda (ptr), y
	sta effect_tile, x

	txa
	clc
	adc #1
	cmp #EFFECT_MAX_COUNT
	bne nowrap
	lda #0
nowrap:
	sta next_effect_spawn_index
	txa
	rts
.endproc


.segment "TEMP"

VAR cur_effect
	.byte 0

VAR next_effect_spawn_index
	.byte 0

VAR effect_sprite_rotation
	.byte 0

VAR effect_collide_x
	.byte 0
VAR effect_collide_y
	.byte 0

VAR effect_type
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat

VAR effect_x
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat

VAR effect_y
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat

VAR effect_tile
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat

VAR effect_direction
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat

VAR effect_time
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat

;Laser uses to store fractional pixel
VAR effect_data_0
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat
;Laser uses to store accumulator
VAR effect_data_1
	.repeat EFFECT_MAX_COUNT
	.byte 0
	.endrepeat

; used to determine if delta x or delta y is larger one bit per EFFECT
VAR x_or_y_dominate
	.byte 0, 0

.data

VAR effect_descriptors
	.word player_bullet_descriptor
	.word player_lmg_bullet_descriptor
	.word player_ak_bullet_descriptor
	.word player_sniper_bullet_descriptor
	.word player_shotgun_bullet_descriptor
	.word player_left_bullet_descriptor
	.word player_right_bullet_descriptor
	.word drop_descriptor
	.word enemy_death_descriptor
	.word player_bullet_damage_descriptor
	.word player_bullet_hit_descriptor
	.word shark_laser_descriptor
	.word shark_laser_hit_descriptor
	.word shark_laser_damage_descriptor


TILES bullet_tiles, 2, "tiles/effects/bullet.chr", 6
TILES laser_tiles, 2, "tiles/effects/laser.chr", 7
