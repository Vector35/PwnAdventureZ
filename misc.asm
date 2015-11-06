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

PROC byte_to_str
	sta temp

	lda current_bank
	pha
	lda #^byte_to_low_digit_table
	jsr bankswitch

	lda temp
	cmp #10
	bcc single
	cmp #100
	bcc double

	tax
	clc
	lda byte_to_high_digit_table & $ffff, x
	adc #'0'
	sta scratch
	lda byte_to_mid_digit_table & $ffff, x
	adc #'0'
	sta scratch + 1
	lda byte_to_low_digit_table & $ffff, x
	adc #'0'
	sta scratch + 2
	lda #0
	sta scratch + 3
	lda #3
	jmp done

single:
	tax
	clc
	lda byte_to_low_digit_table & $ffff, x
	adc #'0'
	sta scratch
	lda #0
	sta scratch + 1
	lda #1
	jmp done

double:
	tax
	clc
	lda byte_to_mid_digit_table & $ffff, x
	adc #'0'
	sta scratch
	lda byte_to_low_digit_table & $ffff, x
	adc #'0'
	sta scratch + 1
	lda #0
	sta scratch + 2
	lda #2
	jmp done

done:
	sta temp
	pla
	jsr bankswitch
	lda temp
	rts
.endproc


PROC byte_to_padded_str
	sta temp

	lda current_bank
	pha
	lda #^byte_to_low_digit_table
	jsr bankswitch

	lda temp
	cmp #10
	bcc single
	cmp #100
	bcc double

	tax
	clc
	lda byte_to_high_digit_table & $ffff, x
	adc #'0'
	sta scratch
mid:
	clc
	lda byte_to_mid_digit_table & $ffff, x
	adc #'0'
	sta scratch + 1
low:
	clc
	lda byte_to_low_digit_table & $ffff, x
	adc #'0'
	sta scratch + 2
	lda #0
	sta scratch + 3

	pla
	jsr bankswitch
	rts

single:
	tax
	lda #' '
	sta scratch
	sta scratch + 1
	jmp low

double:
	tax
	lda #' '
	sta scratch
	jmp mid
.endproc


.segment "EXTRA"

VAR byte_to_low_digit_table
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	.byte 0, 1, 2, 3, 4, 5

VAR byte_to_mid_digit_table
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	.byte 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
	.byte 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
	.byte 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
	.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	.byte 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
	.byte 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
	.byte 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
	.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	.byte 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
	.byte 5, 5, 5, 5, 5, 5

VAR byte_to_high_digit_table
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 2, 2
