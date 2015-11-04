.include "defines.inc"

.segment "FIXED"

PROC get_enemy_tile
	ldy cur_enemy

	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	tax

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	tay

	rts
.endproc


PROC spawn_starting_enemy
	sta arg5

	lda current_bank
	pha
	lda #^do_spawn_starting_enemy
	jsr bankswitch
	jsr do_spawn_starting_enemy & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC invalidate_enemy_cache
	ldx #0
	lda #$ff
loop:
	sta saved_enemy_screen_x, x
	sta saved_enemy_screen_y, x
	inx
	cpx #8
	bne loop
	rts
.endproc


.segment "EXTRA"

PROC do_spawn_starting_enemy
	lda #0
	sta arg4
	; Try to find a valid spawn location
spawnloop:
	lda arg5
	cmp #ENEMY_SHARK
	bne not_shark 
	jsr find_water_spawn_point & $ffff
	cmp #0
	beq notspawnable
	jmp dospawn & $ffff
not_shark:
	lda #9
	jsr rand_range
	clc
	adc #3
	sta arg0

	lda #6
	jsr rand_range
	clc
	adc #3
	sta arg1
	tay
	ldx arg0
	jsr read_spawnable_at
	beq notspawnable
dospawn:
	; Don't spawn too near the player
	lda player_x
	lsr
	lsr
	lsr
	lsr
	sec
	sbc arg0
	cmp #2
	bcc checkplayery
	cmp #$fe
	bcc playerspawnok

checkplayery:
	lda player_y
	lsr
	lsr
	lsr
	lsr
	sec
	sbc arg1
	cmp #2
	bcc notspawnable
	cmp #$fe
	bcs notspawnable

playerspawnok:
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

	jmp spawnhere & $ffff

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

	lda #60
	jsr rand_range
	clc
	adc #30
	ldx arg4
	sta enemy_idle_time, x

	lda arg5
	asl
	tay
	lda enemy_descriptors, y
	sta ptr
	lda enemy_descriptors + 1, y
	sta ptr + 1

	ldy #ENEMY_DESC_SPEED_MASK
	lda (ptr), y
	sta enemy_speed_mask, x
	ldy #ENEMY_DESC_SPEED_VALUE
	lda (ptr), y
	sta enemy_speed_value, x

	ldy #ENEMY_DESC_SPRITE_STATES
	lda (ptr), y
	sta enemy_sprite_state_low, x
	ldy #ENEMY_DESC_SPRITE_STATES + 1
	lda (ptr), y
	sta enemy_sprite_state_high, x
	
	lda #0
	sta enemy_walk_target, x

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard
	ldy #ENEMY_DESC_HEALTH
	lda (ptr), y
	sta enemy_health, x
	jmp done & $ffff

hard:
	ldy #ENEMY_DESC_HEALTH
	lda (ptr), y
	asl
	sta enemy_health, x
	jmp done & $ffff

veryhard:
	ldy #ENEMY_DESC_HEALTH
	lda (ptr), y
	asl
	clc
	adc temp
	sta enemy_health, x

done:
	lda horde_active
	beq nohorde

	lda enemy_x, x
	sta arg0
	lda enemy_y, x
	sta arg1
	lda #EFFECT_WARP
	sta arg2
	lda #0
	sta arg3
	jsr create_effect

	PLAY_SOUND_EFFECT effect_warp

nohorde:
	rts
.endproc

PROC find_water_spawn_point
	;pick a random edge
	lda #4
	sta arg0
try_again:
	lda arg0
	cmp #0
	beq done_failed
	dec arg0
	lda #4
	jsr rand_range
	cmp #0
	bne not_up
	;try to spawn at top of screen
	;use random X inculsive range 0->MAP_WIDTH-2
	lda #MAP_WIDTH-1
	jsr rand_range
	tax
	;use 0 for y
	ldy #0
	stx arg0
	sty arg1
	jsr read_water_collision_at
	jmp check_spawnable & $ffff
not_up:
	cmp #1
	bne not_down
	;try to spawn at bottom of screen
	;use random x inclusive range 1->MAP_WIDTH
	lda #MAP_WIDTH-1
	jsr rand_range
	adc #1
	clc
	tax
	; use bottom of screen for y
	ldy #MAP_HEIGHT-1
	stx arg0
	sty arg1
	jsr read_water_collision_at
	jmp check_spawnable & $ffff
not_down:
	cmp #2
	bne not_right
	;try to spawn on right side of screen
	;use random y inclusive range 0->MAP_HEIGHT-2
	lda #MAP_HEIGHT-1
	jsr rand_range
	tay
	; use left side of screen
	ldx #MAP_WIDTH-1
	stx arg0
	sty arg1
	jsr read_water_collision_at
	jmp check_spawnable & $ffff
not_right:
	;try to spawn on left side of screen
	;use random y range 1->MAP_HEIGHT
	lda #MAP_HEIGHT-1
	jsr rand_range
	adc #1
	clc
	tay
	; use left side of screen
	ldx #0
	stx arg0
	sty arg1
	jsr read_water_collision_at
check_spawnable:
	beq try_again
	lda #1
	jmp done & $ffff
done_failed:
	lda #0
done:
	rts
.endproc


.segment "FIXED"

PROC restore_enemies

	ldx #0
findloop:
	lda saved_enemy_screen_x, x
	cmp cur_screen_x
	bne findnext
	lda saved_enemy_screen_y, x
	cmp cur_screen_y
	bne findnext
	lda saved_enemy_inside, x
	cmp inside
	beq found
findnext:
	inx
	cpx #8
	bne findloop
	lda #0
	rts

found:
	txa
	asl
	asl
	asl
	tax
	ldy #0

spawnloop:
	txa
	pha
	tya
	pha

	lda saved_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tay
	pla
	tax
	inx
	iny
	cpy #8
	bne spawnloop

	lda #1
	rts
.endproc


.segment "EXTRA"

PROC update_horde
	lda horde_active
	bne hashorde
	jmp nohorde & $ffff

hashorde:
	ldx horde_timer + 1
	beq framezero
	dex
	stx horde_timer + 1
	jmp checkspawn & $ffff

framezero:
	lda #59
	sta horde_timer + 1
	ldx horde_timer
	beq done
	dex
	stx horde_timer
	jmp checkspawn & $ffff

done:
	lda #0
	sta horde_active
	lda #1
	sta horde_complete

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_START_FOREST_BOSS
	beq key1done
	cmp #MAP_SEWER_BOSS
	beq key2done
	cmp #MAP_DEAD_WOOD_BOSS
	beq key5done
	rts

key1done:
	jsr wait_for_vblank
	LOAD_PTR normal_forest_chest_palette
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	lda #MUSIC_FOREST
	jsr play_music
	rts

key2done:
	jsr wait_for_vblank
	LOAD_PTR normal_sewer_chest_palette
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	lda #MUSIC_CAVE
	jsr play_music
	rts

key5done:
	jsr wait_for_vblank
	LOAD_PTR normal_forest_chest_palette
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	lda #MUSIC_FOREST
	jsr play_music
	rts

checkspawn:
	ldx horde_spawn_timer
	dex
	stx horde_spawn_timer
	bne nohorde

	lda horde_spawn_delay
	sta horde_spawn_timer

	lda #4
	jsr rand_range
	tay
	lda horde_enemy_types, y
	jsr spawn_starting_enemy

nohorde:
	rts
.endproc


.segment "FIXED"

PROC update_enemies
	lda current_bank
	pha
	lda #^update_horde
	jsr bankswitch
	jsr update_horde & $ffff
	pla
	jsr bankswitch

	lda #0
	sta cur_enemy

loop:
	ldx cur_enemy
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq next

	lda enemy_speed_mask, x
	beq tickenemy
	lda vblank_count
	and enemy_speed_mask, x
	cmp enemy_speed_value, x
	bcc next
	beq next

tickenemy:
	; Call the enemy's tick function
	lda enemy_type, x
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


.code

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
	lda player_direction
	and #4
	bne nothidden

	lda equipped_armor
	cmp #ITEM_GHILLIE_SUIT
	bne nothidden

	jmp checkforidle

nothidden:
	; Check to see if the enemy can see the player in a direct line of sight
	jsr get_enemy_tile
	stx arg0
	sty arg1

	jsr get_player_tile
	stx arg2
	sty arg3

	ldx cur_enemy
	lda enemy_direction
	and #3
	cmp #DIR_RIGHT
	beq nolookleft

	lda arg1
	cmp arg3
	bne nolookleft

	lda arg0
	cmp arg2
	bcc nolookleft

	lda arg0
	sta arg4
leftloop:
	ldx arg4
	cpx arg2
	beq foundleft
	ldy arg1
	jsr read_collision_at
	beq nolookleft
	dec arg4
	jmp leftloop

foundleft:
	ldx cur_enemy
	lda player_x
	sta enemy_walk_target, x
	lda #DIR_LEFT
	sta enemy_walk_direction, x
	lda #0
	sta enemy_idle_time, x
	jmp moving

nolookleft:
	ldx cur_enemy
	lda enemy_direction
	and #3
	cmp #DIR_LEFT
	beq nolookright

	lda arg1
	cmp arg3
	bne nolookright

	lda arg0
	cmp arg2
	bcs nolookright

	lda arg0
	sta arg4
rightloop:
	ldx arg4
	cpx arg2
	beq foundright
	ldy arg1
	jsr read_collision_at
	beq nolookright
	inc arg4
	jmp rightloop

foundright:
	ldx cur_enemy
	lda player_x
	sta enemy_walk_target, x
	lda #DIR_RIGHT
	sta enemy_walk_direction, x
	lda #0
	sta enemy_idle_time, x
	jmp moving

nolookright:
	ldx cur_enemy
	lda enemy_direction
	and #3
	cmp #DIR_DOWN
	beq nolookup

	lda arg0
	cmp arg2
	bne nolookup

	lda arg1
	cmp arg3
	bcc nolookup

	lda arg1
	sta arg4
uploop:
	ldx arg0
	ldy arg4
	cpy arg3
	beq foundup
	jsr read_collision_at
	beq nolookup
	dec arg4
	jmp uploop

foundup:
	ldx cur_enemy
	lda player_y
	sta enemy_walk_target, x
	lda #DIR_UP
	sta enemy_walk_direction, x
	lda #0
	sta enemy_idle_time, x
	jmp moving

nolookup:
	ldx cur_enemy
	lda enemy_direction
	and #3
	cmp #DIR_UP
	beq checkforidle

	lda arg0
	cmp arg2
	bne checkforidle

	lda arg1
	cmp arg3
	bcs checkforidle

	lda arg1
	sta arg4
downloop:
	ldx arg0
	ldy arg4
	cpy arg3
	beq founddown
	jsr read_collision_at
	beq checkforidle
	inc arg4
	jmp downloop

founddown:
	ldx cur_enemy
	lda player_y
	sta enemy_walk_target, x
	lda #DIR_DOWN
	sta enemy_walk_direction, x
	lda #0
	sta enemy_idle_time, x
	jmp moving

checkforidle:
	ldx cur_enemy
	lda enemy_idle_time, x
	beq moving

	; Enemy is idling, wait for the desired number of ticks
	sec
	sbc #1
	sta enemy_idle_time, x
	beq idledone

	rts

idledone:
	; Idle time complete, choose a random target for walking
	lda #0
	ldx cur_enemy
	sta enemy_moved, x

	lda #2
	jsr rand_range
	cmp #0
	beq horizontal

	; Walk on Y axis
	lda #(MAP_HEIGHT - 2) * 16
	jsr rand_range
	clc
	adc #8
	ldx cur_enemy
	sta enemy_walk_target, x
	cmp enemy_y, x
	bcc up

	lda #DIR_DOWN
	sta enemy_walk_direction, x
	rts

up:
	lda #DIR_UP
	sta enemy_walk_direction, x
	rts

horizontal:
	; Walk on X axis
	lda #(MAP_WIDTH - 2) * 16
	jsr rand_range
	clc
	adc #8
	ldx cur_enemy
	sta enemy_walk_target, x
	cmp enemy_x, x
	bcc left

	lda #DIR_RIGHT
	sta enemy_walk_direction, x
	rts

left:
	lda #DIR_LEFT
	sta enemy_walk_direction, x
	rts

moving:
	; Enemy is walking, check for reaching target
	ldx cur_enemy
	lda enemy_walk_direction, x
	and #3
	cmp #DIR_UP
	beq moveup
	cmp #DIR_DOWN
	beq movedown
	cmp #DIR_LEFT
	beq moveleft

	lda enemy_walk_target, x
	cmp enemy_x, x
	beq toidle
	bcc toidle
	jmp moveok

moveleft:
	lda enemy_walk_target, x
	cmp enemy_x, x
	bcs toidle
	jmp moveok

moveup:
	lda enemy_walk_target, x
	cmp enemy_y, x
	bcs toidle
	jmp moveok

movedown:
	lda enemy_walk_target, x
	cmp enemy_y, x
	beq toidle
	bcc toidle
	jmp moveok

moveok:
	; Enemy has not reached target, try to move
	jsr enemy_move
	cmp #0
	beq toidle
	lda #1
	ldx cur_enemy
	sta enemy_moved, x
	rts

toidle:
	; Enemy couldn't move or is done moving, go back to idle state
	ldx cur_enemy
	lda enemy_moved, x
	bne moved

	; Did not move during this move attempt, reattempt immediately
	lda #1
	sta enemy_idle_time, x
	rts

moved:
	; Enemy completed a move, idle for a random period
	lda #60
	jsr rand_range
	clc
	adc #1
	ldx cur_enemy
	sta enemy_idle_time, x

	lda enemy_direction, x
	and #3
	sta enemy_direction, x
	lda #7
	sta enemy_anim_frame, x
	rts
.endproc


PROC enemy_move
	ldx cur_enemy
	lda enemy_walk_direction, x
	and #3
	cmp #DIR_LEFT
	beq left
	cmp #DIR_RIGHT
	beq right
	cmp #DIR_UP
	beq goup
	cmp #DIR_DOWN
	beq godown
	rts

goup:
	jmp up
godown:
	jmp down

left:
	jsr check_for_enemy_overlap_left
	cmp #0
	bne leftmoveinvalid
	ldx cur_enemy
	lda enemy_x, x
	and #15
	bne noleftcollide
	jsr read_enemy_collision_left
	bne noleftcollide
	ldx cur_enemy
	lda enemy_y, x
	and #15
	cmp #8
	bcc leftsnaptop
	jmp leftsnapbot
leftmoveinvalid:
	lda #0
	rts
leftsnaptop:
	jsr read_enemy_collision_left_direct
	beq leftmoveinvalid
	jmp snapup
leftsnapbot:
	jsr read_enemy_collision_down
	beq leftmoveinvalid
	jsr read_enemy_collision_left_bottom
	beq leftmoveinvalid
	jmp snapdown
noleftcollide:
	ldx cur_enemy
	dec enemy_x, x
	lda #DIR_RUN_LEFT
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts

right:
	jsr check_for_enemy_overlap_right
	cmp #0
	bne rightmoveinvalid
	ldx cur_enemy
	lda enemy_x, x
	and #15
	bne norightcollide
	jsr read_enemy_collision_right
	bne norightcollide
	ldx cur_enemy
	lda enemy_y, x
	and #15
	cmp #8
	bcc rightsnaptop
	jmp rightsnapbot
rightmoveinvalid:
	lda #0
	rts
rightsnaptop:
	jsr read_enemy_collision_right_direct
	beq rightmoveinvalid
	jmp snapup
rightsnapbot:
	jsr read_enemy_collision_down
	beq rightmoveinvalid
	jsr read_enemy_collision_right_bottom
	beq rightmoveinvalid
	jmp snapdown
norightcollide:
	ldx cur_enemy
	inc enemy_x, x
	lda #DIR_RUN_RIGHT
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts

up:
	jsr check_for_enemy_overlap_up
	cmp #0
	bne upmoveinvalid
	ldx cur_enemy
	lda enemy_y, x
	and #15
	bne noupcollide
	jsr read_enemy_collision_up
	bne noupcollide
	ldx cur_enemy
	lda enemy_x, x
	and #15
	cmp #8
	bcc upsnapleft
	jmp upsnapright
upmoveinvalid:
	lda #0
	rts
upsnapleft:
	jsr read_enemy_collision_up_direct
	beq upmoveinvalid
	jmp snapleft
upsnapright:
	jsr read_enemy_collision_right
	beq upmoveinvalid
	jsr read_enemy_collision_up_right
	beq upmoveinvalid
	jmp snapright
noupcollide:
	ldx cur_enemy
	dec enemy_y, x
	lda #DIR_RUN_UP
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts

down:
	jsr check_for_enemy_overlap_down
	cmp #0
	bne downmoveinvalid
	ldx cur_enemy
	lda enemy_y, x
	and #15
	bne nodowncollide
	jsr read_enemy_collision_down
	bne nodowncollide
	ldx cur_enemy
	lda enemy_x, x
	and #15
	cmp #8
	bcc downsnapleft
	jmp downsnapright
downmoveinvalid:
	lda #0
	rts
downsnapleft:
	jsr read_enemy_collision_down_direct
	beq downmoveinvalid
	jmp snapleft
downsnapright:
	jsr read_enemy_collision_right
	beq downmoveinvalid
	jsr read_enemy_collision_down_right
	beq downmoveinvalid
	jmp snapright
nodowncollide:
	ldx cur_enemy
	inc enemy_y, x
	lda #DIR_RUN_DOWN
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts

snapleft:
	jsr check_for_enemy_overlap_left
	cmp #0
	bne snapleftmoveinvalid
	ldx cur_enemy
	lda enemy_x, x
	and #15
	bne nosnapleftcollide
	jsr read_enemy_collision_left
	bne nosnapleftcollide
snapleftmoveinvalid:
	lda #0
	rts
nosnapleftcollide:
	ldx cur_enemy
	dec enemy_x, x
	lda #DIR_RUN_LEFT
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts

snapright:
	jsr check_for_enemy_overlap_right
	cmp #0
	bne snaprightmoveinvalid
	ldx cur_enemy
	lda enemy_x, x
	and #15
	bne nosnaprightcollide
	jsr read_enemy_collision_right
	bne nosnaprightcollide
snaprightmoveinvalid:
	lda #0
	rts
nosnaprightcollide:
	ldx cur_enemy
	inc enemy_x, x
	lda #DIR_RUN_RIGHT
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts

snapup:
	jsr check_for_enemy_overlap_up
	cmp #0
	bne snapupmoveinvalid
	ldx cur_enemy
	lda enemy_y, x
	and #15
	bne nosnapupcollide
	jsr read_enemy_collision_up
	bne nosnapupcollide
snapupmoveinvalid:
	lda #0
	rts
nosnapupcollide:
	ldx cur_enemy
	dec enemy_y, x
	lda #DIR_RUN_UP
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts

snapdown:
	jsr check_for_enemy_overlap_down
	cmp #0
	bne snapdownmoveinvalid
	ldx cur_enemy
	lda enemy_y, x
	and #15
	bne nosnapdowncollide
	jsr read_enemy_collision_down
	bne nosnapdowncollide
snapdownmoveinvalid:
	lda #0
	rts
nosnapdowncollide:
	ldx cur_enemy
	inc enemy_y, x
	lda #DIR_RUN_DOWN
	sta enemy_direction, x
	inc enemy_anim_frame, x
	lda #1
	rts
.endproc


PROC check_for_enemy_overlap_left
	lda #0
	sta arg0

loop:
	ldx arg0
	cpx cur_enemy
	beq next
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq next

	ldy cur_enemy
	lda enemy_x, x
	sec
	sbc enemy_x, y
	cmp #$f4
	bcs xoverlap
	jmp next

xoverlap:
	lda enemy_y, x
	sec
	sbc enemy_y, y
	cmp #$0e
	bcc yoverlap
	cmp #$f1
	bcs yoverlap
	jmp next

yoverlap:
	lda #1
	rts

next:
	ldx arg0
	inx
	stx arg0
	cpx #ENEMY_MAX_COUNT
	bne loop

	lda #0
	rts
.endproc


PROC check_for_enemy_overlap_right
	lda #0
	sta arg0

loop:
	ldx arg0
	cpx cur_enemy
	beq next
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq next

	ldy cur_enemy
	lda enemy_x, x
	sec
	sbc enemy_x, y
	cmp #$0b
	bcc xoverlap
	jmp next

xoverlap:
	lda enemy_y, x
	sec
	sbc enemy_y, y
	cmp #$0e
	bcc yoverlap
	cmp #$f1
	bcs yoverlap
	jmp next

yoverlap:
	lda #1
	rts

next:
	ldx arg0
	inx
	stx arg0
	cpx #ENEMY_MAX_COUNT
	bne loop

	lda #0
	rts
.endproc


PROC check_for_enemy_overlap_up
	lda #0
	sta arg0

loop:
	ldx arg0
	cpx cur_enemy
	beq next
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq next

	ldy cur_enemy
	lda enemy_x, x
	sec
	sbc enemy_x, y
	cmp #$0b
	bcc xoverlap
	cmp #$f4
	bcs xoverlap
	jmp next

xoverlap:
	lda enemy_y, x
	sec
	sbc enemy_y, y
	cmp #$f1
	bcs yoverlap
	jmp next

yoverlap:
	lda #1
	rts

next:
	ldx arg0
	inx
	stx arg0
	cpx #ENEMY_MAX_COUNT
	bne loop

	lda #0
	rts
.endproc


PROC check_for_enemy_overlap_down
	lda #0
	sta arg0

loop:
	ldx arg0
	cpx cur_enemy
	beq next
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq next

	ldy cur_enemy
	lda enemy_x, x
	sec
	sbc enemy_x, y
	cmp #$0b
	bcc xoverlap
	cmp #$f4
	bcs xoverlap
	jmp next

xoverlap:
	lda enemy_y, x
	sec
	sbc enemy_y, y
	cmp #$0e
	bcc yoverlap
	jmp next

yoverlap:
	lda #1
	rts

next:
	ldx arg0
	inx
	stx arg0
	cpx #ENEMY_MAX_COUNT
	bne loop

	lda #0
	rts
.endproc


PROC remove_enemy
	ldx cur_enemy
	lda #ENEMY_NONE
	sta enemy_type, x

	jsr save_enemies

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
	bne present
	jmp empty

present:
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

	lda enemy_sprite_state_low, x
	sta ptr
	lda enemy_sprite_state_high, x
	sta ptr + 1

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

	stx temp + 1

	tya
	tax

	pla
	tay

	lda (ptr), y
	ora arg0
	sta sprites + 1, x
	iny
	lda (ptr), y
	ora arg1
	sta sprites + 2, x
	iny
	lda (ptr), y
	ora arg0
	sta sprites + 5, x
	iny
	lda (ptr), y
	ora arg1
	sta sprites + 6, x

	txa
	tay

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

.segment "FIXED"
PROC enemy_damage
	sta temp
	ldx cur_enemy
	lda enemy_health, x
	sec
	sbc temp
	beq dead
	bcc dead
	sta enemy_health, x
	rts

dead:
	; Enemy is dead, call the die callback
	lda #0
	sta enemy_health, x

	lda enemy_type, x
	asl
	tay
	lda enemy_descriptors, y
	sta ptr
	lda enemy_descriptors + 1, y
	sta ptr + 1

	ldy #ENEMY_DESC_DIE
	lda (ptr), y
	sta temp
	ldy #ENEMY_DESC_DIE + 1
	lda (ptr), y
	sta temp + 1
	jsr call_temp

	rts
.endproc

.code

PROC save_enemies
	ldx #0
findloop:
	lda saved_enemy_screen_x, x
	cmp cur_screen_x
	bne findnext
	lda saved_enemy_screen_y, x
	cmp cur_screen_y
	bne findnext
	lda saved_enemy_inside, x
	cmp inside
	beq found
findnext:
	inx
	cpx #8
	bne findloop
	jmp newscreen

found:
	lda saved_enemy_screen_x
	sta saved_enemy_screen_x, x
	lda saved_enemy_screen_y
	sta saved_enemy_screen_y, x
	lda saved_enemy_inside
	sta saved_enemy_inside, x
	txa
	asl
	asl
	asl
	tax
	ldy #0
swaploop:
	lda saved_enemy_types, y
	sta saved_enemy_types, x
	inx
	iny
	cpy #8
	bne swaploop
	jmp save

newscreen:
	ldx #7
moveloop:
	lda saved_enemy_screen_x - 1, x
	sta saved_enemy_screen_x, x
	lda saved_enemy_screen_y - 1, x
	sta saved_enemy_screen_y, x
	lda saved_enemy_inside - 1, x
	sta saved_enemy_inside, x
	dex
	bne moveloop

	ldx #63
moveloop2:
	lda saved_enemy_types - 8, x
	sta saved_enemy_types, x
	dex
	cpx #7
	bne moveloop2

save:
	lda cur_screen_x
	sta saved_enemy_screen_x
	lda cur_screen_y
	sta saved_enemy_screen_y
	lda inside
	sta saved_enemy_inside
	ldx #0
saveloop:
	lda enemy_type, x
	sta saved_enemy_types, x
	inx
	cpx #8
	bne saveloop

	rts
.endproc


PROC enemy_die
	lda #ITEM_NONE
	ldx #0
	jsr enemy_die_with_drop
	rts
.endproc


PROC enemy_die_with_drop
	sta arg4
	stx arg5

	ldx cur_enemy
	lda enemy_x, x
	sta arg0
	lda enemy_y, x
	sta arg1
	lda #EFFECT_ENEMY_DEATH
	sta arg2
	lda #0
	sta arg3

	jsr create_effect
	rts
.endproc


PROC enemy_die_with_drop_table
	; Pick drop entry from table
	ldy #0
	lda (ptr), y
	jsr rand_range
	sta arg0

	; Read drop type pointer
	ldy #1
	lda (ptr), y
	sta temp
	ldy #2
	lda (ptr), y
	sta temp + 1

	; Look up drop type
	ldy arg0
	lda (temp), y
	sta arg1

	; Read count randomization field and pick a count
	ldy #5
	lda (ptr), y
	sta temp
	ldy #6
	lda (ptr), y
	sta temp + 1

	ldy arg0
	lda (temp), y
	jsr rand_range
	sta arg2

	; Add in the minimum count
	ldy #3
	lda (ptr), y
	sta temp
	ldy #4
	lda (ptr), y
	sta temp + 1
	ldy arg0
	lda (temp), y
	clc
	adc arg2
	tax

	lda arg1
	jsr enemy_die_with_drop
	rts
.endproc


PROC enemy_death_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #8
	beq secondframe
	cmp #16
	beq thirdframe
	cmp #24
	beq splatdone
	rts

secondframe:
	lda #SPRITE_TILE_SPLAT + 4
	sta effect_tile, x
	rts
thirdframe:
	lda #SPRITE_TILE_SPLAT + 8
	sta effect_tile, x
	rts

splatdone:
	; If there is no drop, remove effect now
	ldx cur_effect
	lda effect_data_0, x
	cmp #ITEM_NONE
	beq noitem
	lda effect_data_1, x
	bne hasitem

noitem:
	jsr remove_effect
	rts

hasitem:
	lda #SPRITE_TILE_ORB
	sta effect_tile, x
	lda #0
	sta effect_time, x
	lda #EFFECT_DROP
	sta effect_type, x
	lda effect_x, x
	clc
	adc #4
	sta effect_x, x
	lda effect_y, x
	clc
	adc #4
	sta effect_y, x
	rts
.endproc


PROC drop_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #16
	beq secondframe
	cmp #32
	bne done

	lda #SPRITE_TILE_ORB
	sta effect_tile, x
	lda #0
	sta effect_time, x
	rts

secondframe:
	lda #SPRITE_TILE_ORB + 2
	sta effect_tile, x

done:
	rts
.endproc


PROC warp_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #12
	bne notdone
	jsr remove_effect
notdone:
	rts
.endproc


PROC drop_collide
	PLAY_SOUND_EFFECT effect_getitem

	ldy cur_effect
	lda effect_data_1, y
	tax
	lda effect_data_0, y
	jsr give_item_with_count
	jsr remove_effect
	rts
.endproc


.zeropage

VAR cur_enemy
	.byte 0

VAR saved_enemy_screen_x
	.byte 0, 0, 0, 0, 0, 0, 0, 0
VAR saved_enemy_screen_y
	.byte 0, 0, 0, 0, 0, 0, 0, 0
VAR saved_enemy_inside
	.byte 0, 0, 0, 0, 0, 0, 0, 0


.bss

VAR saved_enemy_types
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0


.segment "TEMP"

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

VAR enemy_health
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_sprite_state_low
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_sprite_state_high
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

VAR enemy_walk_direction
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_walk_target
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_moved
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_idle_time
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_speed_mask
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR enemy_speed_value
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

VAR knockback_time
	.byte 0
VAR knockback_control
	.byte 0

VAR shark_fire_count 
	.repeat ENEMY_MAX_COUNT
	.byte 0
	.endrepeat

.data

VAR enemy_descriptors
	.word normal_male_zombie_descriptor
	.word normal_female_zombie_descriptor
	.word shark_descriptor 
	.word fat_zombie_descriptor
	.word male_npc_1_descriptor
	.word female_npc_1_descriptor
	.word male_thin_npc_1_descriptor
	.word female_thin_npc_1_descriptor
	.word male_npc_2_descriptor
	.word female_npc_2_descriptor
	.word male_thin_npc_2_descriptor
	.word female_thin_npc_2_descriptor
	.word spider_descriptor
	.word rat_descriptor


VAR enemy_death_descriptor
	.word enemy_death_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_SPLAT, 1
	.byte 3
	.byte 16, 16


VAR drop_descriptor
	.word drop_tick
	.word drop_collide
	.word nothing
	.word nothing
	.byte SPRITE_TILE_ORB, 0
	.byte 2
	.byte 8, 8


VAR warp_descriptor
	.word warp_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_WARP, 1
	.byte 2
	.byte 16, 16


TILES splat_tiles, 2, "tiles/effects/splat.chr", 12
TILES orb_tiles, 2, "tiles/items/orb.chr", 4
TILES warp_tiles, 3, "tiles/effects/warp.chr", 4
