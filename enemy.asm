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


.data

VAR enemy_descriptors
	.word normal_zombie_descriptor
	.word fat_zombie_descriptor
