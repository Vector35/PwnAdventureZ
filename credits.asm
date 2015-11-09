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
	jsr disable_rendering
	jsr clear_screen

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

	LOAD_PTR credits_palette
	jsr fade_in
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
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

	LOAD_PTR credits_palette
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
	ldx #10
	ldy #9
	jsr write_string
	ldx #20
	ldy #11
	jsr write_string
	ldx #16
	ldy #13
	jsr write_string
	ldx #18
	ldy #15
	jsr write_string

	LOAD_PTR credits_palette
	jsr fade_in
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr credits_wait & $ffff
	jsr fade_out
	jsr clear_screen
	jmp start & $ffff

	;!TODO: Display flag, death count hint for 2.0 or 3.0

.endproc

PROC credits_wait
	ldy #240
topwait:
	jsr wait_for_vblank
	dey
	bne topwait
	rts
.endproc

VAR credits_palette
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30

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
	.byte "NASSIR MEMON",0
