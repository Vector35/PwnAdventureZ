var fs = require('fs');
var ROMImage = fs.readFileSync(process.argv[2] + '.nes');

var MusicUpdates = '';
var HasUpdates = true;
var ReallyHasUpdates = false;

// CPU flags
var C_FLAG = 1 << 0;
var Z_FLAG = 1 << 1;
var I_FLAG = 1 << 2;
var D_FLAG = 1 << 3;
var B_FLAG = 1 << 4;
var V_FLAG = 1 << 6;
var S_FLAG = 1 << 7;

// PPU register 1 flags
var VERTICAL_WRITE = 1 << 2;
var SPRITE_TABLE = 1 << 3;
var BACKGROUND_TABLE = 1 << 4;
var LARGE_SPRITE = 1 << 5;
var VBLANK_ENABLE = 1 << 7;

// PPU register 2 flags
var LEFT_SPRITE_ENABLE = 1 << 2;
var SCREEN_ENABLE = 1 << 3;
var SPRITE_ENABLE = 1 << 4;

// PPU vblank register flags
var HIT_DETECT = 1 << 6;
var VBLANK = 1 << 7;

// Sprite flags
var SPRITE_BEHIND = 1 << 5;
var FLIP_HORIZONTAL = 1 << 6;
var FLIP_VERTICAL = 1 << 7;

var InstructionNames = [
	"brk", "ora", "invalid", "invalid", "invalid", "ora", "asl", "invalid", // 0x00
	"php", "ora", "asl@", "invalid", "invalid", "ora", "asl", "invalid", // 0x08
	"bpl", "ora", "invalid", "invalid", "invalid", "ora", "asl", "invalid", // 0x10
	"clc", "ora", "invalid", "invalid", "invalid", "ora", "asl", "invalid", // 0x18
	"jsr", "and", "invalid", "invalid", "bit", "and", "rol", "invalid", // 0x20
	"plp", "and", "rol@", "invalid", "bit", "and", "rol", "invalid", // 0x28
	"bmi", "and", "invalid", "invalid", "invalid", "and", "rol", "invalid", // 0x30
	"sec", "and", "invalid", "invalid", "invalid", "and", "rol", "invalid", // 0x38
	"rti", "eor", "invalid", "invalid", "invalid", "eor", "lsr", "invalid", // 0x40
	"pha", "eor", "lsr@", "invalid", "jmp", "eor", "lsr", "invalid", // 0x48
	"bvc", "eor", "invalid", "invalid", "invalid", "eor", "lsr", "invalid", // 0x50
	"cli", "eor", "invalid", "invalid", "invalid", "eor", "lsr", "invalid", // 0x58
	"rts", "adc", "invalid", "invalid", "invalid", "adc", "ror", "invalid", // 0x60
	"pla", "adc", "ror@", "invalid", "jmp", "adc", "ror", "invalid", // 0x68
	"bvs", "adc", "invalid", "invalid", "invalid", "adc", "ror", "invalid", // 0x70
	"sei", "adc", "invalid", "invalid", "invalid", "adc", "ror", "invalid", // 0x78
	"invalid", "sta", "invalid", "invalid", "sty", "sta", "stx", "invalid", // 0x80
	"dey", "invalid", "txa", "invalid", "sty", "sta", "stx", "invalid", // 0x88
	"bcc", "sta", "invalid", "invalid", "sty", "sta", "stx", "invalid", // 0x90
	"tya", "sta", "txs", "invalid", "invalid", "sta", "invalid", "invalid", // 0x98
	"ldy", "lda", "ldx", "invalid", "ldy", "lda", "ldx", "invalid", // 0xa0
	"tay", "lda", "tax", "invalid", "ldy", "lda", "ldx", "invalid", // 0xa8
	"bcs", "lda", "invalid", "invalid", "ldy", "lda", "ldx", "invalid", // 0xb0
	"clv", "lda", "tsx", "invalid", "ldy", "lda", "ldx", "invalid", // 0xb8
	"cpy", "cmp", "invalid", "invalid", "cpy", "cmp", "dec", "invalid", // 0xc0
	"iny", "cmp", "dex", "invalid", "cpy", "cmp", "dec", "invalid", // 0xc8
	"bne", "cmp", "invalid", "invalid", "invalid", "cmp", "dec", "invalid", // 0xd0
	"cld", "cmp", "invalid", "invalid", "invalid", "cmp", "dec", "invalid", // 0xd8
	"cpx", "sbc", "invalid", "invalid", "cpx", "sbc", "inc", "invalid", // 0xe0
	"inx", "sbc", "nop", "invalid", "cpx", "sbc", "inc", "invalid", // 0xe8
	"beq", "sbc", "invalid", "invalid", "invalid", "sbc", "inc", "invalid", // 0xf0
	"sed", "sbc", "invalid", "invalid", "invalid", "sbc", "inc", "invalid" // 0xf8
];

var NONE = 0;
var ABS = 1;
var ABS_DEST = 2;
var ABS_X = 3;
var ABS_X_DEST = 4;
var ABS_Y = 5;
var ABS_Y_DEST = 6;
var ACCUM = 7;
var ADDR = 8;
var IMMED = 9;
var IND = 10;
var IND_X = 11;
var IND_X_DEST = 12;
var IND_Y = 13;
var IND_Y_DEST = 14;
var REL = 15;
var ZERO = 16;
var ZERO_DEST = 17;
var ZERO_X = 18;
var ZERO_X_DEST = 19;
var ZERO_Y = 20;
var ZERO_Y_DEST = 21;
var InstructionOperandTypes = [
	NONE, IND_X, NONE, NONE, NONE, ZERO, ZERO_DEST, NONE, // 0x00
	NONE, IMMED, ACCUM, NONE, NONE, ABS, ABS_DEST, NONE, // 0x08
	REL, IND_Y, NONE, NONE, NONE, ZERO_X, ZERO_X_DEST, NONE, // 0x10
	NONE, ABS_Y, NONE, NONE, NONE, ABS_X, ABS_X_DEST, NONE, // 0x18
	ADDR, IND_X, NONE, NONE, ZERO, ZERO, ZERO_DEST, NONE, // 0x20
	NONE, IMMED, ACCUM, NONE, ABS, ABS, ABS_DEST, NONE, // 0x28
	REL, IND_Y, NONE, NONE, NONE, ZERO_X, ZERO_X_DEST, NONE, // 0x30
	NONE, ABS_Y, NONE, NONE, NONE, ABS_X, ABS_X_DEST, NONE, // 0x38
	NONE, IND_X, NONE, NONE, NONE, ZERO, ZERO_DEST, NONE, // 0x40
	NONE, IMMED, ACCUM, NONE, ADDR, ABS, ABS_DEST, NONE, // 0x48
	REL, IND_Y, NONE, NONE, NONE, ZERO_X, ZERO_X_DEST, NONE, // 0x50
	NONE, ABS_Y, NONE, NONE, NONE, ABS_X, ABS_X_DEST, NONE, // 0x58
	NONE, IND_X, NONE, NONE, NONE, ZERO, ZERO_DEST, NONE, // 0x60
	NONE, IMMED, ACCUM, NONE, IND, ABS, ABS_DEST, NONE, // 0x68
	REL, IND_Y, NONE, NONE, NONE, ZERO_X, ZERO_X_DEST, NONE, // 0x70
	NONE, ABS_Y, NONE, NONE, NONE, ABS_X, ABS_X_DEST, NONE, // 0x78
	NONE, IND_X_DEST, NONE, NONE, ZERO_DEST, ZERO_DEST, ZERO_DEST, NONE, // 0x80
	NONE, NONE, NONE, NONE, ABS_DEST, ABS_DEST, ABS_DEST, NONE, // 0x88
	REL, IND_Y_DEST, NONE, NONE, ZERO_X_DEST, ZERO_X_DEST, ZERO_Y_DEST, NONE, // 0x90
	NONE, ABS_Y_DEST, NONE, NONE, NONE, ABS_X_DEST, NONE, NONE, // 0x98
	IMMED, IND_X, IMMED, NONE, ZERO, ZERO, ZERO, NONE, // 0xa0
	NONE, IMMED, NONE, NONE, ABS, ABS, ABS, NONE, // 0xa8
	REL, IND_Y, NONE, NONE, ZERO_X, ZERO_X, ZERO_Y, NONE, // 0xb0
	NONE, ABS_Y, NONE, NONE, ABS_X, ABS_X, ABS_Y, NONE, // 0xb8
	IMMED, IND_X, NONE, NONE, ZERO, ZERO, ZERO_DEST, NONE, // 0xc0
	NONE, IMMED, NONE, NONE, ABS, ABS, ABS_DEST, NONE, // 0xc8
	REL, IND_Y, NONE, NONE, NONE, ZERO_X, ZERO_X_DEST, NONE, // 0xd0
	NONE, ABS_Y, NONE, NONE, NONE, ABS_X, ABS_X_DEST, NONE, // 0xd8
	IMMED, IND_X, NONE, NONE, ZERO, ZERO, ZERO_DEST, NONE, // 0xe0
	NONE, IMMED, NONE, NONE, ABS, ABS, ABS_DEST, NONE, // 0xe8
	REL, IND_Y, NONE, NONE, NONE, ZERO_X, ZERO_X_DEST, NONE, // 0xf0
	NONE, ABS_Y, NONE, NONE, NONE, ABS_X, ABS_X_DEST, NONE // 0xf8
];

var InstructionClocks = [
	7, 6, 4, 4, 4, 3, 5, 4, 3, 2, 2, 4, 4, 4, 6, 4, // 0x00
	2, 5, 4, 4, 4, 4, 6, 4, 2, 4, 4, 4, 4, 4, 7, 4, // 0x10
	6, 6, 4, 4, 3, 3, 5, 4, 4, 2, 2, 4, 4, 4, 6, 4, // 0x20
	2, 5, 4, 4, 4, 4, 6, 4, 2, 4, 4, 4, 4, 4, 7, 4, // 0x30
	4, 6, 4, 4, 4, 3, 5, 4, 3, 2, 2, 4, 3, 6, 6, 4, // 0x40
	2, 5, 4, 4, 4, 4, 6, 4, 2, 4, 4, 4, 4, 4, 7, 4, // 0x50
	6, 6, 4, 4, 4, 3, 5, 4, 4, 2, 2, 4, 5, 4, 6, 4, // 0x60
	2, 5, 4, 4, 4, 4, 6, 4, 2, 4, 4, 4, 4, 4, 7, 4, // 0x70
	4, 6, 4, 4, 3, 3, 3, 4, 2, 4, 2, 4, 4, 4, 4, 4, // 0x80
	2, 6, 4, 4, 4, 4, 4, 4, 2, 5, 2, 4, 4, 5, 4, 4, // 0x90
	2, 6, 2, 4, 3, 3, 3, 4, 2, 2, 2, 4, 4, 4, 4, 4, // 0xa0
	2, 5, 4, 4, 4, 4, 4, 4, 2, 4, 2, 4, 4, 4, 4, 4, // 0xb0
	2, 6, 4, 4, 3, 3, 5, 4, 2, 2, 2, 4, 4, 4, 6, 4, // 0xc0
	2, 5, 4, 4, 4, 4, 6, 4, 2, 4, 4, 4, 4, 4, 7, 4, // 0xd0
	2, 6, 4, 4, 3, 3, 5, 4, 2, 2, 2, 4, 4, 4, 6, 4, // 0xe0
	2, 5, 4, 4, 4, 4, 6, 4, 2, 4, 4, 4, 4, 4, 7, 4 // 0xf0
];

function Hex(val)
{
	result = val.toString(16);
	if (result.length == 1)
		return "0" + result;
	return result;
}

function Hex16(val)
{
	return Hex(val >> 8) + Hex(val & 0xff);
}

var DisassembleOperandProcs = [
	function(pc, a, b) { return ["", 0]; }, // NONE
	function(pc, a, b) { return [" $" + Hex(b) + Hex(a), 2]; }, // ABS
	function(pc, a, b) { return [" $" + Hex(b) + Hex(a), 2]; }, // ABS_DEST
	function(pc, a, b) { return [" $" + Hex(b) + Hex(a) + ",x", 2]; }, // ABS_X
	function(pc, a, b) { return [" $" + Hex(b) + Hex(a) + ",x", 2]; }, // ABS_X_DEST
	function(pc, a, b) { return [" $" + Hex(b) + Hex(a) + ",y", 2]; }, // ABS_Y
	function(pc, a, b) { return [" $" + Hex(b) + Hex(a) + ",y", 2]; }, // ABS_Y_DEST
	function(pc, a, b) { return [" a", 0]; }, // ACCUM
	function(pc, a, b) { return [" $" + Hex(b) + Hex(a), 2] }, // ADDR
	function(pc, a, b) { return [" #$" + Hex(a), 1]; }, // IMMED
	function(pc, a, b) { return [" ($" + Hex(b) + Hex(a) + ")", 2]; }, // IND
	function(pc, a, b) { return [" ($" + Hex(a) + ",x)", 1]; }, // IND_X
	function(pc, a, b) { return [" ($" + Hex(a) + ",x)", 1]; }, // IND_X_DEST
	function(pc, a, b) { return [" ($" + Hex(a) + "),y", 1]; }, // IND_Y
	function(pc, a, b) { return [" ($" + Hex(a) + "),y", 1]; }, // IND_Y_DEST
	function(pc, a, b) { var ofs = a | ((a >> 7) * 0xff00); return [" $" + Hex16(((pc + 2 + ofs) & 0xffff)), 1]; }, // REL
	function(pc, a, b) { return [" $" + Hex(a), 1]; }, // ZERO
	function(pc, a, b) { return [" $" + Hex(a), 1]; }, // ZERO_DEST
	function(pc, a, b) { return [" $" + Hex(a) + ",x", 1]; }, // ZERO_X
	function(pc, a, b) { return [" $" + Hex(a) + ",x", 1]; }, // ZERO_X_DEST
	function(pc, a, b) { return [" $" + Hex(a) + ",y", 1]; }, // ZERO_Y
	function(pc, a, b) { return [" $" + Hex(a) + ",y", 1]; } // ZERO_Y_DEST
];

var NZFlags = [];
for (var i = 0; i < 512; i++)
{
	flag = 0;
	if ((i & 0xff) == 0)
		flag |= Z_FLAG;
	if ((i & 0x80) != 0)
		flag |= S_FLAG;
	if (i >= 0x100)
		flag |= C_FLAG;
	NZFlags[i] = flag;
}

var Palette = [
	[0x75,0x75,0x75], [0x27,0x1B,0x8F], [0x00,0x00,0xAB], [0x47,0x00,0x9F],
	[0x8F,0x00,0x77], [0xAB,0x00,0x13], [0xA7,0x00,0x00], [0x7F,0x0B,0x00],
	[0x43,0x2F,0x00], [0x00,0x47,0x00], [0x00,0x51,0x00], [0x00,0x3F,0x17],
	[0x1B,0x3F,0x5F], [0x00,0x00,0x00], [0x05,0x05,0x05], [0x05,0x05,0x05],
	[0xBC,0xBC,0xBC], [0x00,0x73,0xEF], [0x23,0x3B,0xEF], [0x83,0x00,0xF3],
	[0xBF,0x00,0xBF], [0xE7,0x00,0x5B], [0xDB,0x2B,0x00], [0xCB,0x4F,0x0F],
	[0x8B,0x73,0x00], [0x00,0x97,0x00], [0x00,0xAB,0x00], [0x00,0x93,0x3B],
	[0x00,0x83,0x8B], [0x11,0x11,0x11], [0x09,0x09,0x09], [0x09,0x09,0x09],
	[0xFF,0xFF,0xFF], [0x3F,0xBF,0xFF], [0x5F,0x97,0xFF], [0xA7,0x8B,0xFD],
	[0xF7,0x7B,0xFF], [0xFF,0x77,0xB7], [0xFF,0x77,0x63], [0xFF,0x9B,0x3B],
	[0xF3,0xBF,0x3F], [0x83,0xD3,0x13], [0x4F,0xDF,0x4B], [0x58,0xF8,0x98],
	[0x00,0xEB,0xDB], [0x66,0x66,0x66], [0x0D,0x0D,0x0D], [0x0D,0x0D,0x0D],
	[0xFF,0xFF,0xFF], [0xAB,0xE7,0xFF], [0xC7,0xD7,0xFF], [0xD7,0xCB,0xFF],
	[0xFF,0xC7,0xFF], [0xFF,0xC7,0xDB], [0xFF,0xBF,0xB3], [0xFF,0xDB,0xAB],
	[0xFF,0xE7,0xA3], [0xE3,0xFF,0xA3], [0xAB,0xF3,0xBF], [0xB3,0xFF,0xCF],
	[0x9F,0xFF,0xF3], [0xDD,0xDD,0xDD], [0x11,0x11,0x11], [0x11,0x11,0x11]
];

var shift, mapperValue, romRegion, largeRomSwap, largeChrSwap;
var cmd, chrRegionA, chrRegionB, romRegionA, romRegionB, irqStartCounter, irqCounter, irqEnable, irqRequest, irqResetCounter;

function Mapper0Init()
{
}

function Mapper0Write(addr, value)
{
}

function Mapper0Scanline()
{
}

function Mapper0IRQRequest()
{
	return false;
}

function Mapper1Init()
{
	shift = 0;
	mapperValue = 0;
	romRegion = 0x8000;
	largeRomSwap = false;
	largeChrSwap = false;
}

function Mapper1Write(addr, value)
{
	if (value & 0x80)
	{
		shift = 0;
		mapperValue = 0;
		return;
	}

	mapperValue |= (value & 1) << shift;
	shift += 1;
	if (shift < 5)
		return;

	var reg = (addr - 0x8000) >> 13;
	if (reg == 0)
	{
		if ((mapperValue & 3) == 0)
			MapFourScreenMirror(0);
		else if ((mapperValue & 3) == 1)
			MapFourScreenMirror(0x400);
		else if ((mapperValue & 3) == 2)
			MapVertMirror();
		else
			MapHorizMirror();
		romRegion = (mapperValue & 4) ? 0x8000 : 0xc000;
		largeRomSwap = (mapperValue & 8) == 0;
		largeChrSwap = (mapperValue & 0x10) == 0;
		if (mapperValue & 4)
			MapMemory(0xc000, 0x4000, (romBankCount - 1) * 0x4000);
		else
			MapMemory(0x8000, 0x4000, 0);
	}
	else if (reg == 1)
	{
		if (largeChrSwap)
			MapChr(0, 0x2000, (mapperValue & ~1) * 0x1000);
		else
			MapChr(0, 0x1000, mapperValue * 0x1000);
	}
	else if (reg == 2)
	{
		if (!largeChrSwap)
			MapChr(0x1000, 0x1000, mapperValue * 0x1000);
	}
	else if (reg == 3)
	{
		if (largeRomSwap)
			MapMemory(0x8000, 0x8000, (mapperValue & 0xe) * 0x4000);
		else
			MapMemory(romRegion, 0x4000, (mapperValue & 0xf) * 0x4000);
		sramEnable = (mapperValue & 0x10) == 0;
	}

	shift = 0;
	mapperValue = 0;
}

function Mapper1Scanline()
{
}

function Mapper1IRQRequest()
{
	return false;
}

function Mapper4Init()
{
	cmd = 0;
	chrRegionA = 0;
	chrRegionB = 0x1000;
	romRegionA = 0x8000;
	romRegionB = 0xc000;
	irqStartCounter = 0;
	irqCounter = 0xff;
	irqEnable = false;
	irqRequest = false;
	irqResetCounter = false;
}

function Mapper4Write(addr, value)
{
	if (addr == 0x8000)
	{
		cmd = value & 7;
		chrRegionA = (value & 0x80) ? 0x1000 : 0;
		chrRegionB = (value & 0x80) ? 0 : 0x1000;
		romRegionA = (value & 0x40) ? 0xc000 : 0x8000;
		romRegionB = (value & 0x40) ? 0x8000 : 0xc000;
		MapMemory(romRegionB, 0x2000, (romBankCount - 1) * 0x4000);
	}
	else if (addr == 0x8001)
	{
		if (cmd == 0)
		{
			value = value & (~1) & ((vromBankCount << 3) - 1);
			MapChr(chrRegionA, 0x800, value * 0x400);
		}
		else if (cmd == 1)
		{
			value = value & (~1) & ((vromBankCount << 3) - 1);
			MapChr(chrRegionA + 0x800, 0x800, value * 0x400);
		}
		else if (cmd == 2)
		{
			value &= (vromBankCount << 3) - 1;
			MapChr(chrRegionB, 0x400, value * 0x400);
		}
		else if (cmd == 3)
		{
			value &= (vromBankCount << 3) - 1;
			MapChr(chrRegionB + 0x400, 0x400, value * 0x400);
		}
		else if (cmd == 4)
		{
			value &= (vromBankCount << 3) - 1;
			MapChr(chrRegionB + 0x800, 0x400, value * 0x400);
		}
		else if (cmd == 5)
		{
			value &= (vromBankCount << 3) - 1;
			MapChr(chrRegionB + 0xc00, 0x400, value * 0x400);
		}
		else if (cmd == 6)
			MapMemory(romRegionA, 0x2000, value * 0x2000);
		else if (cmd == 7)
			MapMemory(0xa000, 0x2000, value * 0x2000);
	}
	else if (addr == 0xa000)
	{
		if (value & 1)
			MapHorizMirror();
		else
			MapVertMirror();
	}
	else if (addr == 0xa001)
		sramEnable = (value & 0x80) != 0;
	else if (addr == 0xc000)
		irqStartCounter = value;
	else if (addr == 0xc001)
		irqResetCounter = true;
	else if (addr == 0xe000)
	{
		irqRequest = false;
		irqEnable = false;
	}
	else if (addr == 0xe001)
	{
		irqRequest = false;
		irqEnable = true;
	}
}

function Mapper4Scanline()
{
	if (irqResetCounter)
	{
		irqCounter = irqStartCounter;
		irqResetCounter = false;
	}
	else
	{
		irqCounter--;
		if (irqCounter <= 0)
		{
			if (irqEnable)
				irqRequest = true;
			irqResetCounter = true;
		}
	}
}

function Mapper4IRQRequest()
{
	return irqRequest;
}

var MAPPER_INIT = 0;
var MAPPER_WRITE = 1;
var MAPPER_SCANLINE = 2;
var MAPPER_IRQ_REQUEST = 3;
var Mappers = [];
Mappers[0] = [Mapper0Init, Mapper0Write, Mapper0Scanline, Mapper0IRQRequest];
Mappers[1] = [Mapper1Init, Mapper1Write, Mapper1Scanline, Mapper1IRQRequest];
Mappers[4] = [Mapper4Init, Mapper4Write, Mapper4Scanline, Mapper4IRQRequest];

function SetNZFlags(value)
{
	p = (p & ~(S_FLAG | Z_FLAG)) | NZFlags[value];
}

function SetCNZFlags(value)
{
	p = (p & ~(C_FLAG | S_FLAG | Z_FLAG)) | NZFlags[value];
}

function ADC(a, b)
{
	var value = a + b + (p & C_FLAG);
	SetCNZFlags(value);
	p = (p & ~V_FLAG) | (((b ^ a ^ 0x80) & (b ^ value) & 0x80) >> 1);
	return value & 0xff;
}

function ASL(a)
{
	var value = (a << 1) & 0xff;
	p = (p & ~C_FLAG) | (a >> 7);
	SetNZFlags(value);
	return value;
}

function BIT(a, b)
{
	var value = a & b;
	p = (p & ~(Z_FLAG | S_FLAG | V_FLAG)) | (b & 0xc0);
	if (value == 0)
		p |= Z_FLAG;
	return value;
}

function BRK()
{
	Push16((pc + 1) & 0xffff);
	p |= B_FLAG;
	Push8(p);
	p |= I_FLAG;
	pc = Read16(0xfffe);
}

function LSR(a)
{
	var value = a >> 1;
	p = (p & ~C_FLAG) | (a & 1);
	SetNZFlags(value);
	return value;
}

function ROL(a)
{
	var value = ((a << 1) | (p & C_FLAG)) & 0xff;
	p = (p & ~C_FLAG) | (a >> 7);
	SetNZFlags(value);
	return value;
}

function ROR(a)
{
	var value = (a >> 1) | ((p & C_FLAG) << 7);
	p = (p & ~C_FLAG) | (a & 1);
	SetNZFlags(value);
	return value;
}

function SBC(a, b)
{
	var value = a - b - (1 - (p & C_FLAG));
	SetCNZFlags(value + 0x100);
	p = (p & ~V_FLAG) | (((b ^ a) & (a ^ value) & 0x80) >> 1);
	return value & 0xff;
}

function Read8(addr)
{
	if (addr < 0x2000)
		return ram[ramPages[addr >> 11] + (addr & 0x7ff)];
	if (addr >= 0x8000)
		return rom[romPages[(addr - 0x8000) >> 11] + (addr & 0x7ff)];
	if (addr >= 0x6000)
	{
		if (sramEnable)
			return sram[addr & 0x1fff];
		return 0;
	}
	if (addr == 0x2000)
		return ppuReg1;
	if (addr == 0x2001)
		return ppuReg2;
	if (addr == 0x2002)
	{
		var value = vblankReg;
		vblankReg &= ~VBLANK;
		vramAddrWriteHigh = true;
		writeToVertScroll = false;
		return value;
	}
	if (addr == 0x2007)
	{
		var value = vramReadBuffer;
		vramReadBuffer = VramRead(vramAddr);
		if (ppuReg1 & VERTICAL_WRITE)
			vramAddr = (vramAddr + 32) & 0x3fff;
		else
			vramAddr = (vramAddr + 1) & 0x3fff;
		return value;
	}
	if (addr == 0x4016)
	{
		if ((joy1State < 0) || (joy1State >= 8))
			return 0;
		var value = joy1[joy1State];
		joy1State++;
		return value;
	}
	if (addr == 0x4017)
	{
		if ((joy2State < 0) || (joy2State >= 8))
			return 0;
		var value = joy2[joy2State];
		joy2State++;
		return value;
	}
	return 0;
}

function Read16(addr)
{
	return Read8(addr) | (Read8(addr + 1) << 8);
}

function ReadZeroPage16(addr)
{
	return Read8(addr) | (Read8((addr + 1) & 0xff) << 8);
}

function Write8(addr, value)
{
	if (addr < 0x2000)
		ram[ramPages[addr >> 11] + (addr & 0x7ff)] = value;
	else if (addr >= 0x8000)
		mapper[MAPPER_WRITE](addr, value);
	else if (addr >= 0x6000)
	{
		if (sramEnable)
			sram[addr & 0x1fff] = value;
	}
	else if (addr == 0x2000)
		ppuReg1 = value;
	else if (addr == 0x2001)
		ppuReg2 = value;
	else if (addr == 0x2003)
		spriteAddr = value;
	else if (addr == 0x2004)
	{
		spriteMem[spriteAddr] = value;
		spriteAddr = (spriteAddr + 1) & 0xff;
	}
	else if (addr == 0x2005)
	{
		if (writeToVertScroll)
		{
			if (value >= 240)
				vertScroll = value - 256;
			else
				vertScroll = value;
		}
		else
		{
			horizScroll = value;
		}
		writeToVertScroll = !writeToVertScroll;
	}
	else if (addr == 0x2006)
	{
		if (vramAddrWriteHigh)
			vramAddr = (vramAddr & 0xff) | ((value & 0x3f) << 8);
		else
		{
			vramAddr = (vramAddr & 0xff00) | value;
			ppuReg1 = (ppuReg1 & ~3) | ((vramAddr >> 10) & 3);
		}
		vramAddrWriteHigh = !vramAddrWriteHigh;
	}
	else if (addr == 0x2007)
	{
		VramWrite(vramAddr, value)
		if (ppuReg1 & VERTICAL_WRITE)
			vramAddr = (vramAddr + 32) & 0x3fff;
		else
			vramAddr = (vramAddr + 1) & 0x3fff;
	}
	else if (addr == 0x4014)
	{
		base = value << 8;
		for (var i = 0; i < 256; i++)
			Write8(0x2004, Read8(base + i));
	}
	else if (addr == 0x4016)
	{
		if ((value & 1) != 0)
			joy1State = joy2State = -1;
		else
			joy1State = joy2State = 0;
	}
	else if ((addr >= 0x4000) && (addr < 0x4010))
	{
		if (!First)
			MusicUpdates += addr.toString(16) + '=' + value.toString(16) + ' ';
		HasUpdates = true;
		ReallyHasUpdates = true;
	}
}

function Write16(addr, value)
{
	Write8(addr, value & 0xff);
	Write8(addr + 1, value >> 8);
}

function Code8()
{
	var value = Read8(pc);
	pc++;
	return value;
}

function SignedCode8()
{
	var value = Code8();
	return value | ((value >> 7) * 0xff00);
}

function Code16()
{
	var value = Read16(pc);
	pc += 2;
	return value;
}

function Push8(value)
{
	Write8(0x100 + s, value);
	s = (s - 1) & 0xff;
}

function Push16(value)
{
	Push8(value >> 8);
	Push8(value & 0xff);
}

function Pop8()
{
	s = (s + 1) & 0xff;
	return Read8(0x100 + s);
}

function Pop16()
{
	var value = Pop8();
	value |= Pop8() << 8;
	return value;
}

function MapMemory(addr, size, target)
{
	if (addr < 0x2000)
	{
		for (var i = 0; i < size; i += 0x800)
			ramPages[(addr + i) >> 11] = target + i;
	}
	else
	{
		for (var i = 0; i < size; i += 0x800)
			romPages[(addr + i - 0x8000) >> 11] = target + i;
	}
}

function MapChr(addr, size, target)
{
	for (var i = 0; i < size; i += 0x400)
		chrPages[(addr + i) >> 10] = target + i;
}

function MapVertMirror()
{
	nameTablePages = [0, 0x400, 0, 0x400];
}

function MapHorizMirror()
{
	nameTablePages = [0, 0, 0x400, 0x400];
}

function MapFourScreenMirror(table)
{
	nameTablePages = [table, table, table, table];
}

function VramRead(addr)
{
	if (addr < 0x2000)
		return chr[chrPages[addr >> 10] + (addr & 0x3ff)];
	else if (addr < 0x3f00)
		return nameTable[nameTablePages[(addr & 0xfff) >> 10] + (addr & 0x3ff)];
	else
		return palette[addr & 0x1f];
}

function VramWrite(addr, value)
{
	if (addr < 0x2000)
	{
		if (chrWritable)
			chr[chrPages[addr >> 10] + (addr & 0x3ff)] = value;
	}
	else if (addr < 0x3f00)
	{
		nameTable[nameTablePages[(addr & 0xfff) >> 10] + (addr & 0x3ff)] = value;
	}
	else
	{
		palette[addr & 0x1f] = value;
	}
}

function Color(attr, bit0, bit1)
{
	var value = bit0 | (bit1 << 1) | (attr << 2);
	if (!(value & 3))
		value = 16;
	return Palette[palette[value]];
}

var Frames = 0;
var Seconds = 0;
var Done = false;
var First = true;

function Scanline()
{
	scanline = (scanline + 1) % 262;

	if (scanline >= 20)
		mapper[MAPPER_SCANLINE]();

	if (scanline == 261)
	{
		Frames++;
		if (Frames >= 60)
		{
			Frames = 0;
			Seconds++;
		}
		if ((!Done) && (!First))
			MusicUpdates += "\n";
		if (!HasUpdates)
			Done = true;
		process.stdout.write("\r" + Seconds.toString());
		if (ReallyHasUpdates)
			First = false;
		HasUpdates = false;
		frameReady = true;
		vblankReg |= VBLANK;
		return;
	}

	if (scanline == 20)
	{
		vblankReg &= ~(VBLANK | HIT_DETECT);
		vblankTriggered = false;
		return;
	}
}

function Disassemble(addr)
{
	var opcode = Read8(addr);
	var operandByte1 = Read8(addr + 1);
	var operandByte2 = Read8(addr + 2);
	result = DisassembleOperandProcs[InstructionOperandTypes[opcode]](addr, operandByte1, operandByte2);
	var operands = result[0];
	var operandLength = result[1];
	if (operandLength == 0)
		return [InstructionNames[opcode] + operands, [opcode]];
	if (operandLength == 1)
		return [InstructionNames[opcode] + operands, [opcode, operandByte1]];
	return [InstructionNames[opcode] + operands, [opcode, operandByte1, operandByte2]];
}

function KeyDown(event)
{
	if (event.keyCode == 88) // X (B)
		joy1[0] = 1;
	if (event.keyCode == 90) // Z (A)
		joy1[1] = 1;
	if (event.keyCode == 32) // Space (Select)
		joy1[2] = 1;
	if (event.keyCode == 13) // Enter (Start)
		joy1[3] = 1;
	if (event.keyCode == 38) // Up
		joy1[4] = 1;
	if (event.keyCode == 40) // Down
		joy1[5] = 1;
	if (event.keyCode == 37) // Left
		joy1[6] = 1;
	if (event.keyCode == 39) // Right
		joy1[7] = 1;
}

function KeyUp(event)
{
	if (event.keyCode == 88) // X (B)
		joy1[0] = 0;
	if (event.keyCode == 90) // Z (A)
		joy1[1] = 0;
	if (event.keyCode == 32) // Space (Select)
		joy1[2] = 0;
	if (event.keyCode == 13) // Enter (Start)
		joy1[3] = 0;
	if (event.keyCode == 38) // Up
		joy1[4] = 0;
	if (event.keyCode == 40) // Down
		joy1[5] = 0;
	if (event.keyCode == 37) // Left
		joy1[6] = 0;
	if (event.keyCode == 39) // Right
		joy1[7] = 0;
}

function Init()
{
	document.addEventListener("keydown", KeyDown, false);
	document.addEventListener("keyup", KeyUp, false);

	ExecuteFrame();
}

function SingleStep()
{
	Instructions[Code8()]();

	if (cycles >= nextScanlineCycle)
	{
		Scanline();

		nextScanlineCycle += 113;
		scanlineCycleFraction += 2;
		if (scanlineCycleFraction >= 3)
		{
			nextScanlineCycle += 1;
			scanlineCycleFraction -= 3;
		}

		if ((!vblankTriggered) && (vblankReg & VBLANK) && (ppuReg1 & VBLANK_ENABLE))
		{
			vblankTriggered = true;
			Push16(pc);
			Push8(p);
			p |= I_FLAG;
			pc = Read16(0xfffa);
		}
	}

	if (mapper[MAPPER_IRQ_REQUEST]() && (!(p & I_FLAG)))
	{
		Push16(pc);
		p &= ~B_FLAG;
		Push8(p);
		p |= I_FLAG;
		pc = Read16(0xfffe);
	}
}

function Execute()
{
	while (true)
	{
		while (!frameReady)
			SingleStep();
		frameReady = false;

		if (Done)
		{
			console.log("\nDone\n");
			fs.writeFileSync(process.argv[2] + '.txt', MusicUpdates);
			break;
		}
	}
}

var romBankCount = ROMImage[4];
var vromBankCount = ROMImage[5];
var romFlags = ROMImage[6];
var mapperIndex = (romFlags >> 4) | (ROMImage[7] & 0xff);
var ramBankCount = ROMImage[8];
if (ramBankCount == 0)
	ramBankCount = 1;

var offset = 16;
if (romFlags & 4)
	offset += 512;
var rom = ROMImage.slice(offset, offset + (romBankCount * 0x4000));
var vrom = ROMImage.slice(offset + (romBankCount * 0x4000), offset + (romBankCount * 0x4000) + (vromBankCount * 0x2000));
var ram = new Array(ramBankCount * 0x2000);
var sram = new Array(0x2000);
var sramEnable = false;
for (var i = 0; i < (ramBankCount * 0x2000); i++)
	ram[i] = 0;
for (var i = 0; i < 0x2000; i++)
	sram[i] = 0;

var ramPages = [0, 0, 0, 0];
var romPages = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
MapMemory(0x8000, 0x4000, 0);
MapMemory(0xc000, 0x4000, 0x4000 * (romBankCount - 1));
var mapper = Mappers[mapperIndex];

var a = 0;
var x = 0;
var y = 0;
var s = 0;
var p = 0x20 | I_FLAG;
var pc = Read16(0xfffc);
var cycles = 0;

var nextScanlineCycle = cycles;
var scanlineCycleFraction = 0;
var scanline = 0;
var ppuReg1 = 0;
var ppuReg2 = 0;
var spriteAddr = 0;
var vertScroll = 0;
var horizScroll = 0;
var writeToVertScroll = false;
var vramAddr = 0;
var vramAddrWriteHigh = true;
var vramReadBuffer = 0;
var vblankReg = 0x80;
var vblankTriggered = false;
var frameReady = false;

var palette = new Array(32);
var spriteMem = new Array(256);
for (var i = 0; i < 32; i++)
	palette[i] = 0;
for (var i = 0; i < 256; i++)
	spriteMem[i] = 0;

var chr, chrWritable;
if (vromBankCount == 0)
{
	chr = new Array(0x2000);
	chrWritable = true;
	for (var i = 0; i < 0x2000; i++)
		chr[i] = 0;
}
else
{
	chr = vrom;
	chrWritable = false;
}
var chrPages = new Array(8);
for (var i = 0; i < 8; i++)
	chrPages[i] = i * 0x400;

var nameTable = new Array(0x1000);
var nameTablePages = [0, 0, 0, 0];
for (var i = 0; i < 0x1000; i++)
	nameTable[i] = 0;
if (romFlags & 8)
	nameTablePages = [0, 0x400, 0x800, 0xc00];
else if (romFlags & 1)
	MapVertMirror();
else
	MapHorizMirror();

var joy1 = [0, 0, 0, 0, 0, 0, 0, 0];
var joy2 = [0, 0, 0, 0, 0, 0, 0, 0];
var joy1State = 0;
var joy2State = 0;

var pixels = new Array(256 + 16);
for (var y = 0; y < (256 + 16); y++)
{
	pixels[y] = new Array(256 + 8);
	for (var x = 0; x < (256 + 8); x++)
		pixels[y][x] = [0, 0, 0];
}

InstructionProcs = [];
InstructionProcs["adc"] = function(arg) { a = ADC(a, arg); };
InstructionProcs["asl"] = function(arg) { Write8(arg, ASL(Read8(arg))); };
InstructionProcs["asl@"] = function(arg) { a = ASL(arg); };
InstructionProcs["and"] = function(arg) { a = a & arg; SetNZFlags(a); };
InstructionProcs["bcc"] = function(arg) { if (!(p & C_FLAG)) pc = arg; };
InstructionProcs["bcs"] = function(arg) { if (p & C_FLAG) pc = arg; };
InstructionProcs["beq"] = function(arg) { if (p & Z_FLAG) pc = arg; };
InstructionProcs["bit"] = function(arg) { BIT(a, arg); };
InstructionProcs["bmi"] = function(arg) { if (p & S_FLAG) pc = arg; };
InstructionProcs["bne"] = function(arg) { if (!(p & Z_FLAG)) pc = arg; };
InstructionProcs["bpl"] = function(arg) { if (!(p & S_FLAG)) pc = arg; };
InstructionProcs["brk"] = function(arg) { BRK(); };
InstructionProcs["bvc"] = function(arg) { if (!(p & V_FLAG)) pc = arg; };
InstructionProcs["bvs"] = function(arg) { if (p & V_FLAG) pc = arg; };
InstructionProcs["clc"] = function(arg) { p &= ~C_FLAG; };
InstructionProcs["cld"] = function(arg) { p &= ~D_FLAG; };
InstructionProcs["cli"] = function(arg) { p &= ~I_FLAG; };
InstructionProcs["clv"] = function(arg) { p &= ~V_FLAG; };
InstructionProcs["cmp"] = function(arg) { var value = 0x100 + a - arg; SetCNZFlags(value); };
InstructionProcs["cpx"] = function(arg) { var value = 0x100 + x - arg; SetCNZFlags(value); };
InstructionProcs["cpy"] = function(arg) { var value = 0x100 + y - arg; SetCNZFlags(value); };
InstructionProcs["dec"] = function(arg) { var value = (Read8(arg) - 1) & 0xff; Write8(arg, value); SetNZFlags(value); };
InstructionProcs["dex"] = function(arg) { x = (x - 1) & 0xff; SetNZFlags(x); };
InstructionProcs["dey"] = function(arg) { y = (y - 1) & 0xff; SetNZFlags(y); };
InstructionProcs["eor"] = function(arg) { a = a ^ arg; SetNZFlags(a); };
InstructionProcs["inc"] = function(arg) { var value = (Read8(arg) + 1) & 0xff; Write8(arg, value); SetNZFlags(value); };
InstructionProcs["inx"] = function(arg) { x = (x + 1) & 0xff; SetNZFlags(x); };
InstructionProcs["iny"] = function(arg) { y = (y + 1) & 0xff; SetNZFlags(y); };
InstructionProcs["invalid"] = function(arg) { alert("Invalid instruction, previous pc=" + Hex16(lastPC)); };
InstructionProcs["jmp"] = function(arg) { pc = arg; };
InstructionProcs["jsr"] = function(arg) { Push16((pc - 1) & 0xffff); pc = arg; };
InstructionProcs["lda"] = function(arg) { a = arg; SetNZFlags(arg); };
InstructionProcs["ldx"] = function(arg) { x = arg; SetNZFlags(arg); };
InstructionProcs["ldy"] = function(arg) { y = arg; SetNZFlags(arg); };
InstructionProcs["lsr"] = function(arg) { Write8(arg, LSR(Read8(arg))); };
InstructionProcs["lsr@"] = function(arg) { a = LSR(arg); };
InstructionProcs["nop"] = function(arg) {},
InstructionProcs["ora"] = function(arg) { a = a | arg; SetNZFlags(a); };
InstructionProcs["pha"] = function(arg) { Push8(a); };
InstructionProcs["php"] = function(arg) { Push8(p); };
InstructionProcs["pla"] = function(arg) { a = Pop8(); SetNZFlags(a); };
InstructionProcs["plp"] = function(arg) { p = Pop8(); };
InstructionProcs["rol"] = function(arg) { Write8(arg, ROL(Read8(arg))); };
InstructionProcs["rol@"] = function(arg) { a = ROL(arg); };
InstructionProcs["ror"] = function(arg) { Write8(arg, ROR(Read8(arg))); };
InstructionProcs["ror@"] = function(arg) { a = ROR(arg); };
InstructionProcs["rti"] = function(arg) { p = Pop8() | 0x20; pc = Pop16(); };
InstructionProcs["rts"] = function(arg) { pc = (Pop16() + 1) & 0xffff; };
InstructionProcs["sbc"] = function(arg) { a = SBC(a, arg); };
InstructionProcs["sec"] = function(arg) { p |= C_FLAG; };
InstructionProcs["sed"] = function(arg) { p |= D_FLAG; };
InstructionProcs["sei"] = function(arg) { p |= I_FLAG; };
InstructionProcs["sta"] = function(arg) { Write8(arg, a); };
InstructionProcs["stx"] = function(arg) { Write8(arg, x); };
InstructionProcs["sty"] = function(arg) { Write8(arg, y); };
InstructionProcs["tax"] = function(arg) { x = a; SetNZFlags(x); };
InstructionProcs["tay"] = function(arg) { y = a; SetNZFlags(y); };
InstructionProcs["tsx"] = function(arg) { x = s; SetNZFlags(x); };
InstructionProcs["txa"] = function(arg) { a = x; SetNZFlags(a); };
InstructionProcs["txs"] = function(arg) { s = x; };
InstructionProcs["tya"] = function(arg) { a = y; SetNZFlags(a); };

ArgProcs = [
	function() { return undefined; }, // NONE
	function() { return Read8(Code16()); }, // ABS
	function() { return Code16(); }, // ABS_DEST
	function() { return Read8((Code16() + x) & 0xffff); }, // ABS_X
	function() { return (Code16() + x) & 0xffff; }, // ABS_X_DEST
	function() { return Read8((Code16() + y) & 0xffff); }, // ABS_Y
	function() { return (Code16() + y) & 0xffff; }, // ABS_Y_DEST
	function() { return a; }, // ACCUM
	function() { return Code16(); }, // ADDR
	function() { return Code8(); }, // IMMED
	function() { var addr = Code16(); return Read8(addr) | (Read8((addr & 0xff00) | ((addr + 1) & 0xff)) << 8); }, // IND
	function() { return Read8(ReadZeroPage16((Code8() + x) & 0xff)); }, // IND_X
	function() { return ReadZeroPage16((Code8() + x) & 0xff); }, // IND_X_DEST
	function() { return Read8((ReadZeroPage16(Code8()) + y) & 0xffff); }, // IND_Y
	function() { return (ReadZeroPage16(Code8()) + y) & 0xffff; }, // IND_Y_DEST
	function() { var ofs = SignedCode8(); return (pc + ofs) & 0xffff; }, // REL
	function() { return Read8(Code8()); }, // ZERO
	function() { return Code8(); }, // ZREO_DEST
	function() { return Read8((Code8() + x) & 0xff); }, // ZERO_X
	function() { return (Code8() + x) & 0xff; }, // ZERO_X_DEST
	function() { return Read8((Code8() + y) & 0xff); }, // ZERO_Y
	function() { return (Code8() + y) & 0xff; } // ZERO_Y_DEST
];

function MakeInstruction(instructionProc, argProc, clocks)
{
	return function() { instructionProc(argProc()); cycles += clocks; };
}

Instructions = new Array(256);
for (var index = 0; index < 256; index++)
{
	var name = InstructionNames[index];
	var instructionProc = InstructionProcs[name];
	var argProc = ArgProcs[InstructionOperandTypes[index]];
	var clocks = InstructionClocks[index];
	Instructions[index] = MakeInstruction(instructionProc, argProc, clocks);
}

Execute();
