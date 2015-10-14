.include "defines.inc"

.code

PROC find_item
	sta temp
	ldx #0
	ldy #0
loop:
	cpx inventory_count
	beq notfound
	lda inventory + 1, y
	cmp temp
	beq found
	inx
	iny
	iny
	jmp loop

found:
	txa
	rts

notfound:
	lda #$ff
	rts
.endproc


PROC give_weapon
	sta temp
	lda inventory_count
	asl
	tay
	stx inventory, y
	lda temp
	sta inventory + 1, y
	inc inventory_count
	rts
.endproc


PROC give_item
	ldx #1
	jmp give_item_with_count
.endproc


PROC give_item_with_count
	sta arg0
	stx arg1

	jsr find_item
	cmp #$ff
	beq newitem

	txa
	asl
	tax
	lda inventory, x
	clc
	adc arg1
	bcs toomany
	sta inventory, x
	rts

toomany:
	lda #$ff
	sta inventory, x
	rts

newitem:
	lda inventory_count
	asl
	tax
	lda arg1
	sta inventory, x
	lda arg0
	sta inventory + 1, x
	inc inventory_count
	rts
.endproc


PROC get_item_type
	asl
	tax
	lda item_descriptors, x
	sta ptr
	lda item_descriptors + 1, x
	sta ptr + 1

	ldy #ITEM_DESC_TYPE
	lda (ptr), y
	rts
.endproc


PROC use_item
	asl
	tax
	lda item_descriptors, x
	sta ptr
	lda item_descriptors + 1, x
	sta ptr + 1

	ldy #ITEM_DESC_USE
	lda (ptr), y
	sta temp
	ldy #ITEM_DESC_USE + 1
	lda (ptr), y
	sta temp + 1

	lda temp
	bne valid
	lda temp + 1
	bne valid

	lda #0
	rts

valid:
	jsr call_temp
	rts
.endproc


PROC get_item_name
	asl
	tax
	lda item_descriptors, x
	sta ptr
	lda item_descriptors + 1, x
	sta ptr + 1

	ldy #ITEM_DESC_NAME
	jsr add_y_to_ptr
	rts
.endproc


PROC get_item_description
	asl
	tax
	lda item_descriptors, x
	sta ptr
	lda item_descriptors + 1, x
	sta ptr + 1

	ldy #ITEM_DESC_NAME
	jsr add_y_to_ptr

	ldy #0
loop:
	lda (ptr), y
	beq found
	iny
	jmp loop

found:
	iny
	jsr add_y_to_ptr
	rts
.endproc


PROC update_equipped_item_slots
	lda equipped_weapon
	cmp #ITEM_NONE
	beq noweapon

	ldx #0
weaponloop:
	txa
	asl
	tay
	lda inventory + 1, y
	cmp equipped_weapon
	beq foundweapon
	inx
	cpx inventory_count
	bne weaponloop

	lda #ITEM_NONE
	sta equipped_weapon
	jmp noweapon

foundweapon:
	stx equipped_weapon_slot

noweapon:
	lda equipped_armor
	cmp #ITEM_NONE
	beq noarmor

	ldx #0
armorloop:
	txa
	asl
	tay
	lda inventory + 1, y
	cmp equipped_armor
	beq foundarmor
	inx
	cpx inventory_count
	bne armorloop

	lda #ITEM_NONE
	sta equipped_armor
	rts

foundarmor:
	stx equipped_armor_slot

noarmor:
	rts
.endproc


PROC load_item_background_tiles
	cmp #ITEM_NONE
	beq blank

	asl
	tay
	lda item_descriptors, y
	sta temp
	lda item_descriptors + 1, y
	sta temp + 1
	ldy #ITEM_DESC_TILE
	lda (temp), y
	sta ptr
	iny
	lda (temp), y
	sta ptr + 1
	jmp load

blank:
	LOAD_PTR blank_tiles

load:
	txa
	asl
	asl
	asl
	asl
	sta temp
	txa
	lsr
	lsr
	lsr
	lsr
	sta temp + 1
	lda #4
	ldy #3
	jsr copy_tiles

	rts
.endproc


PROC load_item_sprite_tiles
	cmp #ITEM_NONE
	beq blank

	asl
	tay
	lda item_descriptors, y
	sta temp
	lda item_descriptors + 1, y
	sta temp + 1
	ldy #ITEM_DESC_TILE
	lda (temp), y
	sta ptr
	iny
	lda (temp), y
	sta ptr + 1
	jmp load

blank:
	LOAD_PTR blank_tiles

load:
	txa
	asl
	asl
	asl
	asl
	sta temp
	txa
	lsr
	lsr
	lsr
	lsr
	ora #$10
	sta temp + 1
	lda #4
	ldy #3
	jsr copy_tiles

	rts
.endproc


PROC use_bandage
	lda player_health
	cmp #100
	beq alreadymax

	clc
	adc #25
	cmp #100
	bcc notmax
	lda #100
notmax:
	sta player_health
	lda #1
	rts

alreadymax:
	lda #0
	rts
.endproc


PROC use_health_kit
	lda player_health
	cmp #100
	beq alreadymax

	clc
	adc #50
	cmp #100
	bcc notmax
	lda #100
notmax:
	sta player_health
	lda #1
	rts

alreadymax:
	lda #0
	rts
.endproc


PROC use_one_ammo
	lda equipped_weapon_slot
	asl
	tax
	dec inventory, x
	beq outofammo
	rts

outofammo:
	; No more ammo for current weapon, grenades disappear from inventory when
	; the last one is used
	lda equipped_weapon
	jsr get_item_type
	cmp #ITEM_TYPE_GRENADE
	beq usedall
	rts

usedall:
	lda equipped_weapon_slot
	sta arg0
deleteloop:
	lda arg0
	clc
	adc #1
	cmp inventory_count
	beq deletedone

	lda arg0
	asl
	tax
	lda inventory + 2, x
	sta inventory, x
	lda inventory + 3, x
	sta inventory + 1, x

	inc arg0
	jmp deleteloop

deletedone:
	dec inventory_count
	lda #ITEM_NONE
	sta equipped_weapon
	rts
.endproc


PROC fire_pistol
	jsr use_one_ammo

	lda player_x
	clc
	adc #7
	sta arg0
	lda player_y
	clc
	adc #7
	sta arg1
	lda #EFFECT_PLAYER_BULLET
	sta arg2
	jsr get_player_direction_bits
	sta arg3
	jsr create_effect

	cmp #$ff
	beq failed

	sta cur_effect
	jsr player_bullet_tick
	jsr player_bullet_tick

	lda #15
	sta attack_cooldown
	lda #1
	sta attack_held

failed:
	rts
.endproc


PROC fire_smg
	jsr use_one_ammo

	lda player_x
	clc
	adc #7
	sta arg0
	lda player_y
	clc
	adc #7
	sta arg1
	lda #EFFECT_PLAYER_BULLET
	sta arg2
	jsr get_player_direction_bits
	sta arg3
	jsr create_effect

	cmp #$ff
	beq failed

	sta cur_effect
	jsr player_bullet_tick
	jsr player_bullet_tick

	lda #12
	sta attack_cooldown

failed:
	rts
.endproc


.data

VAR axe_item
	.word 0
	.word axe_tiles & $ffff
	.byte ITEM_TYPE_MELEE
	.byte "WOOD AXE       ", 0
	.byte "CHOPS WOOD OR ZOMBIES     ", 0

VAR sword_item
	.word 0
	.word ninja_sword_tiles & $ffff
	.byte ITEM_TYPE_MELEE
	.byte "NINJA SWORD    ", 0
	.byte "MASTER THE CLOSE RANGE    ", 0

VAR pistol_item
	.word fire_pistol
	.word pistol_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "G17 PISTOL     ", 0
	.byte "A RELIABLE HANDGUN        ", 0

VAR smg_item
	.word fire_smg
	.word smg_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "SMG            ", 0
	.byte "SMALL FULL AUTO WEAPON    ", 0

VAR lmg_item
	.word 0
	.word lmg_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "MACHINE GUN    ", 0
	.byte "EFFECTIVE HEAVY WEAPON    ", 0

VAR ak_item
	.word 0
	.word ak_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "AK RIFLE       ", 0
	.byte "FAMOUS FOR RELIABILITY    ", 0

VAR shotgun_item
	.word 0
	.word shotgun_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "SHOTGUN        ", 0
	.byte "LEGENDARY ZOMBIE DEFENSE  ", 0

VAR sniper_item
	.word 0
	.word sniper_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "SNIPER RIFLE   ", 0
	.byte "TAKE THEM OUT FROM AFAR   ", 0

VAR hand_cannon_item
	.word 0
	.word hand_cannon_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "HAND CANNON    ", 0
	.byte "THE ENVY OF ALL PIRATES   ", 0

VAR rocket_launcher_item
	.word 0
	.word launcher_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "ROCKET LAUNCHER", 0
	.byte "MAKE IT GO BOOM           ", 0

VAR flamethrower_item
	.word 0
	.word blank_tiles & $ffff
	.byte ITEM_TYPE_GUN
	.byte "FLAMETHROWER   ", 0
	.byte "BURNINATE THE INFECTED    ", 0

VAR grenade_item
	.word 0
	.word grenade_tiles & $ffff
	.byte ITEM_TYPE_GRENADE
	.byte "FRAG GRENADE   ", 0
	.byte "FIRE IN THE HOLE          ", 0

VAR bandage_item
	.word use_bandage
	.word bandage_tiles & $ffff
	.byte ITEM_TYPE_HEALTH
	.byte "BANDAGE        ", 0
	.byte "HEAL MINOR WOUNDS         ", 0

VAR health_kit_item
	.word use_health_kit
	.word health_kit_tiles & $ffff
	.byte ITEM_TYPE_HEALTH
	.byte "HEALTH KIT     ", 0
	.byte "QUICKLY HEAL WOUNDS       ", 0

VAR fuel_item
	.word 0
	.word fuel_tiles & $ffff
	.byte ITEM_TYPE_CONSUMABLE
	.byte "FUEL CAN       ", 0
	.byte "COMBUSTABLE FUEL          ", 0

VAR stick_item
	.word 0
	.word sticks_tiles & $ffff
	.byte ITEM_TYPE_CRAFTING
	.byte "STICK          ", 0
	.byte "WOOD STICK FOR CRAFTING   ", 0

VAR cloth_item
	.word 0
	.word cloth_strip_tiles & $ffff
	.byte ITEM_TYPE_CRAFTING
	.byte "CLOTH STRIPS   ", 0
	.byte "TORN CLOTH FOR CRAFTING   ", 0

VAR shirt_item
	.word 0
	.word shirt_tiles & $ffff
	.byte ITEM_TYPE_CRAFTING
	.byte "SHIRT          ", 0
	.byte "A SHIRT FOR CRAFTING      ", 0

VAR pants_item
	.word 0
	.word pants_tiles & $ffff
	.byte ITEM_TYPE_CRAFTING
	.byte "PANTS          ", 0
	.byte "DENIM FOR CRAFTING        ", 0

VAR metal_item
	.word 0
	.word metal_tiles & $ffff
	.byte ITEM_TYPE_CRAFTING
	.byte "METAL FRAGMENTS", 0
	.byte "METAL FOR CRAFTING        ", 0

VAR gem_item
	.word 0
	.word gem_tiles & $ffff
	.byte ITEM_TYPE_SELL
	.byte "GEM            ", 0
	.byte "SELL FOR GOLD             ", 0

VAR gunpowder_item
	.word 0
	.word gunpowder_tiles & $ffff
	.byte ITEM_TYPE_CRAFTING
	.byte "GUNPOWDER      ", 0
	.byte "EXPLOSIVE POWDER          ", 0

VAR campfire_item
	.word 0
	.word campfire_tiles & $ffff
	.byte ITEM_TYPE_CAMPFIRE
	.byte "CAMPFIRE       ", 0
	.byte "USE TO SET SPAWN POINT    ", 0

VAR sneakers_item
	.word 0
	.word sneakers_tiles & $ffff
	.byte ITEM_TYPE_OUTFIT
	.byte "SNEAKERS       ", 0
	.byte "WEAR TO RUN FASTER        ", 0

VAR wizard_hat_item
	.word 0
	.word wizard_hat_tiles & $ffff
	.byte ITEM_TYPE_OUTFIT
	.byte "WIZARD HAT     ", 0
	.byte "FEELS MAGICAL             ", 0

VAR armor_item
	.word 0
	.word armor_tiles & $ffff
	.byte ITEM_TYPE_OUTFIT
	.byte "SUIT OF ARMOR  ", 0
	.byte "LESS DAMAGE BUT SLOWER    ", 0

VAR tinfoil_hat_item
	.word 0
	.word blank_tiles & $ffff
	.byte ITEM_TYPE_OUTFIT
	.byte "TINFOIL HAT    ", 0
	.byte "MAY REFLECT LASER BEAMS   ", 0

VAR ghillie_suit_item
	.word 0
	.word ghillie_tiles & $ffff
	.byte ITEM_TYPE_OUTFIT
	.byte "GHILLIE SUIT   ", 0
	.byte "MAKE LIKE A TREE AND SNIPE", 0

VAR coffee_item
	.word 0
	.word coffee_tiles & $ffff
	.byte ITEM_TYPE_CONSUMABLE
	.byte "COFFEE         ", 0
	.byte "GO INTO HYPER ACTIVE      ", 0

VAR wine_item
	.word 0
	.word wine_tiles & $ffff
	.byte ITEM_TYPE_CONSUMABLE
	.byte "WINE BOTTLE    ", 0
	.byte "NUMBS THE PAIN FOR A TIME ", 0

VAR item_descriptors
	.word axe_item
	.word sword_item
	.word pistol_item
	.word smg_item
	.word lmg_item
	.word ak_item
	.word shotgun_item
	.word sniper_item
	.word hand_cannon_item
	.word rocket_launcher_item
	.word flamethrower_item
	.word grenade_item
	.word bandage_item
	.word health_kit_item
	.word fuel_item
	.word stick_item
	.word cloth_item
	.word shirt_item
	.word pants_item
	.word metal_item
	.word gem_item
	.word gunpowder_item
	.word campfire_item
	.word sneakers_item
	.word wizard_hat_item
	.word armor_item
	.word tinfoil_hat_item
	.word ghillie_suit_item
	.word coffee_item
	.word wine_item


TILES blank_tiles, 3, "tiles/items/blank.chr", 4
TILES campfire_tiles, 3, "tiles/items/campfire.chr", 4
TILES cloth_strip_tiles, 3, "tiles/items/clothstrips.chr", 4
TILES coffee_tiles, 3, "tiles/items/coffee.chr", 4
TILES fuel_tiles, 3, "tiles/items/fuel.chr", 4
TILES gem_tiles, 3, "tiles/items/gem.chr", 4
TILES ghillie_tiles, 3, "tiles/items/ghillie.chr", 4
TILES gunpowder_tiles, 3, "tiles/items/gunpowder.chr", 4
TILES health_kit_tiles, 3, "tiles/items/healthkit.chr", 4
TILES pants_tiles, 3, "tiles/items/pants.chr", 4
TILES shirt_tiles, 3, "tiles/items/shirt.chr", 4
TILES sneakers_tiles, 3, "tiles/items/sneakers.chr", 4
TILES sticks_tiles, 3, "tiles/items/sticks.chr", 4
TILES wine_tiles, 3, "tiles/items/wine.chr", 4
TILES axe_tiles, 3, "tiles/weapons/axe.chr", 4
TILES grenade_tiles, 3, "tiles/weapons/grenade.chr", 4
TILES ak_tiles, 3, "tiles/weapons/ak.chr", 4
TILES hand_cannon_tiles, 3, "tiles/weapons/handcannon.chr", 4
TILES launcher_tiles, 3, "tiles/weapons/launcher.chr", 4
TILES lmg_tiles, 3, "tiles/weapons/lmg.chr", 4
TILES pistol_tiles, 3, "tiles/weapons/pistol.chr", 4
TILES shotgun_tiles, 3, "tiles/weapons/shotgun.chr", 4
TILES smg_tiles, 3, "tiles/weapons/smg.chr", 4
TILES sniper_tiles, 3, "tiles/weapons/sniper.chr", 4
TILES bandage_tiles, 3, "tiles/items/bandage.chr", 4
TILES metal_tiles, 3, "tiles/items/metalfragments.chr", 4
TILES wizard_hat_tiles, 3, "tiles/items/wizardhat.chr", 4
TILES ninja_sword_tiles, 3, "tiles/weapons/ninjasword.chr", 4
TILES armor_tiles, 3, "tiles/items/armor.chr", 4
