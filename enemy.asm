.include "defines.inc"

.code

PROC spawn_starting_enemy
	sta arg5

	; Try to find a valid spawn location
	lda #0
	sta arg4
spawnloop:
	lda #7
	jsr rand_range
	clc
	adc #4
	sta arg0

	lda #4
	jsr rand_range
	clc
	adc #4
	sta arg1
	tay
	ldx arg0

	jsr read_spawnable_at
	beq notspawnable

	; Check to make sure there isn't already an enemy here
	ldx #0
collideloop:
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq collidenext
	lda enemy_x, x
	lsr
	lsr
	lsr
	lsr
	cmp arg0
	bne collidenext
	lda enemy_y, x
	lsr
	lsr
	lsr
	lsr
	cmp arg1
	beq notspawnable
collidenext:
	inx
	cpx #ENEMY_MAX_COUNT
	bne collideloop

	jmp spawnhere

notspawnable:
	; Not a valid location, try up to 8 times to find one
	ldx arg4
	inx
	stx arg4
	cpx #8
	bne spawnloop
	rts

spawnhere:
	; Find an empty slot for the enemy to spawn into
	ldx #0
findslot:
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq slotfound
	inx
	cpx #ENEMY_MAX_COUNT
	bne findslot
	rts

slotfound:
	; Valid slot found, spawn the enemy now
	stx arg4

	lda arg5
	sta enemy_type, x
	lda arg0
	asl
	asl
	asl
	asl
	sta enemy_x, x
	lda arg1
	asl
	asl
	asl
	asl
	sta enemy_y, x

	lda #4
	jsr rand_range
	ldx arg4
	sta enemy_direction, x

	lda #150
	jsr rand_range
	clc
	adc #30
	ldx arg4
	sta enemy_idle_time, x

	rts
.endproc


PROC update_enemies
	lda #0
	sta cur_enemy

loop:
	ldx cur_enemy
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq next

	; Call the enemy's tick function
	asl
	tay
	lda enemy_descriptors, y
	sta ptr
	lda enemy_descriptors + 1, y
	sta ptr + 1

	ldy #ENEMY_DESC_TICK
	lda (ptr), y
	sta temp
	ldy #ENEMY_DESC_TICK + 1
	lda (ptr), y
	sta temp + 1
	jsr call_temp

next:
	ldx cur_enemy
	inx
	stx cur_enemy
	cpx #ENEMY_MAX_COUNT
	bne loop

	rts
.endproc


PROC check_for_enemy_collide
	lda player_damage_flash_time
	beq notinvuln
	rts

notinvuln:
	lda #0
	sta cur_enemy

loop:
	ldx cur_enemy
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq next

	lda enemy_x, x
	sec
	sbc player_x
	cmp #$0b
	bcc xoverlap
	cmp #$f4
	bcs xoverlap
	jmp next

xoverlap:
	lda enemy_y, x
	sec
	sbc player_y
	cmp #$0e
	bcc yoverlap
	cmp #$f1
	bcs yoverlap
	jmp next

yoverlap:
	; Call the enemy's collide function
	lda enemy_type, x
	asl
	tay
	lda enemy_descriptors, y
	sta ptr
	lda enemy_descriptors + 1, y
	sta ptr + 1

	ldy #ENEMY_DESC_COLLIDE
	lda (ptr), y
	sta temp
	ldy #ENEMY_DESC_COLLIDE + 1
	lda (ptr), y
	sta temp + 1
	jsr call_temp

next:
	ldx cur_enemy
	inx
	stx cur_enemy
	cpx #ENEMY_MAX_COUNT
	bne loop

	rts
.endproc


PROC enemy_knockback
	ldx cur_enemy

	; Get the absolute value of the X distance from the player
	lda enemy_x, x
	cmp player_x
	bcc leftofplayer

	lda enemy_x, x
	sec
	sbc player_x
	sta arg0
	jmp checkvert

leftofplayer:
	lda player_x
	sec
	sbc enemy_x, x
	sta arg0

checkvert:
	; Get the absolute value of the Y distance from the player
	lda enemy_y, x
	cmp player_y
	bcc upfromplayer

	lda enemy_y, x
	sec
	sbc player_y
	sta arg1
	jmp finddir

upfromplayer:
	lda player_y
	sec
	sbc enemy_y, x
	sta arg1

finddir:
	; Determine far distance from player, this is the direction we want
	; to send the player
	lda arg0
	cmp arg1
	bcc usevert

	lda enemy_x, x
	cmp player_x
	bcc right

	lda #JOY_LEFT
	sta knockback_control
	lda #10
	sta knockback_time
	lda #DIR_RUN_RIGHT
	sta player_direction
	rts

right:
	lda #JOY_RIGHT
	sta knockback_control
	lda #10
	sta knockback_time
	lda #DIR_RUN_LEFT
	sta player_direction
	rts

usevert:
	lda enemy_y, x
	cmp player_y
	bcc down

	lda #JOY_UP
	sta knockback_control
	lda #10
	sta knockback_time
	lda #DIR_RUN_DOWN
	sta player_direction
	rts

down:
	lda #JOY_DOWN
	sta knockback_control
	lda #10
	sta knockback_time
	lda #DIR_RUN_UP
	sta player_direction
	rts
.endproc


PROC walking_ai_tick
	rts
.endproc


PROC enemy_die
	ldx cur_enemy
	lda #ENEMY_NONE
	sta enemy_type, x
	rts
.endproc


PROC update_enemy_sprites
	; NES only supports 8 sprites per scan line, so rotate priority of enemy sprites
	; to ensure all of them get screen time.  This will create the classic flicker
	; effect when there is a lot going on.
	lda enemy_sprite_rotation
	clc
	adc #3
	sta enemy_sprite_rotation

	ldx #0
spriteloop:
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq empty

	asl
	tay
	lda enemy_descriptors, y
	sta ptr
	lda enemy_descriptors + 1, y
	sta ptr + 1

	ldy #ENEMY_DESC_TILE
	lda (ptr), y
	sta arg0
	ldy #ENEMY_DESC_PALETTE
	lda (ptr), y
	sta arg1

	txa
	clc
	adc enemy_sprite_rotation
	and #ENEMY_MAX_COUNT - 1
	asl
	asl
	asl
	clc
	adc #SPRITE_OAM_ENEMIES
	tay

	lda enemy_anim_frame, x
	lsr
	lsr
	lsr
	and #1
	sta temp

	lda enemy_direction, x
	asl
	ora temp
	asl
	asl
	pha

	lda enemy_y, x
	clc
	adc #7
	sta sprites, y
	sta sprites + 4, y

	pla
	stx temp + 1
	tax

	lda walking_sprites_for_state, x
	ora arg0
	sta sprites + 1, y
	lda walking_sprites_for_state + 1, x
	ora arg1
	sta sprites + 2, y
	lda walking_sprites_for_state + 2, x
	ora arg0
	sta sprites + 5, y
	lda walking_sprites_for_state + 3, x
	ora arg1
	sta sprites + 6, y

	ldx temp + 1
	lda enemy_x, x
	clc
	adc #8
	sta sprites + 3, y
	adc #8
	sta sprites + 7, y
	jmp next

empty:
	txa
	clc
	adc enemy_sprite_rotation
	and #ENEMY_MAX_COUNT - 1
	asl
	asl
	asl
	clc
	adc #SPRITE_OAM_ENEMIES
	tay
	lda #$ff
	sta sprites, y
	sta sprites + 4, y

next:
	inx
	cpx #ENEMY_MAX_COUNT
	beq done
	jmp spriteloop

done:
	rts
.endproc


.zeropage

VAR cur_enemy
	.byte 0


.bss

VAR enemy_sprite_rotation
	.byte 0

VAR enemy_type
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_x
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_y
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_anim_frame
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_direction
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_walk_target
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_idle_time
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR knockback_time
	.byte 0
VAR knockback_control
	.byte 0


.data

VAR enemy_descriptors
	.word normal_zombie_descriptor
	.word fat_zombie_descriptor
