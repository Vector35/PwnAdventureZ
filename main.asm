.include "defines.inc"

.code

PROC main
	; First check the save RAM and clear any invalid saves
	jsr validate_saves

	jsr title

	jsr has_save_ram
	beq newgame

	jsr save_select

	; Ensure the entire RAM, including the scratch area below the stack, is in a
	; known state to prevent all possibility of cross-save contamination
	jsr zero_unused_stack_page

	; Clear temporary RAM
	ldx #0
	lda #0
cleartemp:
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne cleartemp

	lda start_new_game
	cmp #0
	beq resume

newgame:
	jsr new_game

resume:
	jsr update_controller
	lda controller
	cmp #JOY_UP | JOY_B
	bne nomapviewer
	jmp map_viewer

nomapviewer:
	LOAD_PTR neonstarlight_ptr
	lda #<neonstarlight_bank
	sta arg0
	lda #>neonstarlight_bank
	sta arg1
	lda #<neonstarlight_loop_ptr
	sta arg2
	lda #>neonstarlight_loop_ptr
	sta arg3
	lda #<neonstarlight_loop_bank
	sta arg4
	lda #>neonstarlight_loop_bank
	sta arg5
	lda #^neonstarlight_ptr
	jsr play_music

	jsr game_loop
	rts
.endproc


PROC game_loop
	; When loading game, set player location to where the player entered the room, to
	; avoid spawning in the middle of a group of enemies
	lda player_entry_x
	sta player_x
	lda player_entry_y
	sta player_y

	jsr has_save_ram
	beq prepare

	jsr generate_minimap_cache

prepare:
	; Save player location as the entry location for this map
	lda player_x
	sta player_entry_x
	lda player_y
	sta player_entry_y

	jsr generate_map
	jsr init_player_sprites
	jsr init_zombie_sprites
	jsr init_shark_sprites
	jsr init_effect_sprites
	jsr init_status_tiles

	jsr save_enemies

	jsr save

	LOAD_PTR game_palette
	jsr fade_in

	jmp vblank

loop:
	lda player_health
	bne notdead

	jsr game_over
	jmp prepare

notdead:
	; Get latest controller state and look for movement
	jsr update_controller

	lda controller
	and #JOY_START
	beq nopause

	PLAY_SOUND_EFFECT effect_select
	jsr minimap
	jmp vblank

nopause:
	lda controller
	and #JOY_SELECT
	beq noinventory

	PLAY_SOUND_EFFECT effect_select
	jsr show_inventory
	jmp vblank

noinventory:
	lda knockback_time
	beq normalmove

	jsr perform_player_move
	jsr perform_player_move
	dec knockback_time
	jmp movedone

normalmove:
	lda #0
	sta extra_player_move
	jsr perform_player_move
	beq normalsecondmove

	jmp prepare

normalsecondmove:
	lda equipped_armor
	cmp #ITEM_SNEAKERS
	bne movedone

	lda vblank_count
	and #1
	bne movedone

	lda #1
	sta extra_player_move
	jsr perform_player_move
	beq movedone
	jmp prepare

movedone:
	jsr update_enemies
	jsr check_for_enemy_collide
	jsr update_effects

vblank:
	jsr wait_for_vblank
	jsr update_player_surroundings
	jsr update_player_sprite
	jsr update_status_bar
	jsr prepare_for_rendering

	jsr update_enemy_sprites
	jsr update_effect_sprites

	jmp loop
.endproc


PROC new_game
	; Zero out all memory except the stack page to get the game into a known state
	lda active_save_slot
	sta scratch
	lda secret_code
	sta scratch + 1

	ldx #0
	lda #0
clearloop:
	sta $0000, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne clearloop

	lda scratch
	sta active_save_slot
	lda scratch + 1
	sta secret_code

	jsr zero_unused_stack_page

	; Ask for name if we are saving
	jsr has_save_ram
	bne nameloop
	jmp namedone

nameloop:
	ldx #0
	lda #0
nameclearloop:
	sta name, x
	inx
	cpx #14
	bne nameclearloop

	jsr enter_name

	lda name
	cmp #'Q'
	bne nothard
	lda name + 1
	cmp #'U'
	bne nothard
	lda name + 2
	cmp #'E'
	bne nothard
	lda name + 3
	cmp #'S'
	bne nothard
	lda name + 4
	cmp #'T'
	bne nothard
	lda name + 5
	cmp #' '
	bne nothard
	lda name + 6
	cmp #'2'
	bne nothard
	lda name + 7
	cmp #'.'
	bne nothard
	lda name + 8
	cmp #'0'
	bne nothard
	lda name + 9
	cmp #0
	bne nothard

	; Secret name entered for hard difficulty, set it and restart name entry
	lda #1
	sta new_game_difficulty
	lda #0
	sta secret_code
	jmp nameloop

nothard:
	lda name
	cmp #'U'
	bne namedone
	lda name + 1
	cmp #'N'
	bne namedone
	lda name + 2
	cmp #'B'
	bne namedone
	lda name + 3
	cmp #'E'
	bne namedone
	lda name + 4
	cmp #'A'
	bne namedone
	lda name + 5
	cmp #'R'
	bne namedone
	lda name + 6
	cmp #'A'
	bne namedone
	lda name + 7
	cmp #'B'
	bne namedone
	lda name + 8
	cmp #'L'
	bne namedone
	lda name + 9
	cmp #'E'
	bne namedone
	lda name + 10
	cmp #0
	bne namedone

	; Secret name entered for hardest difficulty, set it and restart name entry
	lda #2
	sta new_game_difficulty
	lda #0
	sta secret_code
	jmp nameloop

namedone:
	lda new_game_difficulty
	sta difficulty

	; Initialize map generators
	jsr init_map

	; Set player spawn position
	lda #112
	sta player_entry_x
	sta spawn_pos_x
	lda #112
	sta player_entry_y
	sta spawn_pos_y
	lda #DIR_DOWN
	sta player_direction
	lda #0
	sta player_anim_frame
	lda #100
	sta player_health

	lda secret_code
;	beq nocode

	lda #1
	sta gold

	lda #ITEM_PISTOL
	ldx #200
	jsr give_weapon

	lda #ITEM_SNEAKERS
	jsr give_item

	lda #ITEM_GHILLIE_SUIT
	jsr give_item

	lda #ITEM_BANDAGE
	ldx #5
	jsr give_item_with_count

	lda #ITEM_HEALTH_KIT
	ldx #5
	jsr give_item_with_count

	lda #ITEM_METAL
	ldx #10
	jsr give_item_with_count

	lda #ITEM_GUNPOWDER
	ldx #10
	jsr give_item_with_count

	lda #ITEM_GEM
	ldx #10
	jsr give_item_with_count

	lda #ITEM_CLOTH
	ldx #30
	jsr give_item_with_count

	lda #ITEM_SHIRT
	ldx #8
	jsr give_item_with_count

nocode:
	lda #ITEM_NONE
	sta equipped_weapon
	sta equipped_armor

	; Don't start a new game on restore
	lda #0
	sta start_new_game

	; Ensure game palette has black as the background
	lda #$0f
	sta game_palette + 16
	sta game_palette + 20
	sta game_palette + 24
	sta game_palette + 28

	; Save the initial state to the save slot
	lda active_save_slot
	jsr save_ram_to_slot

	rts
.endproc


.segment "CHR1"

PROC show_game_over
	; Update number of deaths
	ldx death_count + 2
	inx
	stx death_count + 2
	cpx #10
	bne deathupdatedone

	lda #0
	sta death_count + 2
	ldx death_count + 1
	inx
	stx death_count + 1
	cpx #10
	bne deathupdatedone

	lda #0
	sta death_count + 1
	ldx death_count
	inx
	stx death_count
	cpx #10
	bne deathupdatedone

	lda #9
	sta death_count
	sta death_count + 1
	sta death_count + 2

deathupdatedone:
	; Respawn player at the most recent spawn point
	lda spawn_screen_x
	sta cur_screen_x
	lda spawn_screen_y
	sta cur_screen_y
	lda spawn_pos_x
	sta player_x
	sta player_entry_x
	lda spawn_pos_y
	sta player_y
	sta player_entry_y
	lda #100
	sta player_health
	lda #0
	sta player_damage_flash_time
	lda #0
	sta knockback_time
	jsr save

	jsr fade_out
	jsr clear_screen

	LOAD_ALL_TILES 0, title_tiles

	; Draw text
	LOAD_PTR game_over_strings
	ldx #7
	ldy #9
	jsr write_string
	ldx #8
	ldy #10
	jsr write_string
	ldx #7
	ldy #13
	jsr write_string

	; Set palette for game over text
	lda #3
	sta arg0
	lda #6
	sta arg1
	sta arg3
	lda #12
	sta arg2
	lda #1
	sta arg4
	jsr set_box_palette

	lda #3
	sta arg0
	lda #8
	sta arg1
	sta arg3
	lda #12
	sta arg2
	lda #2
	sta arg4
	jsr set_box_palette

	LOAD_PTR game_over_palette
	jsr fade_in

	ldx #180
	jsr wait_for_frame_count

	ldy #0
	LOAD_PTR game_over_palette + 12
game_over_fade:
	tya
	pha

	lda #1
	jsr load_single_palette
	jsr prepare_for_rendering

	ldx #15
	jsr wait_for_frame_count

	pla
	tay
	iny
	cpy #4
	bne game_over_fade

	jsr wait_for_vblank
	LOAD_PTR continue_str
	ldx #10
	ldy #16
	jsr write_string
	LOAD_PTR right_arrow_str
	ldx #8
	ldy #16
	jsr write_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	LOAD_PTR save_quit_str
	ldx #10
	ldy #17
	jsr write_string
	jsr prepare_for_rendering

	lda #0
	sta selection

loop:
	jsr wait_for_vblank
	jsr update_controller
	lda controller
	and #JOY_START | JOY_A
	bne done
	lda controller
	and #JOY_UP | JOY_DOWN | JOY_SELECT
	bne change
	jmp loop & $ffff

change:
	jsr wait_for_vblank

	LOAD_PTR space_str
	lda #16
	clc
	adc selection
	tay
	ldx #8
	jsr write_string

	lda selection
	eor #1
	sta selection

	LOAD_PTR right_arrow_str
	lda #16
	clc
	adc selection
	tay
	ldx #8
	jsr write_string

	jsr prepare_for_rendering

waitfordepress:
	jsr wait_for_vblank
	jsr update_controller
	lda controller
	bne waitfordepress

	jmp loop & $ffff

done:
	lda selection
	beq continue

	jmp start

continue:
	jsr fade_out
	rts
.endproc


.segment "FIXED"

PROC game_over
	lda current_bank
	pha
	lda #^show_game_over
	jsr bankswitch
	jsr show_game_over & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC update_controller
	tya
	pha

	; Start controller read
	lda #1
	sta JOY1
	lda #0
	sta JOY1

	; Read 8 buttons
	ldx #8
loop:
	pha
	lda JOY1
	and #3 ; Button is pressed if either of the bottom two bits are set
	cmp #1
	pla
	ror

	dex
	bne loop

	sta controller

	jsr update_entropy

	pla
	tay
	lda controller
	rts
.endproc


PROC save
	lda active_save_slot
	jsr save_ram_to_slot
	rts
.endproc


.data
VAR game_over_strings
	.byte "THE ZOMBIES HAVE", 0
	.byte "OVERTAKEN YOU.", 0
	.byte $3b, $3b, " GAME  OVER ", $3d, $3d, 0

VAR continue_str
	.byte "CONTINUE", 0
VAR save_quit_str
	.byte "SAVE AND QUIT", 0

VAR game_over_palette
	.byte $0f, $26, $26, $26
	.byte $0f, $0f, $0f, $0f
	.byte $0f, $30, $30, $30
	.byte $0f, $07, $07, $07
	.byte $0f, $17, $17, $17
	.byte $0f, $27, $27, $27
	.byte $0f, $37, $37, $37
	.byte $0f, $26, $26, $26


.bss
VAR start_new_game
	.byte 0

VAR name
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

VAR difficulty
	.byte 0
VAR time_played
	.byte 0, 0, 0, 0, 0, 0

VAR key_count
	.byte 0

VAR death_count
	.byte 0, 0, 0


.segment "TEMP"

VAR new_game_difficulty
	.byte 0

VAR selection
	.byte 0


.zeropage
VAR controller
	.byte 0

VAR inventory_count
	.byte 0

VAR inventory
	.repeat INVENTORY_SIZE
	.byte 0, 0
	.endrepeat

VAR map_screen_generators
	.repeat MAP_TYPE_COUNT
	.word 0
	.endrepeat

VAR equipped_weapon
	.byte 0
VAR equipped_armor
	.byte 0
VAR equipped_weapon_slot
	.byte 0
VAR equipped_armor_slot
	.byte 0

VAR cur_screen_x
	.byte 0
VAR cur_screen_y
	.byte 0
VAR inside
	.byte 0
VAR map_bank
	.byte 0
VAR map_ptr
	.word 0
VAR map_visited_ptr
	.word 0

VAR spawn_screen_x
	.byte 0
VAR spawn_screen_y
	.byte 0
VAR spawn_pos_x
	.byte 0
VAR spawn_pos_y
	.byte 0

VAR active_save_slot
	.byte 0

VAR secret_code
	.byte 0

VAR gold
	.byte 0, 0, 0, 0
