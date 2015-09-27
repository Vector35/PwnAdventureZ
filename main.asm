.include "defines.inc"

.code

PROC main
	; First check the save RAM and clear any invalid saves
	lda #0
	jsr is_save_slot_valid
	beq slot0valid
	lda #0
	jsr clear_slot

slot0valid:
	lda #1
	jsr is_save_slot_valid
	beq slot1valid
	lda #1
	jsr clear_slot

slot1valid:
	lda #2
	jsr is_save_slot_valid
	beq slot2valid
	lda #2
	jsr clear_slot

slot2valid:
	lda #3
	jsr is_save_slot_valid
	beq slot3valid
	lda #3
	jsr clear_slot

slot3valid:
	lda #4
	jsr is_save_slot_valid
	beq slot4valid
	lda #4
	jsr clear_slot

slot4valid:
	jsr title

	jsr has_save_ram
	beq newgame

	jsr save_select

	; Ensure the entire RAM, including the scratch area below the stack, is in a
	; known state to prevent all possibility of cross-save contamination
	jsr zero_unused_stack_page

	lda start_new_game
	cmp #0
	beq resume

newgame:
	jsr new_game

resume:
	jsr game_loop
	rts
.endproc


PROC game_loop
prepare:
	jsr generate_map
	jsr init_player_sprites

	jsr save

	LOAD_PTR game_palette
	jsr fade_in

loop:
	lda #0
	sta arg4

	; Get latest controller state and look for movement
	jsr update_controller

	jsr perform_player_move
	bne prepare

	jsr wait_for_vblank
	jsr update_player_sprite
	jsr prepare_for_rendering

	jmp loop
.endproc


PROC new_game
	; Zero out all memory except the stack page to get the game into a known state
	lda active_save_slot
	sta scratch

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
	jmp nameloop

namedone:
	lda new_game_difficulty
	sta difficulty

	; Initialize map generators
	jsr init_map

	; Set player spawn position
	lda #112
	sta player_x
	lda #96
	sta player_y
	lda #DIR_DOWN
	sta player_direction
	lda #0
	sta player_anim_frame

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


.segment "FIXED"

PROC game_over
	lda rendering_enabled
	beq already_disabled
	jsr fade_out
already_disabled:

	jsr clear_screen

	; Draw text
	LOAD_PTR game_over_strings
	ldx #7
	ldy #13
	jsr write_string
	ldx #8
	ldy #14
	jsr write_string
	ldx #7
	ldy #17
	jsr write_string

	; Set palette for game over text
	lda #3
	sta arg0
	lda #8
	sta arg1
	sta arg3
	lda #12
	sta arg2
	lda #1
	sta arg4
	jsr set_box_palette

	LOAD_PTR game_over_palette
	jsr fade_in

	ldx #180
	jsr wait_for_frame_count

	ldy #0
	LOAD_PTR game_over_palette + 8
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

end:
	jsr wait_for_vblank
	jsr update_controller
	lda controller
	and #JOY_START
	beq end
	jmp start
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

VAR game_over_palette
	.byte $0f, $26, $26, $26
	.byte $0f, $0f, $0f, $0f
	.byte $0f, $07, $07, $07
	.byte $0f, $17, $17, $17
	.byte $0f, $27, $27, $27
	.byte $0f, $37, $37, $37
	.byte $0f, $26, $26, $26
	.byte $0f, $26, $26, $26


.bss
VAR inventory

VAR map_screen_generators
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

VAR cur_screen_x
	.byte 0
VAR cur_screen_y
	.byte 0

VAR active_save_slot
	.byte 0
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

VAR new_game_difficulty
	.byte 0


.zeropage
VAR controller
	.byte 0
