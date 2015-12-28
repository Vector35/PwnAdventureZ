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

.segment "FIXED"

PROC show_credits
	lda current_bank
	pha
	lda #^do_show_credits
	jsr bankswitch
	jsr do_show_credits & $ffff
	pla
	jsr bankswitch
	rts
.endproc



.segment "CHR1"

PROC do_show_credits
	; Game beaten, prepare for next quest and display credits

	; Trigger for AGDQ judge script
	lda #1
	sta game_beaten

	lda #0
	sta key_count

	lda difficulty
	cmp #2
	beq alreadymaxdifficulty

	inc difficulty
	jsr save
	dec difficulty
	jmp startcredits & $ffff

alreadymaxdifficulty:
	jsr save

startcredits:
	lda #MUSIC_CREDITS
	jsr play_music

	jsr disable_rendering
	jsr clear_screen

	LOAD_ALL_TILES 0, title_tiles

	LOAD_PTR credit_string_1
	ldx #7
	ldy #4
	jsr write_string
	ldx #1
	ldy #8
	jsr write_string
	ldx #1
	ldy #9
	jsr write_string
	ldx #1
	ldy #10
	jsr write_string
	ldx #1
	ldy #14
	jsr write_string
	ldx #1
	ldy #15
	jsr write_string
	ldx #1
	ldy #16
	jsr write_string
	ldx #1
	ldy #20
	jsr write_string

	lda #0
	sta arg0
	lda #2
	sta arg1
	lda #15
	sta arg2
	lda #2
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #0
	sta arg0
	lda #7
	sta arg1
	lda #15
	sta arg2
	lda #8
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	lda #0
	sta arg0
	lda #10
	sta arg1
	lda #15
	sta arg2
	lda #10
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette
	jsr fade_in
	jsr credits_wait & $ffff

	LOAD_PTR credits_fade_1
	lda #1
	jsr load_single_palette
	jsr prepare_for_rendering

	ldx #20
	jsr wait_for_frame_count

	LOAD_PTR credits_fade_2
	lda #1
	jsr load_single_palette
	jsr prepare_for_rendering

	ldx #20
	jsr wait_for_frame_count

	LOAD_PTR credits_fade_3
	lda #1
	jsr load_single_palette
	jsr prepare_for_rendering

	jsr credits_wait & $ffff

	LOAD_PTR credits_fade_1
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	ldx #20
	jsr wait_for_frame_count

	LOAD_PTR credits_fade_2
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	ldx #20
	jsr wait_for_frame_count

	LOAD_PTR credits_fade_3
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	jsr credits_wait & $ffff
	jsr fade_out
	jsr clear_screen

	LOAD_PTR credit_string_2
	ldx #11
	ldy #5
	jsr write_string
	ldx #1
	ldy #10
	jsr write_string
	ldx #16
	ldy #12
	jsr write_string
	ldx #17
	ldy #14
	jsr write_string
	ldx #17
	ldy #16
	jsr write_string
	ldx #1
	ldy #19
	jsr write_string
	ldx #17
	ldy #21
	jsr write_string

	lda #0
	sta arg0
	lda #2
	sta arg1
	lda #15
	sta arg2
	lda #2
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	lda #0
	sta arg0
	lda #5
	sta arg1
	lda #15
	sta arg2
	lda #5
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #0
	sta arg0
	lda #9
	sta arg1
	lda #15
	sta arg2
	lda #9
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette_2
	jsr fade_in
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr fade_out
	jsr clear_screen

	LOAD_PTR credit_string_3
	ldx #1
	ldy #7
	jsr write_string
	ldx #16
	ldy #7
	jsr write_string
	ldx #17
	ldy #9
	jsr write_string
	ldx #17
	ldy #11
	jsr write_string
	ldx #1
	ldy #16
	jsr write_string
	ldx #13
	ldy #18
	jsr write_string

	lda #0
	sta arg0
	lda #3
	sta arg1
	lda #5
	sta arg2
	lda #3
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #0
	sta arg0
	lda #8
	sta arg1
	lda #15
	sta arg2
	lda #8
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette
	jsr fade_in
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr fade_out
	jsr clear_screen

	LOAD_PTR credit_string_4
	ldx #1
	ldy #8
	jsr write_string
	ldx #18
	ldy #10
	jsr write_string
	ldx #1
	ldy #15
	jsr write_string
	ldx #18
	ldy #17
	jsr write_string
	ldx #17
	ldy #19
	jsr write_string

	lda #0
	sta arg0
	lda #4
	sta arg1
	lda #15
	sta arg2
	lda #4
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #0
	sta arg0
	lda #7
	sta arg1
	lda #15
	sta arg2
	lda #7
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette
	jsr fade_in
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr fade_out
	jsr clear_screen

	LOAD_PTR credit_string_5
	ldx #1
	ldy #7
	jsr write_string
	ldx #9
	ldy #9
	jsr write_string
	ldx #19
	ldy #11
	jsr write_string
	ldx #15
	ldy #13
	jsr write_string
	ldx #18
	ldy #15
	jsr write_string

	lda #0
	sta arg0
	lda #3
	sta arg1
	lda #15
	sta arg2
	lda #3
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette
	jsr fade_in
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr fade_out
	jsr clear_screen

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard
	jmp normal & $ffff

hard:
	jmp dohard & $ffff
veryhard:
	jmp doveryhard & $ffff

normal:
	LOAD_PTR normal_win_string
	ldx #2
	ldy #6
	jsr write_string
	ldx #2
	ldy #7
	jsr write_string
	ldx #2
	ldy #8
	jsr write_string
	ldx #2
	ldy #9
	jsr write_string
	ldx #2
	ldy #12
	jsr write_string
	ldx #2
	ldy #13
	jsr write_string
	ldx #2
	ldy #14
	jsr write_string
	ldx #2
	ldy #17
	jsr write_string
	ldx #2
	ldy #18
	jsr write_string

	LOAD_PTR credit_flag
	ldx #2
	ldy #21
	jsr write_string
	ldx #2
	ldy #22
	jsr write_string

	jsr get_death_count_string & $ffff
	LOAD_PTR scratch
	ldx #11
	ldy #17
	jsr write_string

	lda #0
	sta arg0
	lda #3
	sta arg1
	lda #15
	sta arg2
	lda #4
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #5
	sta arg0
	lda #8
	sta arg1
	lda #6
	sta arg2
	lda #8
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	lda #0
	sta arg0
	lda #10
	sta arg1
	lda #15
	sta arg2
	lda #11
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette_2
	jsr fade_in

endloop:
	jsr wait_for_vblank
	jmp endloop & $ffff

dohard:
	LOAD_PTR hard_win_string
	ldx #2
	ldy #7
	jsr write_string
	ldx #2
	ldy #8
	jsr write_string
	ldx #2
	ldy #9
	jsr write_string
	ldx #2
	ldy #10
	jsr write_string
	ldx #2
	ldy #11
	jsr write_string
	ldx #2
	ldy #14
	jsr write_string
	ldx #2
	ldy #15
	jsr write_string
	ldx #2
	ldy #16
	jsr write_string
	ldx #2
	ldy #19
	jsr write_string
	ldx #2
	ldy #20
	jsr write_string

	jsr get_death_count_string & $ffff
	LOAD_PTR scratch
	ldx #11
	ldy #19
	jsr write_string

	lda #0
	sta arg0
	lda #3
	sta arg1
	lda #15
	sta arg2
	lda #5
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #5
	sta arg0
	lda #9
	sta arg1
	lda #6
	sta arg2
	lda #9
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette_2
	jsr fade_in
	jmp endloop & $ffff

doveryhard:
	LOAD_PTR very_hard_win_string
	ldx #2
	ldy #10
	jsr write_string
	ldx #2
	ldy #11
	jsr write_string
	ldx #2
	ldy #12
	jsr write_string
	ldx #2
	ldy #13
	jsr write_string
	ldx #2
	ldy #17
	jsr write_string
	ldx #2
	ldy #18
	jsr write_string

	jsr get_death_count_string & $ffff
	LOAD_PTR scratch
	ldx #11
	ldy #17
	jsr write_string

	lda #0
	sta arg0
	lda #5
	sta arg1
	lda #15
	sta arg2
	lda #7
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #5
	sta arg0
	lda #8
	sta arg1
	lda #6
	sta arg2
	lda #8
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	LOAD_PTR credits_palette_2
	jsr fade_in
	jmp endloop & $ffff
.endproc

PROC credits_wait
	ldy #240
topwait:
	jsr wait_for_vblank
	dey
	bne topwait
	rts
.endproc


PROC get_death_count_string
	lda death_count
	cmp #0
	beq twodigits

	lda death_count
	clc
	adc #$30
	sta scratch
	lda death_count + 1
	clc
	adc #$30
	sta scratch + 1
	lda death_count + 2
	clc
	adc #$30
	sta scratch + 2
	lda #0
	sta scratch + 3
	rts

twodigits:
	lda death_count + 1
	cmp #0
	beq onedigit

	lda #$20
	sta scratch
	lda death_count + 1
	clc
	adc #$30
	sta scratch + 1
	lda death_count + 2
	clc
	adc #$30
	sta scratch + 2
	lda #0
	sta scratch + 3
	rts

onedigit:
	lda #$20
	sta scratch
	sta scratch + 1
	lda death_count + 2
	clc
	adc #$30
	sta scratch + 2
	lda #0
	sta scratch + 3
	rts
.endproc


VAR credits_palette
	.byte $0f, $30, $30, $30
	.byte $0f, $0f, $0f, $0f
	.byte $0f, $0f, $0f, $0f
	.byte $0f, $21, $21, $21
	.byte $0f, $30, $30, $30
	.byte $0f, $30, $30, $30
	.byte $0f, $30, $30, $30

VAR credits_palette_2
	.byte $0f, $30, $30, $30
	.byte $0f, $0f, $0f, $0f
	.byte $0f, $37, $37, $37
	.byte $0f, $21, $21, $21
	.byte $0f, $30, $30, $30
	.byte $0f, $30, $30, $30
	.byte $0f, $30, $30, $30

VAR credits_fade_1
	.byte $0f, $00, $00, $00
VAR credits_fade_2
	.byte $0f, $10, $10, $10
VAR credits_fade_3
	.byte $0f, $30, $30, $30

VAR credit_string_1
	.byte "CONGRATULATIONS!", 0
	.byte "YOU HAVE DESTROYED PATIENT", 0
	.byte "ZERO AND SAVED HUMANITY FROM", 0
	.byte "CERTAIN ANNIHILATION.", 0
	.byte "AS YOU EXIT THE LAIR, YOU", 0
	.byte "TRIGGER A MASSIVE EXPLOSION", 0
	.byte "SEALING THE PLAGUE FOREVER.", 0
	.byte "YOU HOPE...", 0

VAR credit_string_2
	.byte "CREDITS", 0
	.byte "PROGRAMMING:",0
	.byte "PETER LAFOSSE",0
	.byte "RUSTY WAGNER", 0
	.byte "JORDAN WIENS", 0
	.byte "GAME ENGINE:",0
	.byte "RUSTY WAGNER",0

VAR credit_string_3
	.byte "ART:",0
	.byte "PETER LAFOSSE",0
	.byte "RUSTY WAGNER", 0
	.byte "JORDAN WIENS", 0
	.byte "COVER ART:",0
	.byte "ANDREW LAMOUREUX", 0

VAR credit_string_4
	.byte "MUSIC:",0
	.byte "ALEX TAYLOR", 0
	.byte "SFX:",0
	.byte "ALEX TAYLOR", 0
	.byte "RUSTY WAGNER", 0

VAR credit_string_5
	.byte "SPECIAL THANKS:",0
	.byte "INFINITENESLIVES.COM",0
	.byte "ERIC LIANG",0
	.byte "GERI DELPRIORE",0
	.byte "NASIR MEMON",0

VAR normal_win_string
	.byte "YOU HAVE ENDED THE ZOMBIE", 0
	.byte "INFESTATION ON NORMAL", 0
	.byte "DIFFICULTY. CAN YOU", 0
	.byte "SURVIVE HARD DIFFICULTY?", 0
	.byte "CONTINUE FROM YOUR SAVE OR", 0
	.byte "ENTER ", $22, "QUEST 2.0", $22, " AS YOUR", 0
	.byte "NAME TO TRY.", 0
	.byte "YOU DIED 000 TIMES DURING", 0
	.byte "YOUR QUEST.", 0

VAR hard_win_string
	.byte "YOU HAVE ENDED THE ZOMBIE", 0
	.byte "INFESTATION ON THE HARD", 0
	.byte "DIFFICULTY. CAN YOU", 0
	.byte "SURVIVE APOCALYPSE", 0
	.byte "DIFFICULTY?", 0
	.byte "CONTINUE FROM YOUR SAVE OR", 0
	.byte "ENTER ", $22, "UNBEARABLE", $22, " AS YOUR", 0
	.byte "NAME TO TRY.", 0
	.byte "YOU DIED 000 TIMES DURING", 0
	.byte "YOUR QUEST.", 0

VAR very_hard_win_string
	.byte "YOU HAVE ENDED THE ZOMBIE", 0
	.byte "INFESTATION ON THE HARDEST", 0
	.byte "DIFFICULTY. YOU ARE", 0
	.byte "HUMANITY", $40, "S HERO.", 0
	.byte "YOU DIED 000 TIMES DURING", 0
	.byte "YOUR QUEST.", 0

.bss

VAR game_beaten
	.byte 0
