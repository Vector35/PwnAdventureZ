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

PROC write_mapper_8000
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	rts
.endproc


PROC write_mapper_a000
	sta $a000
	lsr
	sta $a000
	lsr
	sta $a000
	lsr
	sta $a000
	lsr
	sta $a000
	rts
.endproc


PROC write_mapper_e000
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	lsr
	sta $e000
	rts
.endproc


PROC reset_mapper
	; Reset the mapper write state
	lda #$80
	sta $8000

	; Init settings (8k CHR, 16k PRG, $8000 swap, vertical)
	lda #$0e
	jsr write_mapper_8000

	; Set CHR select to 0, disable save RAM for some SNROM boards
	lda #$10
	jsr write_mapper_a000

	; Map first bank into $8000, disable save RAM until accessing
	lda #$10
	jsr write_mapper_e000

	rts
.endproc


PROC bankswitch
	pha

	lda save_ram_enabled
	bne ramenabled

	lda in_nmi
	bne nmi

loop:
	lda vblank_count
	sta bankswitch_vblank_count

nmi:
	lda #$80
	sta $8000

	pla
	pha
	ora #$10
	jsr write_mapper_e000

	lda in_nmi
	bne done

	lda vblank_count
	cmp bankswitch_vblank_count
	bne loop

done:
	pla
	rts

ramenabled:
	lda in_nmi
	bne ramnmi

ramloop:
	lda vblank_count
	sta bankswitch_vblank_count

ramnmi:
	lda #$80
	sta $8000

	pla
	pha
	jsr write_mapper_e000

	lda in_nmi
	bne ramdone

	lda vblank_count
	cmp bankswitch_vblank_count
	bne ramloop

ramdone:
	pla
	rts
.endproc


PROC has_save_ram
	lda #0
	rts
.endproc


PROC enable_save_ram
	lda #1
	sta save_ram_enabled

	lda in_nmi
	bne nmi

loop:
	lda vblank_count
	sta bankswitch_vblank_count

nmi:
	; Enable RAM in both CHR and PRG select registers, as the original SNROM boards
	; used CHR select bit 4 as a write protect as well
	lda #$80
	sta $8000

	lda current_bank
	jsr write_mapper_e000

	lda #$00
	jsr write_mapper_a000

	lda in_nmi
	bne done

	lda vblank_count
	cmp bankswitch_vblank_count
	bne loop
done:
	rts
.endproc


PROC disable_save_ram
	lda #0
	sta save_ram_enabled

	lda in_nmi
	bne nmi

loop:
	lda vblank_count
	sta bankswitch_vblank_count

nmi:
	; Disable RAM in both CHR and PRG select registers, as the original SNROM boards
	; used CHR select bit 4 as a write protect as well
	lda #$80
	sta $8000

	lda current_bank
	ora #$10
	jsr write_mapper_e000

	lda #$10
	jsr write_mapper_a000

	lda in_nmi
	bne done

	lda vblank_count
	cmp bankswitch_vblank_count
	bne loop
done:
	rts
.endproc


PROC clear_save_header
	ldy #0
	lda #0
clearloop:
	sta (ptr), y
	iny
	cpy #$20
	bne clearloop
	rts
.endproc


PROC clear_slot_0
	jsr enable_save_ram
	ldx #0
	lda #0
clearloop:
	sta $6300, x
	sta $6400, x
	sta $6500, x
	sta $6d00, x
	sta $6e00, x
	sta $6f00, x
	sta $7700, x
	sta $7800, x
	sta $7900, x
	inx
	bne clearloop
	LOAD_PTR $6c00
	jsr clear_save_header
	LOAD_PTR $6ca0
	jsr clear_save_header
	LOAD_PTR $76a0
	jsr clear_save_header
	jsr disable_save_ram
	rts
.endproc


PROC clear_slot_1
	jsr enable_save_ram
	ldx #0
	lda #0
clearloop:
	sta $6600, x
	sta $6700, x
	sta $6800, x
	sta $7000, x
	sta $7100, x
	sta $7200, x
	sta $7a00, x
	sta $7b00, x
	sta $7c00, x
	inx
	bne clearloop
	LOAD_PTR $6c20
	jsr clear_save_header
	LOAD_PTR $6cc0
	jsr clear_save_header
	LOAD_PTR $76c0
	jsr clear_save_header
	jsr disable_save_ram
	rts
.endproc


PROC clear_slot_2
	jsr enable_save_ram
	ldx #0
	lda #0
clearloop:
	sta $6900, x
	sta $6a00, x
	sta $6b00, x
	sta $7300, x
	sta $7400, x
	sta $7500, x
	sta $7d00, x
	sta $7e00, x
	sta $7f00, x
	inx
	bne clearloop
	LOAD_PTR $6c40
	jsr clear_save_header
	LOAD_PTR $6ce0
	jsr clear_save_header
	LOAD_PTR $76e0
	jsr clear_save_header
	jsr disable_save_ram
	rts
.endproc


PROC update_checksum
	eor checksum
	sta checksum

	ldx #0
loop:
	lda checksum
	and #1
	bne one

	clc
	ror checksum + 1
	ror checksum
	jmp next

one:
	clc
	ror checksum + 1
	ror checksum
	lda checksum
	eor #1
	sta checksum
	lda checksum + 1
	eor #$a0
	sta checksum + 1

next:
	inx
	cpx #8
	bne loop

	rts
.endproc


PROC update_header_checksum
	ldy #0
updateloop:
	lda (ptr), y
	jsr update_checksum
	iny
	cpy #SAVE_HEADER_CHECKSUM
	bne updateloop
	rts
.endproc


PROC write_header_checksum
	lda checksum
	sta (ptr), y
	iny
	lda checksum + 1
	sta (ptr), y
	rts
.endproc


PROC write_save_header
	lda #'P'
	ldy #0
	sta (ptr), y
	iny
	lda #'w'
	sta (ptr), y
	iny
	lda #'n'
	sta (ptr), y
	iny
	lda #'Z'
	sta (ptr), y
	iny

	ldx #0
nameloop:
	lda name, x
	sta (ptr), y
	iny
	inx
	cpx #14
	bne nameloop

	lda difficulty
	sta (ptr), y
	iny

	lda key_count
	sta (ptr), y
	iny

	ldx #0
timeloop:
	lda time_played, x
	sta (ptr), y
	iny
	inx
	cpx #6
	bne timeloop

	rts
.endproc


PROC save_ram_to_slot_0
	jsr enable_save_ram

	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
saveloop1:
	lda $0000, y
	sta $6300, y
	jsr update_checksum
	lda $0300, y
	sta $6400, y
	jsr update_checksum
	lda $0400, y
	sta $6500, y
	jsr update_checksum
	iny
	bne saveloop1

	LOAD_PTR $6c00
	jsr write_save_header
	jsr update_header_checksum
	jsr write_header_checksum

	lda #0
	sta checksum
	sta checksum + 1
	ldy #0
saveloop2:
	lda $0000, y
	sta $6d00, y
	lda $0300, y
	sta $6e00, y
	lda $0400, y
	sta $6f00, y
	iny
	bne saveloop2

	LOAD_PTR $6ca0
	jsr write_save_header
	jsr write_header_checksum

	lda #0
	sta checksum
	sta checksum + 1
	ldy #0
saveloop3:
	lda $0000, y
	sta $7700, y
	lda $0300, y
	sta $7800, y
	lda $0400, y
	sta $7900, y
	iny
	bne saveloop3

	LOAD_PTR $76a0
	jsr write_save_header
	jsr write_header_checksum

	jsr disable_save_ram
	rts
.endproc


PROC save_ram_to_slot_1
	jsr enable_save_ram

	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
saveloop1:
	lda $0000, y
	sta $6600, y
	jsr update_checksum
	lda $0300, y
	sta $6700, y
	jsr update_checksum
	lda $0400, y
	sta $6800, y
	jsr update_checksum
	iny
	bne saveloop1

	LOAD_PTR $6c20
	jsr write_save_header
	jsr update_header_checksum
	jsr write_header_checksum

	lda #0
	sta checksum
	sta checksum + 1
	ldy #0
saveloop2:
	lda $0000, y
	sta $7000, y
	lda $0300, y
	sta $7100, y
	lda $0400, y
	sta $7200, y
	iny
	bne saveloop2

	LOAD_PTR $6cc0
	jsr write_save_header
	jsr write_header_checksum

	lda #0
	sta checksum
	sta checksum + 1
	ldy #0
saveloop3:
	lda $0000, y
	sta $7a00, y
	lda $0300, y
	sta $7b00, y
	lda $0400, y
	sta $7c00, y
	iny
	bne saveloop3

	LOAD_PTR $76c0
	jsr write_save_header
	jsr write_header_checksum

	jsr disable_save_ram
	rts
.endproc


PROC save_ram_to_slot_2
	jsr enable_save_ram


	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
saveloop1:
	lda $0000, y
	sta $6900, y
	jsr update_checksum
	lda $0300, y
	sta $6a00, y
	jsr update_checksum
	lda $0400, y
	sta $6b00, y
	jsr update_checksum
	iny
	bne saveloop1

	LOAD_PTR $6c40
	jsr write_save_header
	jsr update_header_checksum
	jsr write_header_checksum

	lda #0
	sta checksum
	sta checksum + 1
	ldy #0
saveloop2:
	lda $0000, y
	sta $7300, y
	lda $0300, y
	sta $7400, y
	lda $0400, y
	sta $7500, y
	iny
	bne saveloop2

	LOAD_PTR $6ce0
	jsr write_save_header
	jsr write_header_checksum

	lda #0
	sta checksum
	sta checksum + 1
	ldy #0
saveloop3:
	lda $0000, y
	sta $7d00, y
	lda $0300, y
	sta $7e00, y
	lda $0400, y
	sta $7f00, y
	iny
	bne saveloop3

	LOAD_PTR $76e0
	jsr write_save_header
	jsr write_header_checksum

	jsr disable_save_ram
	rts
.endproc


PROC restore_ram_from_slot_0
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $6300, x
	sta $0000, x
	lda $6400, x
	sta $0300, x
	lda $6500, x
	sta $0400, x
	inx
	bne saveloop

	jsr disable_save_ram
	rts
.endproc


PROC restore_ram_from_slot_1
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $6600, x
	sta $0000, x
	lda $6700, x
	sta $0300, x
	lda $6800, x
	sta $0400, x
	inx
	bne saveloop

	jsr disable_save_ram
	rts
.endproc


PROC restore_ram_from_slot_2
	jsr enable_save_ram

	ldx #0
saveloop:
	lda $6900, x
	sta $0000, x
	lda $6a00, x
	sta $0300, x
	lda $6b00, x
	sta $0400, x
	inx
	bne saveloop

	jsr disable_save_ram
	rts
.endproc


PROC clear_slot
	cmp #1
	beq slot1
	cmp #2
	beq slot2
	jmp clear_slot_0
slot1:
	jmp clear_slot_1
slot2:
	jmp clear_slot_2
.endproc


PROC save_ram_to_slot
	cmp #1
	beq slot1
	cmp #2
	beq slot2
	jmp save_ram_to_slot_0
slot1:
	jmp save_ram_to_slot_1
slot2:
	jmp save_ram_to_slot_2
.endproc


PROC restore_ram_from_slot
	cmp #1
	beq slot1
	cmp #2
	beq slot2
	jmp restore_ram_from_slot_0
slot1:
	jmp restore_ram_from_slot_1
slot2:
	jmp restore_ram_from_slot_2
.endproc


PROC is_save_slot_valid
	pha
	jsr enable_save_ram
	pla

	asl
	asl
	asl
	asl
	asl
	tax
	lda $6c00, x
	cmp #'P'
	bne notvalid
	lda $6c01, x
	cmp #'w'
	bne notvalid
	lda $6c02, x
	cmp #'n'
	bne notvalid
	lda $6c03, x
	cmp #'Z'

notvalid:
	php
	jsr disable_save_ram
	plp
	rts
.endproc


PROC validate_saves
	lda current_bank
	pha
	lda #^do_validate_saves
	jsr bankswitch
	jsr do_validate_saves & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_validate_saves
	; Check primary copy of save slot 0 for accuracy
	jsr enable_save_ram

	lda $6c00
	cmp #'P'
	bne save0aheadernotvalid
	lda $6c01
	cmp #'w'
	bne save0aheadernotvalid
	lda $6c02
	cmp #'n'
	bne save0aheadernotvalid
	lda $6c03
	cmp #'Z'
	bne save0aheadernotvalid
	jmp save0aheadervalid & $ffff

save0aheadernotvalid:
	jmp save0anotvalid & $ffff

save0aheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop0a:
	lda $6300, y
	jsr update_checksum
	lda $6400, y
	jsr update_checksum
	lda $6500, y
	jsr update_checksum
	iny
	bne checksumloop0a
	LOAD_PTR $6c00
	jsr update_header_checksum

	lda checksum
	cmp $6c00 + SAVE_HEADER_CHECKSUM
	bne save0anotvalid
	lda checksum + 1
	cmp $6c00 + SAVE_HEADER_CHECKSUM + 1
	bne save0anotvalid

	; First save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop0a:
	lda $6300, y
	sta $6d00, y
	sta $7700, y
	lda $6400, y
	sta $6e00, y
	sta $7800, y
	lda $6500, y
	sta $6f00, y
	sta $7900, y
	iny
	bne copyloop0a

	ldy #0
headerloop0a:
	lda $6c00, y
	sta $6ca0, y
	sta $76a0, y
	iny
	cpy #$20
	bne headerloop0a

	jmp checksave1 & $ffff

save0anotvalid:
	; Check second copy of save slot 0 for accuracy
	lda $6ca0
	cmp #'P'
	bne save0bheadernotvalid
	lda $6ca1
	cmp #'w'
	bne save0bheadernotvalid
	lda $6ca2
	cmp #'n'
	bne save0bheadernotvalid
	lda $6ca3
	cmp #'Z'
	bne save0bheadernotvalid
	jmp save0bheadervalid & $ffff

save0bheadernotvalid:
	jmp save0bnotvalid & $ffff

save0bheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop0b:
	lda $6d00, y
	jsr update_checksum
	lda $6e00, y
	jsr update_checksum
	lda $6f00, y
	jsr update_checksum
	iny
	bne checksumloop0b
	LOAD_PTR $6ca0
	jsr update_header_checksum

	lda checksum
	cmp $6ca0 + SAVE_HEADER_CHECKSUM
	bne save0bnotvalid
	lda checksum + 1
	cmp $6ca0 + SAVE_HEADER_CHECKSUM + 1
	bne save0bnotvalid

	; Second save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop0b:
	lda $6d00, y
	sta $6300, y
	sta $7700, y
	lda $6e00, y
	sta $6400, y
	sta $7800, y
	lda $6f00, y
	sta $6500, y
	sta $7900, y
	iny
	bne copyloop0b

	ldy #0
headerloop0b:
	lda $6ca0, y
	sta $6c00, y
	sta $76a0, y
	iny
	cpy #$20
	bne headerloop0b

	jmp checksave1 & $ffff

save0bnotvalid:
	; Check third copy of save slot 0 for accuracy
	lda $76a0
	cmp #'P'
	bne save0cheadernotvalid
	lda $76a1
	cmp #'w'
	bne save0cheadernotvalid
	lda $76a2
	cmp #'n'
	bne save0cheadernotvalid
	lda $76a3
	cmp #'Z'
	bne save0cheadernotvalid
	jmp save0cheadervalid & $ffff

save0cheadernotvalid:
	jmp save0cnotvalid & $ffff

save0cheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop0c:
	lda $7700, y
	jsr update_checksum
	lda $7800, y
	jsr update_checksum
	lda $7900, y
	jsr update_checksum
	iny
	bne checksumloop0c
	LOAD_PTR $76a0
	jsr update_header_checksum

	lda checksum
	cmp $76a0 + SAVE_HEADER_CHECKSUM
	bne save0cnotvalid
	lda checksum + 1
	cmp $76a0 + SAVE_HEADER_CHECKSUM + 1
	bne save0cnotvalid

	; Third save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop0c:
	lda $7700, y
	sta $6300, y
	sta $6d00, y
	lda $7800, y
	sta $6400, y
	sta $6e00, y
	lda $7900, y
	sta $6500, y
	sta $6f00, y
	iny
	bne copyloop0c

	ldy #0
headerloop0c:
	lda $76a0, y
	sta $6c00, y
	sta $6ca0, y
	iny
	cpy #$20
	bne headerloop0c

	jmp checksave1 & $ffff

save0cnotvalid:
	; No valid saves for slot 0, clear it
	jsr clear_slot_0
	jsr enable_save_ram

checksave1:
	; Check primary copy of save slot 1 for accuracy
	lda $6c20
	cmp #'P'
	bne save1aheadernotvalid
	lda $6c21
	cmp #'w'
	bne save1aheadernotvalid
	lda $6c22
	cmp #'n'
	bne save1aheadernotvalid
	lda $6c23
	cmp #'Z'
	bne save1aheadernotvalid
	jmp save1aheadervalid & $ffff

save1aheadernotvalid:
	jmp save1anotvalid & $ffff

save1aheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop1a:
	lda $6600, y
	jsr update_checksum
	lda $6700, y
	jsr update_checksum
	lda $6800, y
	jsr update_checksum
	iny
	bne checksumloop1a
	LOAD_PTR $6c20
	jsr update_header_checksum

	lda checksum
	cmp $6c20 + SAVE_HEADER_CHECKSUM
	bne save1anotvalid
	lda checksum + 1
	cmp $6c20 + SAVE_HEADER_CHECKSUM + 1
	bne save1anotvalid

	; First save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop1a:
	lda $6600, y
	sta $7000, y
	sta $7a00, y
	lda $6700, y
	sta $7100, y
	sta $7b00, y
	lda $6800, y
	sta $7200, y
	sta $7c00, y
	iny
	bne copyloop1a

	ldy #0
headerloop1a:
	lda $6c20, y
	sta $6cc0, y
	sta $76c0, y
	iny
	cpy #$20
	bne headerloop1a

	jmp checksave2 & $ffff

save1anotvalid:
	; Check second copy of save slot 1 for accuracy
	lda $6cc0
	cmp #'P'
	bne save1bheadernotvalid
	lda $6cc1
	cmp #'w'
	bne save1bheadernotvalid
	lda $6cc2
	cmp #'n'
	bne save1bheadernotvalid
	lda $6cc3
	cmp #'Z'
	bne save1bheadernotvalid
	jmp save1bheadervalid & $ffff

save1bheadernotvalid:
	jmp save1bnotvalid & $ffff

save1bheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop1b:
	lda $7000, y
	jsr update_checksum
	lda $7100, y
	jsr update_checksum
	lda $7200, y
	jsr update_checksum
	iny
	bne checksumloop1b
	LOAD_PTR $6cc0
	jsr update_header_checksum

	lda checksum
	cmp $6cc0 + SAVE_HEADER_CHECKSUM
	bne save1bnotvalid
	lda checksum + 1
	cmp $6cc0 + SAVE_HEADER_CHECKSUM + 1
	bne save1bnotvalid

	; Second save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop1b:
	lda $7000, y
	sta $6600, y
	sta $7a00, y
	lda $7100, y
	sta $6700, y
	sta $7b00, y
	lda $7200, y
	sta $6800, y
	sta $7c00, y
	iny
	bne copyloop1b

	ldy #0
headerloop1b:
	lda $6cc0, y
	sta $6c20, y
	sta $76c0, y
	iny
	cpy #$20
	bne headerloop1b

	jmp checksave2 & $ffff

save1bnotvalid:
	; Check third copy of save slot 1 for accuracy
	lda $76c0
	cmp #'P'
	bne save1cheadernotvalid
	lda $76c1
	cmp #'w'
	bne save1cheadernotvalid
	lda $76c2
	cmp #'n'
	bne save1cheadernotvalid
	lda $76c3
	cmp #'Z'
	bne save1cheadernotvalid
	jmp save1cheadervalid & $ffff

save1cheadernotvalid:
	jmp save1cnotvalid & $ffff

save1cheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop1c:
	lda $7a00, y
	jsr update_checksum
	lda $7b00, y
	jsr update_checksum
	lda $7c00, y
	jsr update_checksum
	iny
	bne checksumloop1c
	LOAD_PTR $76c0
	jsr update_header_checksum

	lda checksum
	cmp $76c0 + SAVE_HEADER_CHECKSUM
	bne save1cnotvalid
	lda checksum + 1
	cmp $76c0 + SAVE_HEADER_CHECKSUM + 1
	bne save1cnotvalid

	; Third save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop1c:
	lda $7a00, y
	sta $6600, y
	sta $7000, y
	lda $7b00, y
	sta $6700, y
	sta $7100, y
	lda $7c00, y
	sta $6800, y
	sta $7200, y
	iny
	bne copyloop1c

	ldy #0
headerloop1c:
	lda $76c0, y
	sta $6c20, y
	sta $6cc0, y
	iny
	cpy #$20
	bne headerloop1c

	jmp checksave2 & $ffff

save1cnotvalid:
	; No valid saves for slot 1, clear it
	jsr clear_slot_1
	jsr enable_save_ram

checksave2:
	; Check primary copy of save slot 2 for accuracy
	lda $6c40
	cmp #'P'
	bne save2aheadernotvalid
	lda $6c41
	cmp #'w'
	bne save2aheadernotvalid
	lda $6c42
	cmp #'n'
	bne save2aheadernotvalid
	lda $6c43
	cmp #'Z'
	bne save2aheadernotvalid
	jmp save2aheadervalid & $ffff

save2aheadernotvalid:
	jmp save2anotvalid & $ffff

save2aheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop2a:
	lda $6900, y
	jsr update_checksum
	lda $6a00, y
	jsr update_checksum
	lda $6b00, y
	jsr update_checksum
	iny
	bne checksumloop2a
	LOAD_PTR $6c40
	jsr update_header_checksum

	lda checksum
	cmp $6c40 + SAVE_HEADER_CHECKSUM
	bne save2anotvalid
	lda checksum + 1
	cmp $6c40 + SAVE_HEADER_CHECKSUM + 1
	bne save2anotvalid

	; First save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop2a:
	lda $6900, y
	sta $7300, y
	sta $7d00, y
	lda $6a00, y
	sta $7400, y
	sta $7e00, y
	lda $6b00, y
	sta $7500, y
	sta $7f00, y
	iny
	bne copyloop2a

	ldy #0
headerloop2a:
	lda $6c40, y
	sta $6ce0, y
	sta $76e0, y
	iny
	cpy #$20
	bne headerloop2a

	jmp done & $ffff

save2anotvalid:
	; Check second copy of save slot 2 for accuracy
	lda $6ce0
	cmp #'P'
	bne save2bheadernotvalid
	lda $6ce1
	cmp #'w'
	bne save2bheadernotvalid
	lda $6ce2
	cmp #'n'
	bne save2bheadernotvalid
	lda $6ce3
	cmp #'Z'
	bne save2bheadernotvalid
	jmp save2bheadervalid & $ffff

save2bheadernotvalid:
	jmp save2bnotvalid & $ffff

save2bheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop2b:
	lda $7300, y
	jsr update_checksum
	lda $7400, y
	jsr update_checksum
	lda $7500, y
	jsr update_checksum
	iny
	bne checksumloop2b
	LOAD_PTR $6ce0
	jsr update_header_checksum

	lda checksum
	cmp $6ce0 + SAVE_HEADER_CHECKSUM
	bne save2bnotvalid
	lda checksum + 1
	cmp $6ce0 + SAVE_HEADER_CHECKSUM + 1
	bne save2bnotvalid

	; Second save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop2b:
	lda $7300, y
	sta $6900, y
	sta $7d00, y
	lda $7400, y
	sta $6a00, y
	sta $7e00, y
	lda $7500, y
	sta $6b00, y
	sta $7f00, y
	iny
	bne copyloop2b

	ldy #0
headerloop2b:
	lda $6ce0, y
	sta $6c40, y
	sta $76e0, y
	iny
	cpy #$20
	bne headerloop2b

	jmp done & $ffff

save2bnotvalid:
	; Check third copy of save slot 2 for accuracy
	lda $76e0
	cmp #'P'
	bne save2cheadernotvalid
	lda $76e1
	cmp #'w'
	bne save2cheadernotvalid
	lda $76e2
	cmp #'n'
	bne save2cheadernotvalid
	lda $76e3
	cmp #'Z'
	bne save2cheadernotvalid
	jmp save2cheadervalid & $ffff

save2cheadernotvalid:
	jmp save2cnotvalid & $ffff

save2cheadervalid:
	lda #0
	sta checksum
	sta checksum + 1

	lda version_hash
	jsr update_checksum
	lda version_hash + 1
	jsr update_checksum
	lda version_hash + 2
	jsr update_checksum
	lda version_hash + 3
	jsr update_checksum

	ldy #0
checksumloop2c:
	lda $7d00, y
	jsr update_checksum
	lda $7e00, y
	jsr update_checksum
	lda $7f00, y
	jsr update_checksum
	iny
	bne checksumloop2c
	LOAD_PTR $76e0
	jsr update_header_checksum

	lda checksum
	cmp $76e0 + SAVE_HEADER_CHECKSUM
	bne save2cnotvalid
	lda checksum + 1
	cmp $76e0 + SAVE_HEADER_CHECKSUM + 1
	bne save2cnotvalid

	; Third save is valid, copy to backup locations to ensure they are valid as well
	ldy #0
copyloop2c:
	lda $7d00, y
	sta $6900, y
	sta $7300, y
	lda $7e00, y
	sta $6a00, y
	sta $7400, y
	lda $7f00, y
	sta $6b00, y
	sta $7500, y
	iny
	bne copyloop2c

	ldy #0
headerloop2c:
	lda $76e0, y
	sta $6c40, y
	sta $6ce0, y
	iny
	cpy #$20
	bne headerloop2c

	jmp done & $ffff

save2cnotvalid:
	; No valid saves for slot 2, clear it
	jsr clear_slot_2
	jsr enable_save_ram

done:
	jsr disable_save_ram
	rts
.endproc


.segment "FIXED"

PROC generate_minimap_cache
	lda current_bank
	pha

	jsr enable_save_ram

	lda map_bank
	jsr bankswitch

	lda #0
	sta arg1
genyloop:
	lda #0
	sta arg0
genxloop:
	ldx arg0
	ldy arg1
	jsr read_overworld_map_known_bank

	and #$3f
	jsr get_minimap_tile_for_type

	ldx arg0
	ldy arg1
	jsr write_minimap_cache

	ldx arg0
	inx
	stx arg0
	cpx #26
	beq xwrap
	jmp genxloop
xwrap:
	ldy arg1
	iny
	sty arg1
	cpy #22
	beq gendone
	jmp genyloop

gendone:
	; Draw contoured edges for rocks, lakes, and bases
	jsr process_minimap_border_sides

	; Generate cave entrance tiles
	lda #0
	sta arg1
caveyloop:
	lda #0
	sta arg0
cavexloop:
	ldx arg0
	ldy arg1
	jsr read_overworld_map_known_bank

	cmp #MAP_CAVE_INTERIOR
	beq cave
	cmp #MAP_CAVE_INTERIOR + $40
	beq cave
	cmp #MAP_STARTING_CAVE
	beq cave
	cmp #MAP_STARTING_CAVE + $40
	beq cave
	cmp #MAP_BLOCKY_CAVE
	beq cave
	cmp #MAP_BLOCKY_CAVE + $40
	beq cave
	cmp #MAP_LOST_CAVE
	beq cave
	cmp #MAP_LOST_CAVE + $40
	beq cave
	cmp #MAP_MINE_ENTRANCE
	beq cave
	cmp #MAP_MINE_ENTRANCE + $40
	beq cave
	jmp nextcave

cave:
	ldx arg0
	ldy arg1
	iny
	jsr read_overworld_map_known_bank
	and #$3f
	jsr is_map_type_forest
	beq nextcave

	lda #MINIMAP_TILE_CAVE_ENTRANCE
	ldx arg0
	ldy arg1
	jsr write_minimap_cache

nextcave:
	ldx arg0
	inx
	stx arg0
	cpx #26
	beq xwrapcave
	jmp cavexloop
xwrapcave:
	ldy arg1
	iny
	sty arg1
	cpy #22
	beq cavedone
	jmp caveyloop

cavedone:
	jsr disable_save_ram

	pla
	jsr bankswitch
	rts
.endproc


PROC process_minimap_border_sides
	lda current_bank
	pha
	lda #^do_process_minimap_border_sides
	jsr bankswitch
	jsr do_process_minimap_border_sides & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_process_minimap_border_sides
	; Convert borders into the correct tile to account for surroundings.  This will
	; give them a contour along the edges.
	ldy #0
yloop:
	ldx #0
xloop:
	jsr process_minimap_border_sides_for_tile & $ffff
	inx
	cpx #26
	bne xloop
	iny
	cpy #22
	bne yloop
	rts
.endproc


PROC process_minimap_border_sides_for_tile
	txa
	sta arg0
	tya
	sta arg1

	; If the tile is empty space, don't touch it
	jsr read_minimap_cache
	cmp #MINIMAP_TILE_ROCK + SMALL_BORDER_CENTER
	beq checkrock
	cmp #MINIMAP_TILE_LAKE + SMALL_BORDER_CENTER
	beq checklake
	cmp #MINIMAP_TILE_BASE + SMALL_BORDER_CENTER
	beq checkbase
	jmp done & $ffff

checkrock:
	lda #MINIMAP_TILE_ROCK
	sta border_tile_base
	lda #MINIMAP_TILE_ROCK + SMALL_BORDER_INTERIOR
	sta border_tile_interior
	jmp solid & $ffff
checklake:
	lda #MINIMAP_TILE_LAKE
	sta border_tile_base
	lda #MINIMAP_TILE_LAKE + SMALL_BORDER_INTERIOR
	sta border_tile_interior
	jmp solid & $ffff
checkbase:
	lda #MINIMAP_TILE_BASE
	sta border_tile_base
	lda #MINIMAP_TILE_BASE + SMALL_BORDER_INTERIOR
	sta border_tile_interior
	jmp solid & $ffff

solid:
	; Create a bit mask based on the 8 surrounding tiles, where the bit is set
	; if the tile is a border wall or outside the map
	lda #0
	sta arg4
	lda #$80
	sta arg5

	lda #$ff
	sta arg3
yloop:
	lda #$ff
	sta arg2
xloop:
	; Skip center as we already know it is solid, and we have only 8 bits
	lda arg2
	cmp #0
	bne notcenter
	lda arg3
	cmp #0
	bne notcenter
	jmp skip & $ffff

notcenter:
	; Compute X and check for bounds
	lda arg0
	clc
	adc arg2
	cmp #$ff
	beq out
	cmp #26
	beq out
	tax

	; Compute Y and check for bounds
	lda arg1
	clc
	adc arg3
	cmp #$ff
	beq out
	cmp #22
	beq out
	tay

	; Read map and check for a border wall
	jsr read_minimap_cache
	cmp border_tile_base
	bcc next
	cmp border_tile_interior
	beq next

out:
	; Solid, mark the bit
	lda arg4
	ora arg5
	sta arg4

next:
	; Move to next bit
	lda arg5
	lsr
	sta arg5

skip:
	; Go to next tile
	ldx arg2
	inx
	stx arg2
	cpx #2
	bne xloop

	ldy arg3
	iny
	sty arg3
	cpy #2
	bne yloop

	; The bit mask has been generated, look it up in the table to get the proper tile
	ldy arg4
	lda border_tile_for_sides, y
	lsr
	lsr
	clc
	adc border_tile_base

	; Write the new tile to the map
	ldx arg0
	ldy arg1
	jsr write_minimap_cache

done:
	lda arg0
	tax
	lda arg1
	tay
	rts
.endproc


.segment "FIXED"

PROC get_minimap_cache_ptr
	tya
	lsr
	lsr
	lsr
	clc
	adc #>minimap_cache
	sta temp + 1

	tya
	asl
	asl
	asl
	asl
	asl
	sta temp
	txa
	clc
	adc temp
	adc #<minimap_cache
	sta temp
	lda temp + 1
	adc #0
	sta temp + 1

	rts
.endproc


PROC read_minimap_cache
	jsr get_minimap_cache_ptr
	ldy #0
	lda (temp), y
	rts
.endproc


PROC write_minimap_cache
	pha
	jsr get_minimap_cache_ptr
	ldy #0
	pla
	sta (temp), y
	rts
.endproc


PROC render_minimap
	jsr enable_save_ram

	lda #0
	sta arg1
	LOAD_PTR minimap_cache

loop:
	ldx #2
	lda arg1
	clc
	adc #32 + 2
	tay
	lda #26
	jsr write_tiles

	ldy #6
	jsr add_y_to_ptr

	ldy arg1
	iny
	sty arg1
	cpy #22
	bne loop

	jsr disable_save_ram
	rts
.endproc


.segment "HEADER"
	.byte "NES", $1a
	.byte 16 ; 256kb program ROM
	.byte 0 ; CHR-RAM
	.byte $12 ; Mapper 1 (SNROM) with battery-backed RAM
	.byte 0
	.byte $01 ; 8kb PRG RAM
	.byte 0 ; NTSC
	.byte 0 ; Program RAM present


.segment "TEMP"
VAR checksum
	.word 0

VAR save_ram_enabled
	.byte 0

VAR bankswitch_vblank_count
	.byte 0


.segment "SRAM"
VAR minimap_cache
	.repeat $2c0
	.byte 0
	.endrepeat
