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

PROC shark_laser_tick
	lda current_bank
	pha
	lda #^do_shark_laser_tick
	jsr bankswitch
	jsr do_shark_laser_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC swiming_ai_tick
	lda current_bank
	pha
	lda #^do_swiming_ai_tick
	jsr bankswitch
	jsr do_swiming_ai_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

.code

PROC laser_hit_player
	lda equipped_armor
	cmp #ITEM_TINFOIL_HAT
	bne noblock

	lda #4
	jsr rand_range
	cmp #0
	beq noblock

	ldx cur_effect
	lda effect_direction, x
	sta temp
	lsr
	lsr
	and #$30
	sta effect_direction, x
	lda temp
	asl
	asl
	and #$c0
	ora effect_direction, x
	sta effect_direction, x

	; Flip the x/y dominate flag
	lda cur_effect
	lsr
	lsr
	lsr
	tay ;y is 0 or 1 indicating the byte of x_or_y_dominate to bit check
	lda cur_effect
	and #7
	tax ;x is now position of taggle mask representing the bit to check
	lda toggle_mask2 & $ffff, x ; get the toggle mask
	eor x_or_y_dominate, y
	sta x_or_y_dominate, y

	ldx cur_effect
	lda #EFFECT_REFLECTED_LASER
	sta effect_type, x
	rts

noblock:
	lda #4
	jsr take_damage
	jsr shark_laser_tick
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

PROC laser_hit_world
	ldx cur_effect
	dec effect_x, x
	dec effect_y, x
	lda #EFFECT_SHARK_LASER_HIT
	sta effect_type, x
	lda #SPRITE_TILE_BULLET_HIT
	sta effect_tile, x
	lda #0
	sta effect_time, x
	rts
.endproc

PROC laser_hit_tick 
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #8
	bne done
	jsr remove_effect & $ffff
done:
	rts
.endproc

PROC shark_collide
	;Player should never collide with shark
	rts
.endproc

.segment "EXTRA"

PROC get_relative_player_direction
	;compare tile by tile to get a general direction
	;if player's x > enemy's x 
	ldx cur_enemy
	lda enemy_x, x
	lsr
	lsr
	lsr
	sta temp
	lda player_x
	lsr
	lsr
	lsr
	cmp temp ;if enemy_x > player_x
	bpl playerisright
	beq playerincolumn
playerisleft:
	lda #JOY_LEFT
	jmp check_col & $ffff
playerisright:
	lda #JOY_RIGHT
	jmp check_col & $ffff
playerincolumn:
	lda #0
check_col:
	sta arg0
	ldx cur_enemy
	lda enemy_y, x
	lsr
	lsr
	lsr
	sta temp
	lda player_y
	lsr
	lsr
	lsr
	cmp temp ;if enemy_y > player_y
	bmi playerisup
	beq playerinrow
playerisdown:
	lda #JOY_DOWN
	jmp done & $ffff
playerinrow:
	lda #0
	jmp done & $ffff
playerisup:
	lda #JOY_UP
done:
	ora arg0
	rts	
.endproc


PROC compute_fractional_pixel
	ldx cur_effect
	lda effect_x, x ;x1
	lsr
	lsr
	lsr
	lsr
	sta temp
	lda player_x ;x2
	lsr
	lsr
	lsr
	lsr
	cmp temp
	bmi x1_greater
x1_lessthan:
	sec
	sbc temp
	jmp calc_y & $ffff
x1_greater:
	sta arg0
	lda temp
	sec
	sbc arg0 ; x1 - x2 	; compute absolute difference of x1, and x2
calc_y:
	sta arg1
	lda effect_y, x
	lsr
	lsr
	lsr
	lsr
	sta temp
	lda player_y
	lsr
	lsr
	lsr
	lsr
	cmp temp ; y1
	bmi y1_greater		 ;compute absolute difference of y1 and y2
y1_lessthan:
	sec
	sbc temp
	jmp compute_dx & $ffff
y1_greater:
	sta arg0
	lda temp
	sec
	sbc arg0
compute_dx:
	sta temp
	; temp = |y1 - y2|
	; arg1 = |x1 - x2|
	cmp arg1 
	bmi x_greater
x_lessthan:
	lda cur_effect
	and #7
	tax
	lda toggle_mask_invert & $ffff, x
	tay
	lda cur_effect
	lsr
	lsr
	lsr
	tax
	tya
	and x_or_y_dominate, x
	sta x_or_y_dominate, x
	jmp store_fractional & $ffff
x_greater:
	lda cur_effect
	and #7
	tax
	lda toggle_mask2 & $ffff, x
	tay
	lda cur_effect
	lsr
	lsr
	lsr
	tax
	tya
	ora x_or_y_dominate, x
	sta x_or_y_dominate, x
store_fractional:
	ldy temp
	ldx arg1
	jsr lookup_fractional & $ffff
	ldx cur_effect
	sta effect_data_0, x
	rts
.endproc

PROC lookup_fractional
	LOAD_PTR fractional_pixel_lookup & $ffff
	tya
	asl
	asl
	asl
	asl
	sta temp
	txa
	clc
	adc temp
	tay
	jsr add_y_to_ptr
	ldy #0
	lda (ptr), y
	rts
.endproc

PROC fire_laser
	PLAY_SOUND_EFFECT effect_laser

	;create the effect
	jsr get_relative_player_direction & $ffff
	sta arg3
	ldx cur_enemy
	lda enemy_x, x
	clc
	adc arg4
	sta arg0
	lda enemy_y, x
	clc
	adc arg5
	sta arg1
	lda #EFFECT_SHARK_LASER
	sta arg2
	;record the players current TILE position this will be used as the dest
	jsr create_effect & $ffff

	cmp #$ff
	beq failed1
	sta cur_effect
	jsr compute_fractional_pixel & $ffff

	jsr shark_laser_tick
	jsr shark_laser_tick

failed1:

	;create the effect
	jsr get_relative_player_direction & $ffff
	sta arg3
	ldx cur_enemy
	lda enemy_x, x
	clc
	adc arg4
	sta arg0
	lda enemy_y, x
	clc
	adc arg5
	sta arg1
	lda #EFFECT_SHARK_LASER
	sta arg2
	;record the players current TILE position this will be used as the dest
	jsr create_effect & $ffff

	cmp #$ff
	beq failed2
	sta cur_effect
	jsr compute_fractional_pixel & $ffff

	jsr shark_laser_tick

failed2:

	;create the effect
	jsr get_relative_player_direction & $ffff
	sta arg3
	ldx cur_enemy
	lda enemy_x, x
	clc
	adc arg4
	sta arg0
	lda enemy_y, x
	clc
	adc arg5
	sta arg1
	lda #EFFECT_SHARK_LASER
	sta arg2
	;record the players current TILE position this will be used as the dest
	jsr create_effect & $ffff

	cmp #$ff
	beq failed3
	sta cur_effect
	jsr compute_fractional_pixel & $ffff

failed3:
	rts
.endproc

;The shark has two states
; swiming - where the fin is shown and is moving
; shooting - when the head is shown, stationary, and we are shooting lasers
PROC do_swiming_ai_tick
	ldx cur_enemy
	lda #0
	sta enemy_knockback_time, x
	sta arg0
	;is it time to shoot?
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
	lda #$30
	cmp shark_fire_count, x
	bne dontfire
	lda #7
	sta arg4
	sta arg5
	jsr fire_laser & $ffff
dontfire:
	rts
change_sprite:
	lda #>(shooting_sprites_for_state)
	sta enemy_sprite_state_high, x
	lda #<(shooting_sprites_for_state)
	sta enemy_sprite_state_low, x
	rts
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
	jmp try_new_direction & $ffff
toidle_tramp3: jmp toidle_tramp & $ffff
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
	jsr rand_range & $ffff

	cmp #DIR_UP
	bne not_up
	jsr get_enemy_tile & $ffff
	;check if we are on the edge
	cpy #0
	beq try_new_direction
	dey
	jsr read_water_collision_at & $ffff
	beq try_new_direction
	jsr get_enemy_tile & $ffff
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
	jmp moving & $ffff
;shark_state_head_up_tramp:jmp shark_state_head_up
try_new_direction_tramp:  jmp try_new_direction & $ffff
not_up:
	cmp #DIR_DOWN
	bne not_down
	jsr get_enemy_tile & $ffff
	cpy #MAP_HEIGHT-1
	beq try_new_direction
	iny
	jsr read_water_collision_at & $ffff
	beq try_new_direction
	jsr get_enemy_tile & $ffff
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
	jmp moving & $ffff
moving_tramp: jmp moving & $ffff
toidle_tramp: jmp toidle & $ffff
not_down:
	cmp #DIR_RIGHT
	bne not_right
	jsr get_enemy_tile & $ffff
	cpx #MAP_WIDTH-1
	beq try_new_direction_tramp
	inx
	jsr read_water_collision_at & $ffff
	beq try_new_direction_tramp
	jsr get_enemy_tile & $ffff
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
	jmp moving & $ffff
try_new_direction_tramp2:
	jmp try_new_direction_tramp & $ffff
not_right:
	jsr get_enemy_tile & $ffff
	cpx #0
	beq try_new_direction_tramp
	dex
	jsr read_water_collision_at & $ffff
	beq try_new_direction_tramp
	jsr get_enemy_tile & $ffff
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
	jmp moveok & $ffff

moveleft:
	lda enemy_walk_target, x
	cmp enemy_x, x
	bcs try_new_direction_tramp2
	jmp moveok & $ffff

moveup:
	lda enemy_walk_target, x
	cmp enemy_y, x
	bcs try_new_direction_tramp2
	jmp moveok & $ffff

movedown:
	lda enemy_walk_target, x
	cmp enemy_y, x
	beq try_new_direction_tramp2
	bcc try_new_direction_tramp2
	;jmp moveok

moveok:
	; Enemy has not reached target, try to move
	jsr shark_move & $ffff
	lda #1
	ldx cur_enemy
	sta enemy_moved, x
	rts

toidle:
	lda #$20
	clc
	adc #$10
	jsr rand_range & $ffff
	ldx cur_enemy
	sta enemy_idle_time, x
	rts
.endproc

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
	jmp done & $ffff
moveup:
	dec enemy_y, x
	jmp done & $ffff
movedown:
	inc enemy_y, x
	jmp done & $ffff
moveleft:
	dec enemy_x, x
done:
	rts
.endproc

PROC get_x_adder
	ldx cur_effect
	lda effect_direction, x	
	and #JOY_RIGHT
	cmp #JOY_RIGHT
	bne neg
pos:
	lda #1
	rts
neg:
	lda #$ff
	rts
.endproc

PROC get_y_adder
	ldx cur_effect
	lda effect_direction, x	
	and #JOY_DOWN
	cmp #JOY_DOWN
	bne neg
pos:
	lda #1
	rts
neg:
	lda #$ff
	rts
.endproc

PROC do_shark_laser_tick
	jsr do_shark_laser_tick_inner & $ffff
	jsr do_shark_laser_tick_inner & $ffff
	rts
.endproc

PROC do_shark_laser_tick_inner
	lda cur_effect
	lsr
	lsr
	lsr
	tay ;y is 0 or 1 indicating the byte of x_or_y_dominate to bit check
	lda cur_effect
	and #7
	tax ;x is now position of taggle mask representing the bit to check
	lda toggle_mask2 & $ffff, x ; get the toggle mask
	and x_or_y_dominate, y ;and the toggle mask with the byte
	;if a == 0 => dy > dx ;; Thus we increment y and calculate fractional pixel for x
	cmp #0
	beq y_greater
x_greater:
	jsr get_x_adder & $ffff
	clc
	adc effect_x, x
	sta effect_x, x

	lda effect_data_0, x ;load the fractional part
	clc
	adc effect_data_1, x ;add it to the accumulator
	sta effect_data_1, x ;store the new value back
	bcc done
	jsr get_y_adder & $ffff
	clc
	adc effect_y, x
	sta effect_y, x
	jmp done & $ffff
y_greater:
	jsr get_y_adder & $ffff
	clc
	adc effect_y, x
	sta effect_y, x

	lda effect_data_0, x ;load the fractional part
	clc
	adc effect_data_1, x ;add it to the accumulator
	sta effect_data_1, x ;store the new value back
	bcc done
	jsr get_x_adder & $ffff
	clc
	adc effect_x, x
	sta effect_x, x
done:
	rts
.endproc

VAR fractional_pixel_lookup
	;x-axis ------------------->
	.byte 0,  0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0
	.byte 0,  255,  128,  85,   64,   51,   43,   36,   32,   28,   26,   23,   21,   20,   18,   17
	.byte 0,  128,  255,  170,  128,  102,  85,   73,   64,   57,   51,   46,   43,   39,   36,   34
	.byte 0,  85,   170,  255,  191,  153,  128,  109,  96,   85,   77,   70,   64,   59,   55,   51
	.byte 0,  64,   128,  191,  255,  204,  170,  146,  128,  113,  102,  93,   85,   78,   73,   68
	.byte 0,  51,   102,  153,  204,  255,  213,  182,  159,  142,  128,  116,  106,  98,   91,   85
	.byte 0,  43,   85,   128,  170,  213,  255,  219,  191,  170,  153,  139,  128,  118,  109,  102
	.byte 0,  36,   73,   109,  146,  182,  219,  255,  223,  198,  179,  162,  149,  137,  128,  119
	.byte 0,  32,   64,   96,   128,  159,  191,  223,  255,  227,  204,  185,  170,  157,  146,  136
	.byte 0,  28,   57,   85,   113,  142,  170,  198,  227,  255,  230,  209,  191,  177,  164,  153
	.byte 0,  26,   51,   77,   102,  128,  153,  179,  204,  230,  255,  232,  213,  196,  182,  170
	.byte 0,  23,   46,   70,   93,   116,  139,  162,  185,  209,  232,  255,  234,  216,  200,  187
	.byte 0,  21,   43,   64,   85,   106,  128,  149,  170,  191,  213,  234,  255,  235,  219,  204
	.byte 0,  20,   39,   59,   78,   98,   118,  137,  157,  177,  196,  216,  235,  255,  237,  221
	.byte 0,  18,   36,   55,   73,   91,   109,  128,  146,  164,  182,  200,  219,  237,  255,  238
	.byte 0,  17,   34,   51,   68,   85,   102,  119,  136,  153,  170,  187,  204,  221,  238,  255

VAR toggle_mask_invert
	.byte $fe, $fd, $fb, $f7, $ef, $df, $bf, $7f

.data

VAR toggle_mask2
	.byte 1, 2, 4, 8, 16, 32, 64, 128

VAR shark_laser_descriptor
	.word shark_laser_tick
	.word laser_hit_player
	.word nothing
	.word sniper_bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 3
	.byte 3, 3

VAR reflected_laser_descriptor
	.word shark_laser_tick
	.word nothing
	.word bullet_hit_enemy
	.word sniper_bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 3
	.byte 3, 3

VAR shark_laser_hit_descriptor
	.word laser_hit_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_BULLET_HIT, 0
	.byte 2
	.byte 0, 0

VAR shark_laser_damage_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_BULLET_DAMAGE, 0
	.byte 3
	.byte 0, 0

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

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

	.byte $04 + 1, $00
	.byte $06 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

TILES shark_tiles, 2, "tiles/enemies/shark/shark.chr", 8

