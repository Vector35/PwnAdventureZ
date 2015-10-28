.include "defines.inc"


.define SHARK_TILES $100
.define TILE1 0
.define TILE2 4
.define TILE3 8
.define SHARK_FIN 12

.segment "FIXED"

PROC init_shark_sprites
	LOAD_ALL_TILES SHARK_TILES + SPRITE_TILE_SHARK, shark_tiles
	rts
.endproc


.code

PROC shark_move
	ldx cur_enemy
	lda enemy_walk_direction, x
	and #3
	cmp #DIR_UP
	beq moveup
	cmp #DIR_DOWN
	beq movedown
	cmp #DIR_LEFT
	beq moveleft
;moveright
	inc enemy_x, x
	jmp done
moveup:
	dec enemy_y, x
	jmp done
movedown:
	inc enemy_y, x
	jmp done
moveleft:
	dec enemy_x, x
done:
	rts
.endproc

;The shark has two states
; swiming - where the fin is shown and is moving
; shooting - when the head is shown, stationary, and we are shooting lasers
PROC swiming_ai_tick
	lda #0
	sta arg0
	;is it time to shoot?
	ldx cur_enemy
	lda enemy_idle_time, x ;here we use idle time as a count down to fire
	cmp #0
	bne swiming
	;shooting
	inc shark_fire_count, x
	lda #$40
	cmp shark_fire_count, x
	beq resume ;once the shark_fire_count reaches 10 return to fin state
	lda #1
	cmp shark_fire_count, x
	beq change_sprite
	;lda #9
	;cmp shark_fire_count, x
	;beq fire
	rts
change_sprite:
	lda #>(shooting_sprites_for_state)
	sta enemy_sprite_state_high, x
	lda #<(shooting_sprites_for_state)
	sta enemy_sprite_state_low, x
	rts
;fire:
resume:
	lda #0
	sta shark_fire_count, x
	lda #>(swiming_sprites_for_state)
	sta enemy_sprite_state_high, x
	lda #<(swiming_sprites_for_state)
	sta enemy_sprite_state_low, x
	lda #$40
	ldx cur_enemy
	sta enemy_idle_time, x
	lda #1
	sta enemy_moved, x
	rts
swiming:
	dec enemy_idle_time, x
	;have we reached our target yet?
	lda enemy_walk_target, x
	cmp #0
	beq try_new_direction
	lda enemy_walk_direction, x
	and #3
	cmp #DIR_UP
	beq check_y
	cmp #DIR_DOWN
	beq check_y
check_x:
	ldy enemy_walk_target, x
	tya
	cmp enemy_x, x
	bne moving_tramp
	jmp try_new_direction
toidle_tramp3: jmp toidle_tramp
check_y:
	ldy enemy_walk_target, x
	tya
	cmp enemy_y, x
	bne moving_tramp
	; we have reached our target
try_new_direction:
	;give it maximum of 8 tries
	lda arg0
	cmp #8
	beq toidle_tramp
	inc arg0

	lda #4
	jsr rand_range

	cmp #DIR_UP
	bne not_up
	jsr get_enemy_tile
	;check if we are on the edge
	cpy #0
	beq try_new_direction
	dey
	jsr read_water_collision_at
	beq try_new_direction
	jsr get_enemy_tile
	dey
	tya
	asl
	asl
	asl
	asl
	ldx cur_enemy
	sta enemy_walk_target, x
	lda #DIR_UP
	sta enemy_walk_direction, x
	jmp moving
;shark_state_head_up_tramp:jmp shark_state_head_up
try_new_direction_tramp:  jmp try_new_direction
not_up:
	cmp #DIR_DOWN
	bne not_down
	jsr get_enemy_tile
	cpy #MAP_HEIGHT-1
	beq try_new_direction
	iny
	jsr read_water_collision_at
	beq try_new_direction
	jsr get_enemy_tile
	iny
	tya
	;convert tile to pixel
	asl
	asl
	asl
	asl
	ldx cur_enemy 
	sta enemy_walk_target, x
	lda #DIR_DOWN
	sta enemy_walk_direction, x
	jmp moving
moving_tramp: jmp moving
toidle_tramp: jmp toidle
not_down:
	cmp #DIR_RIGHT
	bne not_right
	jsr get_enemy_tile
	cpx #MAP_WIDTH-1
	beq try_new_direction_tramp
	inx
	jsr read_water_collision_at
	beq try_new_direction_tramp
	jsr get_enemy_tile
	inx
	txa
	asl
	asl
	asl
	asl
	ldx cur_enemy 
	sta enemy_walk_target, x
	lda #DIR_RIGHT
	sta enemy_walk_direction, x
	jmp moving
try_new_direction_tramp2:
	jmp try_new_direction_tramp
not_right:
	jsr get_enemy_tile
	cpx #0
	beq try_new_direction_tramp
	dex
	jsr read_water_collision_at
	beq try_new_direction_tramp
	jsr get_enemy_tile
	dex
	txa
	asl
	asl
	asl
	asl
	ldx cur_enemy 
	sta enemy_walk_target, x
	lda #DIR_LEFT
	sta enemy_walk_direction, x
moving:
	ldx cur_enemy
	lda enemy_walk_direction, x
	and #3
	cmp #DIR_UP
	beq moveup
	cmp #DIR_DOWN
	beq movedown
	cmp #DIR_LEFT
	beq moveleft
;moveright
	lda enemy_walk_target, x
	cmp enemy_x, x
	beq try_new_direction_tramp2
	bcc try_new_direction_tramp2
	jmp moveok

moveleft:
	lda enemy_walk_target, x
	cmp enemy_x, x
	bcs try_new_direction_tramp2
	jmp moveok

moveup:
	lda enemy_walk_target, x
	cmp enemy_y, x
	bcs try_new_direction_tramp2
	jmp moveok

movedown:
	lda enemy_walk_target, x
	cmp enemy_y, x
	beq try_new_direction_tramp2
	bcc try_new_direction_tramp2
	;jmp moveok

moveok:
	; Enemy has not reached target, try to move
	jsr shark_move
	lda #1
	ldx cur_enemy
	sta enemy_moved, x
	rts

toidle:
	lda #$20
	clc
	adc #$10
	jsr rand_range
	ldx cur_enemy
	sta enemy_idle_time, x
	rts
.endproc

PROC shark_collide
	;Player should never collide with shark
	rts
.endproc

.data

VAR shark_descriptor
	.word swiming_ai_tick
	.word remove_enemy
	.word shark_collide
	.word swiming_sprites_for_state
	.byte SPRITE_TILE_SHARK
	.byte 2 ;gun palette
	.byte 3, 1
	.byte 20

VAR shooting_sprites_for_state

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00

VAR swiming_sprites_for_state

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

TILES shark_tiles, 2, "tiles/enemies/shark/shark.chr", 16
