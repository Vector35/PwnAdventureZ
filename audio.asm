.include "defines.inc"

.segment "FIXED"

PROC play_music
	sta temp

	lda #0
	sta music_playing

	lda ptr
	sta music_page_list_ptr
	lda ptr + 1
	sta music_page_list_ptr + 1
	lda arg0
	sta music_page_bank_ptr
	lda arg1
	sta music_page_bank_ptr + 1
	lda arg2
	sta music_loop_list_ptr
	lda arg3
	sta music_loop_list_ptr + 1
	lda arg4
	sta music_loop_bank_ptr
	lda arg5
	sta music_loop_bank_ptr + 1
	lda temp
	sta music_page_list_bank
	lda #0
	sta music_page_offset

	; Switch to bank containing music pointers
	lda current_bank
	pha
	lda music_page_list_bank
	jsr bankswitch

	; Load pointer to first page of music
	ldy #0
	lda (music_page_list_ptr), y
	sta music_page_ptr
	ldy #1
	lda (music_page_list_ptr), y
	sta music_page_ptr + 1
	ldy #0
	lda (music_page_bank_ptr), y
	sta music_page_bank

	; Update pointers to next page
	lda music_page_list_ptr
	clc
	adc #2
	sta music_page_list_ptr
	lda music_page_list_ptr + 1
	adc #0
	sta music_page_list_ptr + 1

	lda music_page_bank_ptr
	clc
	adc #1
	sta music_page_bank_ptr
	lda music_page_bank_ptr + 1
	adc #0
	sta music_page_bank_ptr + 1

	; Switch back to entry bank and start music playback
	pla
	jsr bankswitch

	lda #1
	sta music_playing
	rts
.endproc


PROC play_sound_effect
	pha

	lda #0
	sta sound_effect_playing

	lda ptr
	sta sound_effect_ptr
	lda ptr + 1
	sta sound_effect_ptr + 1
	pla
	sta sound_effect_bank

	lda #0
	sta sound_effect_offset

	; Silence any notes from the music on the triangle and noise channels
	lda #0
	sta TRI_LINEAR
	lda #0
	sta TRI_HI
	lda #$30
	sta NOISE_VOL

	lda #1
	sta sound_effect_playing
	rts
.endproc


PROC update_audio
	lda current_bank
	pha

	; Set pointers to registers
	lda #0
	sta audio_reg_ptr
	lda #$40
	sta audio_reg_ptr + 1
	lda #<music_reg_state
	sta music_reg_state_ptr
	lda #>music_reg_state
	sta music_reg_state_ptr + 1

	lda music_playing
	bne musicvalid

	jmp processeffect

musicvalid:
	; There is music playing, switch to bank containing music
	lda music_page_bank
	jsr bankswitch

	; Read mask of registers to be updated
	jsr read_music_byte
	sta audio_reg_mask
	jsr read_music_byte
	sta audio_reg_mask + 1

	; Process first 8 audio registers
	lda #0
	sta audio_reg_index
	lda #1
	sta audio_temp
firstloop:
	lda audio_reg_mask
	and audio_temp
	beq firstnotset

	jsr read_music_byte
	ldy audio_reg_index
	sta (audio_reg_ptr), y

firstnotset:
	lda audio_temp
	asl
	beq firstdone
	sta audio_temp
	inc audio_reg_index
	jmp firstloop

firstdone:
	; Process second 8 audio registers
	lda #8
	sta audio_reg_index
	lda #1
	sta audio_temp
secondloop:
	lda audio_reg_mask + 1
	cmp #2
	beq secondnotset
	and audio_temp
	beq secondnotset

	; If sound effect is playing, don't write the register, but save
	; what was going to be written to the current music state
	lda sound_effect_playing
	bne effectactive

	jsr read_music_byte
	ldy audio_reg_index
	sta (audio_reg_ptr), y
	sta (music_reg_state_ptr), y
	jmp secondnotset

effectactive:
	jsr read_music_byte
	ldy audio_reg_index
	sta (music_reg_state_ptr), y

secondnotset:
	lda audio_temp
	asl
	beq seconddone
	sta audio_temp
	inc audio_reg_index
	jmp secondloop

seconddone:
	; Check for end of stream marker
	lda audio_reg_mask + 1
	and #2
	beq processeffect

	; At end of music, loop now
	lda music_loop_list_ptr
	sta music_page_list_ptr
	lda music_loop_list_ptr + 1
	sta music_page_list_ptr + 1
	lda music_loop_bank_ptr
	sta music_page_bank_ptr
	lda music_loop_bank_ptr + 1
	sta music_page_bank_ptr + 1

	lda music_page_list_bank
	jsr bankswitch

	ldy #0
	lda (music_page_list_ptr), y
	sta music_page_ptr
	ldy #1
	lda (music_page_list_ptr), y
	sta music_page_ptr + 1
	ldy #0
	lda (music_page_bank_ptr), y
	sta music_page_bank

	; Update pointers to next page
	lda music_page_list_ptr
	clc
	adc #2
	sta music_page_list_ptr
	lda music_page_list_ptr + 1
	adc #0
	sta music_page_list_ptr + 1

	lda music_page_bank_ptr
	clc
	adc #1
	sta music_page_bank_ptr
	lda music_page_bank_ptr + 1
	adc #0
	sta music_page_bank_ptr + 1

	lda #0
	sta music_page_offset

processeffect:
	; Check for an active sound effect
	lda sound_effect_playing
	bne haseffect

	jmp done

haseffect:
	; There is a valid sound effect, switch to the bank containing the effect
	lda sound_effect_bank
	jsr bankswitch

	; Read the mask of registers to be updated
	jsr read_sound_effect_byte
	sta audio_reg_mask

	; Process effect register updates
	lda #8
	sta audio_reg_index
	lda #1
	sta audio_temp
effectloop:
	lda audio_reg_mask
	cmp #2
	beq effectnotset
	and audio_temp
	beq effectnotset

	jsr read_sound_effect_byte
	ldy audio_reg_index
	sta (audio_reg_ptr), y

effectnotset:
	lda audio_temp
	asl
	beq effectdone
	sta audio_temp
	inc audio_reg_index
	jmp effectloop

effectdone:
	; Check for end of stream marker
	lda audio_reg_mask
	and #2
	beq done

	; Sound effect is done
	lda music_playing
	beq nomusicaftereffect

	; Music is playing, restore channels to music state
	lda music_reg_state + 8
	sta $4008
	lda music_reg_state + $a
	sta $400a
	lda music_reg_state + $b
	sta $400b
	lda music_reg_state + $c
	sta $400c
	lda music_reg_state + $e
	sta $400e
	lda music_reg_state + $f
	sta $400f

	lda #0
	sta sound_effect_playing
	jmp done

nomusicaftereffect:
	; No music and an effect is done, silence effect channels
	lda #0
	sta TRI_LINEAR
	lda #0
	sta TRI_HI
	lda #$30
	sta NOISE_VOL

	lda #0
	sta sound_effect_playing

done:
	pla
	jsr bankswitch

	rts
.endproc


PROC read_music_byte
	ldy music_page_offset
	lda (music_page_ptr), y
	inc music_page_offset
	bne notend

	; Went past end of page, load next page
	pha

	lda music_page_list_bank
	jsr bankswitch

	ldy #0
	lda (music_page_list_ptr), y
	sta music_page_ptr
	ldy #1
	lda (music_page_list_ptr), y
	sta music_page_ptr + 1
	ldy #0
	lda (music_page_bank_ptr), y
	sta music_page_bank

	; Update pointers to next page
	lda music_page_list_ptr
	clc
	adc #2
	sta music_page_list_ptr
	lda music_page_list_ptr + 1
	adc #0
	sta music_page_list_ptr + 1

	lda music_page_bank_ptr
	clc
	adc #1
	sta music_page_bank_ptr
	lda music_page_bank_ptr + 1
	adc #0
	sta music_page_bank_ptr + 1

	lda music_page_bank
	jsr bankswitch

	pla

notend:
	rts
.endproc


PROC read_sound_effect_byte
	ldy sound_effect_offset
	lda (sound_effect_ptr), y
	inc sound_effect_offset
	rts
.endproc


.zeropage

VAR music_page_list_ptr
	.word 0
VAR music_page_bank_ptr
	.word 0
VAR music_page_ptr
	.word 0

VAR sound_effect_ptr
	.word 0

VAR audio_reg_ptr
	.word 0
VAR music_reg_state_ptr
	.word 0


.segment "TEMP"

VAR music_playing
	.byte 0
VAR music_page_list_bank
	.byte 0
VAR music_page_bank
	.byte 0
VAR music_page_offset
	.byte 0
VAR music_reg_state
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

VAR sound_effect_playing
	.byte 0
VAR sound_effect_bank
	.byte 0
VAR sound_effect_offset
	.byte 0

VAR audio_temp
	.byte 0
VAR audio_reg_mask
	.word 0
VAR audio_reg_index
	.byte 0

VAR music_loop_list_ptr
	.word 0
VAR music_loop_bank_ptr
	.word 0


.include "audio/neonstarlight.asm"
.include "audio/neonstarlight_loop.asm"

.segment "AUDIO0"
.include "audio/craft.asm"
.include "audio/enemydie.asm"
.include "audio/enemyhit.asm"
.include "audio/equip.asm"
.include "audio/getitem.asm"
.include "audio/light.asm"
.include "audio/open.asm"
.include "audio/pistol.asm"
.include "audio/playerhit.asm"
.include "audio/select.asm"
.include "audio/uimove.asm"
.include "audio/buy.asm"
.include "audio/sell.asm"

.segment "AUDIO1"
.include "audio/cave.asm"
