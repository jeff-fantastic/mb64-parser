# mesh_data.gd
class_name MeshData extends Node

'''
Holds mesh and material constants
'''

## Tile types enum
enum TileTypes {
	Empty				= 0x00,
	Slope				= 0x02,
	DSlope				= 0x03,
	Slab				= 0x04,
	DSlab				= 0x05,
	Corner				= 0x06,
	DCorner				= 0x07,
	ICorner				= 0x08,
	DICorner			= 0x09,
	SCorner				= 0x0A,
	DSCorner			= 0x0B,
	UGentle				= 0x0C,
	DUGentle			= 0x0D,
	LGentle				= 0x0E,
	DLGentle			= 0x0F,
	EndOfFlippable		= 0x10,
	Block				= EndOfFlippable,
	SSlope				= 0x11,
	SSlab				= 0x12,
	Cull				= 0x13,
	Troll				= 0x14,
	Fence				= 0x15,
	Pole				= 0x16,
	Bars				= 0x17,
	Water				= 0x18,
}

## Tile overhang type enum
enum GrowthTypes {
	None				= 0x00,
	Full				= 0x01,
	NormalSide			= 0x02,
	HalfSide			= 0x03,
	UndersideSlopeCorner= 0x04,
	DiagonalSide		= 0x05,
	VerticalSlabSide	= 0x06,
	DownLowerGentleUnder= 0x07,
	Unconditional		= 0x08,
	ExtraDecalStart		= 0x10,
	SlopeSideL			= ExtraDecalStart,
	SlopeSideR			= 0x11,
	GentleSideL			= 0x12,
	GentleSideR			= 0x13,
}

## Tile cull type enum
enum Cull { 
	Full				= 0x00,
	PoleTop				= 0x01,
	Tri_1				= 0x02,
	Tri_2				= 0x03,
	DownTri_1			= 0x04,
	DownTri_2			= 0x05,
	HalfSide_1			= 0x06,
	HalfSide_2			= 0x07,
	TopTri				= 0x08,
	TopHalf				= 0x09,
	Empty				= 0x0A,
	BottomSlab_Priority = 0x10,
	UpperGentle_1		= BottomSlab_Priority,
	UpperGentle_2		= 0x11,
	BottomSlab			= 0x12,
	LowerGentle_1		= 0x14,
	LowerGentle_2		= 0x15,
	TopSlab_Priority	= 0x20,
	DownUpperGentle_1	= TopSlab_Priority,
	DownUpperGentle_2	= 0x21,
	TopSlab				= 0x22,
	DownLowerGentle_1	= 0x24,
	DownLowerGentle_2	= 0x25
}

## Dirs
enum Dir {
	Top					= 0x00,
	Bottom				= 0x01,
	Right				= 0x02,
	Left				= 0x03,
	Back				= 0x04,
	Front				= 0x05
}

enum Mat {
	ListStart					= 0x00,
	
	Grass						= ListStart,
	GrassOld					= 0x01,
	CartoonGrass				= 0x02,
	DarkGrass					= 0x03,
	HMCGrass					= 0x04,
	OrangeGrass					= 0x05,
	RedGrass					= 0x06,
	PurpleGrass					= 0x07,
	Sand						= 0x08,
	JRBSand						= 0x09,
	Snow						= 0x0A,
	SnowOld						= 0x0B,
	Dirt						= 0x0C,
	SandDirt					= 0x0D,
	LightDirt					= 0x0E,
	HMCDirt						= 0x0F,
	RockyDirt					= 0x10,
	DirtOld						= 0x11,
	WavyDirt					= 0x12,
	WavyDirtBlue				= 0x13,
	SnowDirt					= 0x14,
	PurpleDirt					= 0x15,
	HMCLakeGrass				= 0x16,
	
	TerrainEnd					= 0x17,
	
	Stone						= TerrainEnd,
	HMCStone					= 0x18,
	HMCMazeFloor				= 0x19,
	CCMRock						= 0x1A,
	TTMFloor					= 0x1B,
	TTMRock						= 0x1C,
	Cobblestone					= 0x1D,
	JRBWall						= 0x1E,
	Gabbro						= 0x1F,
	RHRStone					= 0x20,
	LavaRocks					= 0x21,
	VolcanoWall					= 0x22,
	RHRBasalt					= 0x23,
	Obsidian					= 0x24,
	CastleStone					= 0x25,
	JRBUnderwater				= 0x26,
	SnowRock					= 0x27,
	IcyRock						= 0x28,
	DesertStone					= 0x29,
	RHRObsidian					= 0x2A,
	JRBStone					= 0x2B,
	
	StoneEnd					= 0x2C,
	
	Bricks						= StoneEnd,
	DesertBricks				= 0x2D,
	RHRBrick					= 0x2E,
	HMCBrick					= 0x2F,
	BrownBrick					= 0x30, # I LOVE BUILDING BROWN BRICKS
	WDWBrick					= 0x31,
	TTMBrick					= 0x32,
	CastleBrick					= 0x33,
	BBHBrick					= 0x34,
	RoofBrick					= 0x35,
	CastleOutsideBrick			= 0x36,
	SnowBrick					= 0x37,
	JRBBrick					= 0x38,
	SnowTileSide				= 0x39,
	TileBrick					= 0x3A,
	
	BricksEnd					= 0x3B,
	
	Tile						= BricksEnd,
	CastleTile					= 0x3C,
	DesertTile					= 0x3D,
	BlueTile					= 0x3E,
	SnowTile					= 0x3F,
	JRBTileTop					= 0x40,
	JRBTileSide					= 0x41,
	HMCTile						= 0x42,
	GraniteTile					= 0x43,
	RHRTile						= 0x44,
	VPTile						= 0x45,
	DiamondTile					= 0x46,
	CastleStoneTop				= 0x47,
	SnowBrickTile				= 0x48,
	
	TilesEnd					= 0x49,
	
	DesertBlock					= TilesEnd,
	VPBlock						= 0x4A,
	BBHStone					= 0x4B,
	BBHStonePattern				= 0x4C,
	PatternedBlock				= 0x4D,
	HMCSlab						= 0x4E,
	RHRBlock					= 0x4F,
	GraniteBlock				= 0x50,
	StoneSide					= 0x51,
	Pillar						= 0x52,
	BBHPillar					= 0x53,
	RHRPillar					= 0x54,
	
	CutStoneEnd					= 0x55,
	
	Wood						= CutStoneEnd,
	BBHWoodFloor				= 0x56,
	BBHWoodWall					= 0x57,
	CastleWood					= 0x58,
	JRBWood						= 0x59,
	JRBShipSide					= 0x5A,
	JRBShipTop					= 0x5B,
	BBHHauntedPlanks			= 0x5C,
	BBHRoof						= 0x5D,
	SolidWood					= 0x5E,
	RHRWood						= 0x5F,
	
	WoodEnd						= 0x60,
	
	BBHMetal					= WoodEnd,
	JRBMetalSide				= 0x61,
	JRBMetal					= 0x62,
	CastleBasementWall			= 0x63,
	DesertTiles2				= 0x64,
	RustyBlock					= 0x65,
	
	MetalEnd					= 0x66,
	
	CastleCarpet				= MetalEnd,
	CastleWall					= 0x67,
	Roof						= 0x68,
	CastleRoof					= 0x69,
	SnowRoof					= 0x6A,
	BBHWindow					= 0x6B,
	HMCLight					= 0x6C,
	VPCaution					= 0x6D,
	RRBlock						= 0x6E,
	StuddedTile					= 0x6F,
	TTCBlock					= 0x70,
	TTCSide						= 0x71,
	TTCWall						= 0x72,
	Flower						= 0x73,
	
	BuildingEnd					= 0x74,
	
	Lava						= 0x75,
	LavaOld						= 0x76,
	Acid						= 0x77,
	BurningIce					= 0x78,
	Quicksand					= 0x79,
	SlowSand					= 0x7A,
	Void						= 0x7B,
	
	HazardEnd					= 0x7C,
	
	RHRMesh						= HazardEnd,
	VPMesh						= 0x7D,
	HMCMesh						= 0x7E,
	BBHMesh						= 0x7F,
	PinkMesh					= 0x80,
	TTCMesh						= 0x81,
	Ice							= 0x82,
	Crystal						= 0x83,
	VPScreen					= 0x84,
	
	End							= 0x85,
	
	RetroGround					= End,
	RetroBricks					= 0x86,
	RetroTreeTop				= 0x87,
	RetroTreePlat				= 0x88,
	RetroBlock					= 0x89,
	RetroBlueGround				= 0x8A,
	RetroBlueBricks				= 0x8B,
	RetroBlueBlock				= 0x8C,
	RetroWhiteBrick				= 0x8D,
	RetroLava					= 0x8E,
	RetroUnderWaterGround		= 0x8F,
	
	MCDirt						= 0x90,
	MCGrass						= 0x91,
	MCCobblestone				= 0x92,
	MCStone						= 0x93,
	MCOakLogTop					= 0x94,
	MCOakLogSide				= 0x95,
	MCOakLeaves					= 0x96,
	MCWoodPlanks				= 0x97,
	MCSand						= 0x98,
	MCBricks					= 0x99,
	MCLava						= 0x9A,
	MCFlowingLava				= 0x9B,
	MCGlass						= 0x9C
}

## Bar materials
enum MatBar {
	Generic,
	RHR,
	VP,
	HMC,
	BBH,
	LLL,
	TTC,
	Desert,
	BOB,
	Retro,
	MC
}

## Fence materials
enum MatFence {
	Normal,
	Wood2,
	Desert,
	Barbed,
	RHR,
	HMC,
	Castle,
	VP,
	BBH,
	JRB,
	Snow2,
	Snow,
	Retro,
	MC
}

enum MatWater {
	Default,
	Green,
	Retro,
	MC
}

## Materials
@onready var materials = [
	preload("res://asset/mat/grass.tres"), # Material 000
	null, # Material 001
	null, # Material 002
	null, # Material 003
	null, # Material 004
	null, # Material 005
	null, # Material 006
	null, # Material 007
	preload("res://asset/mat/sand.tres"), # Material 008
	null, # Material 009
	null, # Material 010
	null, # Material 011
	preload("res://asset/mat/dirt.tres"), # Material 012
	preload("res://asset/mat/sand_dirt.tres"), # Material 013
	null, # Material 014
	null, # Material 015
	null, # Material 016
	null, # Material 017
	null, # Material 018
	null, # Material 019
	null, # Material 020
	null, # Material 021
	null, # Material 022
	preload("res://asset/mat/stone.tres"), # Material 023
	null, # Material 024
	null, # Material 025
	null, # Material 026
	null, # Material 027
	null, # Material 028
	preload("res://asset/mat/cobblestone.tres"), # Material 029
	null, # Material 030
	null, # Material 031
	null, # Material 032
	null, # Material 033
	null, # Material 034
	null, # Material 035
	null, # Material 036
	null, # Material 037
	null, # Material 038
	null, # Material 039
	null, # Material 040
	null, # Material 041
	null, # Material 042
	null, # Material 043
	preload("res://asset/mat/bricks.tres"), # Material 044
	null, # Material 045
	null, # Material 046
	null, # Material 047
	null, # Material 048
	null, # Material 049
	null, # Material 050
	null, # Material 051
	null, # Material 052
	null, # Material 053
	null, # Material 054
	null, # Material 055
	null, # Material 056
	null, # Material 057
	preload("res://asset/mat/tile_brick.tres"), # Material 058
	preload("res://asset/mat/tile.tres"), # Material 059
	null, # Material 060
	null, # Material 061
	null, # Material 062
	null, # Material 063
	null, # Material 064
	null, # Material 065
	null, # Material 066
	null, # Material 067
	null, # Material 068
	null, # Material 069
	null, # Material 070
	null, # Material 071
	null, # Material 072
	null, # Material 073
	null, # Material 074
	null, # Material 075
	null, # Material 076
	null, # Material 077
	null, # Material 078
	null, # Material 079
	null, # Material 080
	null, # Material 081
	null, # Material 082
	null, # Material 083
	null, # Material 084
	preload("res://asset/mat/wood.tres"), # Material 085
	null, # Material 086
	null, # Material 087
	null, # Material 088
	null, # Material 089
	null, # Material 090
	null, # Material 091
	null, # Material 092
	null, # Material 093
	null, # Material 094
	null, # Material 095
	null, # Material 096
	null, # Material 097
	null, # Material 098
	null, # Material 099
	null, # Material 100
	null, # Material 101
	null, # Material 102
	null, # Material 103
	preload("res://asset/mat/roof.tres"), # Material 104
	null, # Material 105
	null, # Material 106
	null, # Material 107
	null, # Material 108
	null, # Material 109
	null, # Material 110
	null, # Material 111
	null, # Material 112
	null, # Material 113
	null, # Material 114
	null, # Material 115
	null, # Material 116
	preload("res://asset/mat/lava.tres"), # Material 117
	null, # Material 118
	null, # Material 119
	null, # Material 120
	null, # Material 121
	null, # Material 122
	null, # Material 123
	null, # Material 124
	null, # Material 125
	null, # Material 126
	null, # Material 127
	null, # Material 128
	null, # Material 129
	null, # Material 130
	null, # Material 131
	null, # Material 132
	null, # Material 133
	null, # Material 134
	null, # Material 135
	null, # Material 136
	null, # Material 137
	null, # Material 138
	null, # Material 139
	null, # Material 140
	null, # Material 141
	null, # Material 142
	null, # Material 143
	null, # Material 144
	null, # Material 145
	null, # Material 146
	null, # Material 147
	null, # Material 148
	null, # Material 149
	null, # Material 150
	null, # Material 151
	null, # Material 152
	null, # Material 153
	null, # Material 154
	null, # Material 155
	null, # Material 156
]

## Fence materials
@onready var fence_materials = [
	preload("res://asset/mat/fence.tres"),
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null
]

## Skybox materials
@onready var sb_materials = [
	preload("res://asset/mat/skybox/sb_water.tres"),
	preload("res://asset/mat/skybox/sb_cloud_floor.tres"),
	preload("res://asset/mat/skybox/sb_bitfs.tres"),
	preload("res://asset/mat/skybox/sb_bidw.tres"),
	preload("res://asset/mat/skybox/sb_bbh.tres"),
	preload("res://asset/mat/skybox/sb_ccm.tres"),
	preload("res://asset/mat/skybox/sb_ssl.tres"),
	preload("res://asset/mat/skybox/sb_wdw.tres"),
	preload("res://asset/mat/skybox/sb_bits.tres"),
	preload("res://asset/mat/skybox/sb_none.tres")
]

## Default themes.
var default_themes : Array[Array] = [
	## 0 - Generic
	[
		[Mat.Dirt,				Mat.Grass,				"Grass"],
		[Mat.Bricks,			Mat.Bricks,				"Bricks"],
		[Mat.Cobblestone,		Mat.Stone,				"Rock"],
		[Mat.TileBrick,			Mat.Tile,				"Tiling"],
		[Mat.Roof,				Mat.Roof,				"Roof"],
		[Mat.Wood,				Mat.Wood,				"Wood"],
		[Mat.SandDirt,			Mat.Sand,				"Sand"],
		[Mat.SnowDirt,			Mat.Snow,				"Snow"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		[Mat.Quicksand,			Mat.Quicksand,			"Quicksand"],
		MatFence.Normal, Mat.Stone, MatBar.Generic, MatWater.Default
	],
	## 1 - Desert
	[
		[Mat.SandDirt,			Mat.Sand,				"Sand"],
		[Mat.DesertBricks,		Mat.DesertBricks,		"Bricks"],
		[Mat.DesertStone,		Mat.DesertStone,		"Cobblestone"],
		[Mat.DesertTile,		Mat.DesertTile,			"Tiling"],
		[Mat.DesertBlock,		Mat.DesertBlock,		"Stone Block"],
		[Mat.SlowSand,			Mat.SlowSand,			"Slow Quicksand"],
		[Mat.DesertBricks,		Mat.DesertTiles2,		"Plating"],
		[Mat.Dirt,				Mat.Grass,				"Grass"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		[Mat.Quicksand,			Mat.Quicksand,			"Quicksand"],
		MatFence.Desert, Mat.DesertTiles2, MatBar.Desert, MatWater.Green
	],
	## 2 - Lava
	[
		[Mat.RHRStone,			Mat.RHRObsidian,		"Rock"],
		[Mat.RHRBrick,			Mat.RHRObsidian,		"Bricks"],
		[Mat.RHRBasalt,			Mat.RHRBasalt,			"Basalt"],
		[Mat.RHRTile,			Mat.RHRTile,			"Tiling"],
		[Mat.RHRBlock,			Mat.RHRBlock,			"Stone Block"],
		[Mat.RHRWood,			Mat.RHRWood,			"Wood"],
		[Mat.RHRPillar,			Mat.RHRTile,			"Pillar"],
		[Mat.RHRMesh,			Mat.RHRMesh,			"Mesh"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		[Mat.Acid,				Mat.Acid,				"Server Acid"],
		MatFence.RHR, Mat.RHRPillar, MatBar.RHR, MatWater.Default
	],
	## 3 - Cave
	[
		[Mat.HMCDirt,			Mat.HMCGrass,			"Grass"],
		[Mat.HMCBrick,			Mat.HMCMazeFloor,		"Bricks"],
		[Mat.HMCStone,			Mat.HMCStone,			"Rock"],
		[Mat.HMCSlab,			Mat.HMCTile,			"Tiling"],
		[Mat.HMCBrick,			Mat.HMCGrass,			"Grassy Bricks"],
		[Mat.HMCLakeGrass,		Mat.HMCGrass,			"Lake Wall"],
		[Mat.HMCLight,			Mat.HMCLight,			"Light"],
		[Mat.HMCMesh,			Mat.HMCMesh,			"Grille"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		[Mat.Quicksand,			Mat.Quicksand,			"Quicksand"],
		MatFence.HMC, Mat.HMCLakeGrass, MatBar.HMC, MatWater.Green
	],
	## 4 - Castle
	[
		[Mat.CastleWood,		Mat.CastleTile,			"Tiling"],
		[Mat.CastleBrick,		Mat.CastleTile,			"Tiling (Bricks)"],
		[Mat.CastleStone,		Mat.CastleStoneTop,		"Tiling (Stone)"],
		[Mat.CastleWood,		Mat.CastleCarpet,		"Carpet"],
		[Mat.CastleRoof,		Mat.CastleRoof,			"Roof"],
		[Mat.CastleWall,		Mat.CastleWall,			"Castle Wall"],
		[Mat.Pillar,			Mat.CastleStoneTop,		"Pillar"],
		[Mat.CastleBasementWall,Mat.CastleBasementWall,	"Basement Wall"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		[Mat.CastleOutsideBrick,Mat.CastleOutsideBrick,	"Castle Bricks"],
		MatFence.Castle, Mat.CastleStone, MatBar.VP, MatWater.Default
	],
	## 5 - Virtuaplex
	[
		[Mat.VPBlock,			Mat.VPBlock,			"Block"],
		[Mat.VPTile,			Mat.VPTile,				"Tiling"],
		[Mat.Dirt,				Mat.Grass,				"Grass"],
		[Mat.VPTile,			Mat.BlueTile,			"Blue Tiling"],
		[Mat.RustyBlock,		Mat.RustyBlock,			"Rusted Block"],
		[Mat.VPScreen,			Mat.VPScreen,			"Screen"],
		[Mat.VPCaution,			Mat.VPCaution,			"Hazard Stripes"],
		[Mat.VPBlock,			Mat.Snow,				"Snowy Block"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		[Mat.Void,				Mat.Void,				"Void"],
		MatFence.VP, Mat.VPCaution, MatBar.VP, MatWater.Default
	],
	## 6 - Snow
	[
		[Mat.SnowDirt,			Mat.Snow,				"Snow"],
		[Mat.SnowBrick,			Mat.SnowBrickTile,		"Bricks"],
		[Mat.SnowRock,			Mat.SnowRock,			"Rock"],
		[Mat.SnowTileSide,		Mat.SnowTile,			"Tiling"],
		[Mat.SnowRoof,			Mat.SnowRoof,			"Roof"],
		[Mat.Wood,				Mat.Wood,				"Wood"],
		[Mat.Crystal,			Mat.Crystal,			"Crystal"],
		[Mat.Ice,				Mat.Ice,				"Ice"],
		[Mat.BurningIce,		Mat.BurningIce,			"Hazard Ice"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		MatFence.Snow, Mat.SnowTileSide, MatBar.Generic, MatWater.Default
	],
	## 7 - Big Boos Haunt
	[
		[Mat.BBHBrick,			Mat.BBHStone,			"Stone Floor"],
		[Mat.BBHHauntedPlanks,	Mat.BBHHauntedPlanks,	"Haunted Planks"],
		[Mat.BBHStonePattern,	Mat.BBHWoodFloor,		"Wood Floor"],
		[Mat.BBHBrick,			Mat.BBHMetal,			"Metal Roof"],
		[Mat.BBHRoof,			Mat.BBHRoof,			"Roof"],
		[Mat.BBHWoodWall,		Mat.BBHWoodWall,		"Wood"],
		[Mat.BBHStone,			Mat.BBHStone,			"Wall"],
		[Mat.BBHPillar,			Mat.BBHStone,			"Pillar"],
		[Mat.Lava,				Mat.Lava,				"Lava"],
		[Mat.BBHWindow,			Mat.BBHWindow,			"Window"],
		MatFence.BBH, Mat.BBHBrick, MatBar.BBH, MatWater.Default
	],
	## 8 - Jolly Roger Bay
	[
		[Mat.JRBStone,			Mat.JRBSand,			"Sand"],
		[Mat.JRBBrick,			Mat.JRBBrick,			"Bricks"],
		[Mat.JRBUnderwater,		Mat.JRBUnderwater,		"Ocean Floor"],
		[Mat.JRBTileSide, 		Mat.JRBTileTop,			"Tiles"],
		[Mat.JRBShipSide,		Mat.JRBShipTop,			"Wood (Ship)"],
		[Mat.JRBMetalSide,		Mat.JRBWood,			"Wood (Docks)"],
		[Mat.JRBMetalSide,		Mat.JRBMetal,			"Metal"],
		[Mat.HMCMesh,			Mat.HMCMesh,			"Grille"],
		[Mat.JRBWall,			Mat.JRBWall,			"Wall"],
		[Mat.Quicksand,			Mat.Quicksand,			"Quicksand"],
		MatFence.JRB, Mat.VPCaution, MatBar.HMC, MatWater.Default
	],
	## 9 - Retro
	[
		[Mat.RetroGround,		Mat.RetroGround,		"Ground"],
		[Mat.RetroBricks,		Mat.RetroBricks,		"Bricks"],
		[Mat.RetroTreePlat,		Mat.RetroTreeTop,		"Treetop"],
		[Mat.RetroBlock,		Mat.RetroBlock,			"Block"],
		[Mat.RetroBlueGround,	Mat.RetroBlueGround,	"Blue Ground"],
		[Mat.RetroBlueBricks,	Mat.RetroBlueBricks,	"Blue Bricks"],
		[Mat.RetroBlueBlock,	Mat.RetroBlueBlock,		"Blue Block"],
		[Mat.RetroWhiteBrick,	Mat.RetroWhiteBrick,	"White Bricks"],
		[Mat.RetroLava,			Mat.RetroLava,			"Lava"],
		[Mat.RetroUnderWaterGround,	Mat.RetroUnderWaterGround,	"Underwater Tile"],
		MatFence.Retro, Mat.RetroBricks, MatBar.Retro, MatWater.Retro
	],
	## 10 - Custom Theme
	[],
	## 11 - Minecraft
	[
		[Mat.MCDirt,			Mat.MCGrass,			"Grass"],
		[Mat.MCCobblestone,		Mat.MCCobblestone,		"Cobblestone"],
		[Mat.MCStone,			Mat.MCStone,			"Stone"],
		[Mat.MCOakLogSide,		Mat.MCOakLogTop,		"Oak Log"],
		[Mat.MCOakLeaves,		Mat.MCOakLeaves,		"Oak Leaves"],
		[Mat.MCWoodPlanks,		Mat.MCWoodPlanks,		"Oak Planks"],
		[Mat.MCSand,			Mat.MCSand,				"Sand"],
		[Mat.MCBricks,			Mat.MCBricks,			"Bricks"],
		[Mat.MCFlowingLava,		Mat.MCLava,				"Lava"],
		[Mat.MCGlass,			Mat.MCGlass,			"Glass"],
		MatFence.MC, Mat.MCOakLogSide, MatBar.MC, MatWater.MC
	]
]

## Rotations
var dir_rot = [
	[Dir.Top, Dir.Bottom, Dir.Right, Dir.Left, Dir.Back, Dir.Front],
	[Dir.Top, Dir.Bottom, Dir.Front, Dir.Back, Dir.Right, Dir.Left],
	[Dir.Top, Dir.Bottom, Dir.Left, Dir.Right, Dir.Front, Dir.Back],
	[Dir.Top, Dir.Bottom, Dir.Back, Dir.Front, Dir.Left, Dir.Right]
]

## Normal dirs
const UP				= Vector3.UP
const DOWN				= Vector3.DOWN
const RIGHT				= Vector3.RIGHT
const LEFT				= Vector3.LEFT
const BACK				= Vector3.BACK
const FWD				= Vector3.FORWARD

## Side class
class TileSide extends Resource:
	var mesh : PackedVector3Array
	var indices : PackedInt32Array
	var normal : Vector3
	var dir : Dir
	var cullid : int
	var growth : GrowthTypes
	var uv : PackedVector2Array
	func _init(p_mesh : PackedVector3Array, p_ind : PackedInt32Array, p_normal : Vector3, 
	p_cullid : int, p_dir : Dir, p_growth : GrowthTypes, p_uv : PackedVector2Array = []) -> void:
		self.mesh = p_mesh
		self.indices = p_ind
		self.normal = p_normal
		self.dir = p_dir
		self.cullid = p_cullid
		self.growth = p_growth
		self.uv = p_uv

## Tile class
class Tile extends Resource:
	var sides : Array[Array]
	func _init(p_sides : Array[TileSide]) -> void:
		sides.resize(6)
		for side in p_sides:
			self.sides[side.dir].append(side)

## Tiles
@onready var tiles : Array[Tile] = [
	# Empty
	null,
	# Null,
	null,
	# Slope
	Tile.new([
		TileSide.new(PLANE_SLOPE,		INDICE_QUAD,		 UP+BACK,	Cull.Empty, Dir.Top,	GrowthTypes.Full,		UV_QUAD_SLOPE),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD_FLIPPED, DOWN, 		Cull.Full, 	Dir.Bottom,	GrowthTypes.None,		UV_QUAD_TOP),
		TileSide.new(TRIANGLE_SLOPER,	INDICE_TRI,  		 RIGHT, 	Cull.Tri_1, Dir.Left,	GrowthTypes.SlopeSideR,	UV_TRI),
		TileSide.new(TRIANGLE_SLOPEL,	INDICE_TRI_FLIPPED,  		 LEFT, 		Cull.Tri_2, Dir.Right,	GrowthTypes.SlopeSideL,	flip_u(UV_TRI)),
		TileSide.new(PLANE_FRONT,		INDICE_QUAD, 		 FWD, 		Cull.Full, 	Dir.Front,	GrowthTypes.HalfSide,	UV_QUAD),
	]),
	# Slope (Flipped)
	Tile.new([
		TileSide.new(PLANE_UP,					INDICE_QUAD, 		 UP, 		Cull.Full, 		Dir.Top,	GrowthTypes.Full,		UV_QUAD_TOP),
		TileSide.new(flip_y(PLANE_SLOPE),		INDICE_QUAD_FLIPPED, DOWN+BACK,	Cull.Empty, 	Dir.Back,	GrowthTypes.None,		UV_QUAD_TOP),
		TileSide.new(flip_y(TRIANGLE_SLOPER),	INDICE_TRI_FLIPPED,  RIGHT, 	Cull.DownTri_1, Dir.Left,	GrowthTypes.SlopeSideR,	UV_TRI),
		TileSide.new(flip_y(TRIANGLE_SLOPEL),	INDICE_TRI,  LEFT, 		Cull.DownTri_2, Dir.Right,	GrowthTypes.SlopeSideL,	flip_u(UV_TRI)),
		TileSide.new(PLANE_FRONT,				INDICE_QUAD,		 FWD, 		Cull.Full, 		Dir.Front,	GrowthTypes.HalfSide,	UV_QUAD),
	]),
	# Slab
	Tile.new([
		TileSide.new(PLANE_UP_HALF,		INDICE_QUAD, UP, 		Cull.Empty, 		Dir.Top,	GrowthTypes.Full,			UV_QUAD_TOP),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD_FLIPPED, DOWN, 		Cull.Full, 			Dir.Bottom,	GrowthTypes.None,			UV_QUAD_TOP),
		TileSide.new(PLANE_RIGHT_HALF,	INDICE_QUAD_FLIPPED, RIGHT, 	Cull.BottomSlab,	Dir.Left,	GrowthTypes.Unconditional,	flip_u(UV_QUAD_HALFV2)),
		TileSide.new(PLANE_LEFT_HALF,	INDICE_QUAD, LEFT, 		Cull.BottomSlab, 	Dir.Right,	GrowthTypes.Unconditional,	UV_QUAD_HALFV2),
		TileSide.new(PLANE_BACK_HALF,	INDICE_QUAD, BACK, 		Cull.BottomSlab, 	Dir.Back,	GrowthTypes.Unconditional,	UV_QUAD_HALFV2),
		TileSide.new(PLANE_FRONT_HALF,	INDICE_QUAD, FWD, 		Cull.BottomSlab, 	Dir.Front,	GrowthTypes.Unconditional,	UV_QUAD_HALFV2),
	]),
	# Slab (Flipped)
	Tile.new([
		TileSide.new(PLANE_UP,					INDICE_QUAD, 		 UP, 	Cull.Full, 		Dir.Top, 	GrowthTypes.Full,		UV_QUAD_TOP),
		TileSide.new(PLANE_UP_HALF,				INDICE_QUAD_FLIPPED, DOWN, 	Cull.Empty, 	Dir.Bottom, GrowthTypes.None,		UV_QUAD_TOP),
		TileSide.new(flip_y(PLANE_RIGHT_HALF),	INDICE_QUAD, 		 RIGHT, Cull.TopSlab, 	Dir.Left, 	GrowthTypes.HalfSide,	flip_u(UV_QUAD_HALFV1)),
		TileSide.new(flip_y(PLANE_LEFT_HALF),	INDICE_QUAD_FLIPPED, LEFT, 	Cull.TopSlab, 	Dir.Right, 	GrowthTypes.HalfSide,	UV_QUAD_HALFV1),
		TileSide.new(flip_y(PLANE_BACK_HALF),	INDICE_QUAD_FLIPPED, BACK, 	Cull.TopSlab, 	Dir.Back, 	GrowthTypes.HalfSide,	UV_QUAD_HALFV1),
		TileSide.new(flip_y(PLANE_FRONT_HALF),	INDICE_QUAD_FLIPPED, FWD, 	Cull.TopSlab, 	Dir.Front, 	GrowthTypes.HalfSide,	UV_QUAD_HALFV1),
	]),
	# Corner
	Tile.new([
		TileSide.new(TRI_CORNER1,		INDICE_TRI,  UP+BACK,	Cull.Empty, 	Dir.Back, 	GrowthTypes.Full,		UV_TRI),
		TileSide.new(TRI_CORNER2,		INDICE_TRI,  UP+LEFT,	Cull.Empty, 	Dir.Right, 	GrowthTypes.Full,		UV_TRI),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, DOWN, 		Cull.Full, 		Dir.Bottom, GrowthTypes.None,		UV_QUAD_TOP),
		TileSide.new(TRI_SLOPER_BACK,	INDICE_TRI,  FWD,	 	Cull.Tri_1, 	Dir.Front, 	GrowthTypes.NormalSide,	UV_TRI),
		TileSide.new(TRIANGLE_SLOPEB,	INDICE_TRI,  RIGHT, 	Cull.Tri_2, 	Dir.Left, 	GrowthTypes.NormalSide,	UV_TRI),
	]),
	# Corner (Flipped)
	Tile.new([
		TileSide.new(flip_y(TRI_CORNER1),		INDICE_TRI_FLIPPED, DOWN+BACK,	Cull.Empty, 	Dir.Back, 	GrowthTypes.Full,		UV_TRI),
		TileSide.new(flip_y(TRI_CORNER2),		INDICE_TRI_FLIPPED, DOWN+LEFT,	Cull.Empty, 	Dir.Left, 	GrowthTypes.Full,		UV_TRI),
		TileSide.new(PLANE_UP,					INDICE_QUAD,UP, 		Cull.Full, 		Dir.Top, 	GrowthTypes.None,				UV_QUAD_TOP),
		TileSide.new(flip_y(TRI_SLOPER_BACK),	INDICE_TRI_FLIPPED, FWD,	 	Cull.DownTri_1, Dir.Front, 	GrowthTypes.NormalSide,	UV_TRI),
		TileSide.new(flip_y(TRIANGLE_SLOPEB),	INDICE_TRI_FLIPPED, RIGHT, 		Cull.DownTri_2, Dir.Right, 	GrowthTypes.NormalSide,	UV_TRI),
	]),
	# Inverted Corner
	Tile.new([
		TileSide.new(TRIANGLE_SLOPEL,			INDICE_TRI_FLIPPED,  			LEFT, 		Cull.Tri_1, Dir.Left, 	GrowthTypes.SlopeSideL,	flip_u(UV_TRI)),
		TileSide.new(shift(TRI_SLOPER_BACK,2,1),INDICE_TRI_FLIPPED,  	BACK, 		Cull.Tri_2, Dir.Back, 	GrowthTypes.SlopeSideL,	UV_TRI),
		TileSide.new(PLANE_DOWN,				INDICE_QUAD,		 	DOWN, 		Cull.Full, 	Dir.Bottom,	GrowthTypes.None,		UV_QUAD_TOP),
		TileSide.new(PLANE_RIGHT,				INDICE_QUAD,			RIGHT, 		Cull.Full, 	Dir.Right, 	GrowthTypes.NormalSide,	UV_QUAD_INVERSE),
		TileSide.new(TRI_INVERT1,				INDICE_TRI, 			LEFT+UP, 	Cull.Empty, Dir.Top, 	GrowthTypes.NormalSide,	UV_TRI),
		TileSide.new(TRI_INVERT2,				INDICE_TRI, 			BACK+UP, 	Cull.Empty, Dir.Top, 	GrowthTypes.NormalSide,	UV_TRI),
		TileSide.new(PLANE_FRONT,				INDICE_QUAD, 			FWD, 		Cull.Full, 	Dir.Front, 	GrowthTypes.NormalSide,	UV_QUAD),
	]),
	# Inverted Corner (Flipped)
	Tile.new([
		TileSide.new(flip_y(TRIANGLE_SLOPEL),			INDICE_TRI, LEFT, 		Cull.DownTri_1,	Dir.Left, 	GrowthTypes.SlopeSideL,		flip_u(UV_TRI)),
		TileSide.new(flip_y(shift(TRI_SLOPER_BACK,2,1)),INDICE_TRI,  		BACK, 		Cull.DownTri_2,	Dir.Back, 	GrowthTypes.SlopeSideL,		UV_TRI),
		TileSide.new(PLANE_UP,							INDICE_QUAD,UP, 				Cull.Full, 		Dir.Top, GrowthTypes.None,			UV_QUAD_TOP),
		TileSide.new(PLANE_RIGHT,						INDICE_QUAD,		RIGHT, 		Cull.Full, 		Dir.Right, 	GrowthTypes.NormalSide,		UV_QUAD_INVERSE),
		TileSide.new(flip_y(TRI_INVERT1),				INDICE_TRI_FLIPPED, LEFT+DOWN, 	Cull.Empty, 	Dir.Bottom, 	GrowthTypes.NormalSide,		UV_TRI),
		TileSide.new(flip_y(TRI_INVERT2),				INDICE_TRI_FLIPPED, BACK+DOWN, 	Cull.Empty, 	Dir.Bottom, 	GrowthTypes.NormalSide,		UV_TRI),
		TileSide.new(PLANE_FRONT,						INDICE_QUAD, 		FWD, 		Cull.Full, 		Dir.Front, 	GrowthTypes.NormalSide,		UV_QUAD),
	]),
	# Sloped Corner
	Tile.new([
		TileSide.new(TRIANGLE_SLOPER,		INDICE_TRI,			RIGHT, 				Cull.Tri_1, Dir.Left, 	GrowthTypes.SlopeSideR,		UV_TRI),
		TileSide.new(TRIANGLE_SLOPEF,		INDICE_TRI, 		FWD, 				Cull.Tri_2, Dir.Front, 	GrowthTypes.SlopeSideL,		UV_TRI),
		TileSide.new(TRI_CORNER_SLOPE,		INDICE_TRI,			BACK/2+LEFT/2+UP,	Cull.Empty,	Dir.Top, 	GrowthTypes.NormalSide,		UV_TRI),
		TileSide.new(flip_y(TRI_TOP),		INDICE_TRI_FLIPPED, DOWN, 				Cull.TopTri,Dir.Bottom, GrowthTypes.None,			UV_TRI_TOP),
	]),
	# Sloped Corner (Flipped)
	Tile.new([
		TileSide.new(flip_y(TRIANGLE_SLOPER),	INDICE_TRI_FLIPPED,	RIGHT, 				Cull.DownTri_1, Dir.Left,	GrowthTypes.NormalSide,		UV_TRI),
		TileSide.new(flip_y(TRIANGLE_SLOPEF),	INDICE_TRI_FLIPPED, FWD, 				Cull.DownTri_2, Dir.Front,	GrowthTypes.NormalSide,		UV_TRI),
		TileSide.new(flip_y(TRI_CORNER_SLOPE),	INDICE_TRI_FLIPPED,	BACK/2+LEFT/2+DOWN, Cull.Empty, 	Dir.Back,	GrowthTypes.DiagonalSide,	[Vector2(0,1),Vector2(1,0),Vector2(0,0)]),
		TileSide.new(TRI_TOP,					INDICE_TRI, 		UP, 				Cull.TopTri,	Dir.Top, 	GrowthTypes.Full,			UV_TRI_TOP),
	]),
	# Upper Gentle Slope
	Tile.new([
		TileSide.new(PLANE_RIGHT_HALF,				INDICE_QUAD_FLIPPED, RIGHT, 	Cull.BottomSlab, 			Dir.Left, 	GrowthTypes.HalfSide,		flip_u(UV_QUAD_HALFV2)),
		TileSide.new(PLANE_LEFT_HALF,				INDICE_QUAD, 		 LEFT, 		Cull.BottomSlab, 			Dir.Right, 	GrowthTypes.HalfSide,		UV_QUAD_HALFV2),
		TileSide.new(PLANE_BACK_HALF,				INDICE_QUAD, 		 BACK, 		Cull.BottomSlab, 			Dir.Back, 	GrowthTypes.HalfSide,		UV_QUAD_HALFV2),
		TileSide.new(maxv(PLANE_SLOPE,1,0.5),		INDICE_QUAD,		 UP+BACK,	Cull.Empty, 				Dir.Top, 	GrowthTypes.Full,			UV_QUAD_SLOPE),
		TileSide.new(PLANE_DOWN,					INDICE_QUAD, 		 DOWN, 		Cull.Full, 					Dir.Bottom,	GrowthTypes.None,			UV_QUAD_TOP),
		TileSide.new(maxv(TRIANGLE_SLOPER,1,0.5),	INDICE_TRI,  		 RIGHT, 	Cull.UpperGentle_1, 		Dir.Left, 	GrowthTypes.SlopeSideR,		UV_TRI_HALFV1),
		TileSide.new(maxv(TRIANGLE_SLOPEL,1,0.5),	INDICE_TRI_FLIPPED,  		 LEFT, 		Cull.UpperGentle_2, 		Dir.Right, 	GrowthTypes.SlopeSideL,		flip_u(UV_TRI_HALFV1)),
		TileSide.new(PLANE_FRONT,					INDICE_QUAD, 		 FWD, 		Cull.Full, 					Dir.Front, 	GrowthTypes.HalfSide,		UV_QUAD),
	]),
	# Upper Gentle Slope (Flipped)
	Tile.new([
		TileSide.new(flip_y(PLANE_RIGHT_HALF),				INDICE_QUAD,		 RIGHT, 	Cull.TopSlab, 		Dir.Left, 	GrowthTypes.HalfSide,		flip_u(UV_QUAD_HALFV1)),
		TileSide.new(flip_y(PLANE_LEFT_HALF),				INDICE_QUAD_FLIPPED, LEFT, 		Cull.TopSlab, 		Dir.Right, 	GrowthTypes.HalfSide,		UV_QUAD_HALFV1),
		TileSide.new(flip_y(PLANE_BACK_HALF),				INDICE_QUAD_FLIPPED, BACK, 		Cull.TopSlab, 		Dir.Back, 	GrowthTypes.HalfSide,		UV_QUAD_HALFV1),
		TileSide.new(flip_y(maxv(PLANE_SLOPE,1,0.5)),		INDICE_QUAD_FLIPPED, DOWN+BACK,	Cull.Empty, 		Dir.Bottom,	GrowthTypes.None,			UV_QUAD_SLOPE),
		TileSide.new(PLANE_UP,								INDICE_QUAD, UP, 		Cull.Full, 			Dir.Top,	GrowthTypes.Full,					UV_QUAD_TOP),
		TileSide.new(flip_y(maxv(TRIANGLE_SLOPER,1,0.5)),	INDICE_TRI_FLIPPED,	 RIGHT, 	Cull.LowerGentle_1, Dir.Left, 	GrowthTypes.SlopeSideR,		[Vector2(0,.5),Vector2(0,1),Vector2(1,.5)]),
		TileSide.new(flip_y(maxv(TRIANGLE_SLOPEL,1,0.5)),	INDICE_TRI,  LEFT, 		Cull.LowerGentle_2, Dir.Right, 	GrowthTypes.SlopeSideL,				flip_u([Vector2(0,.5),Vector2(0,1),Vector2(1,.5)])),
		TileSide.new(PLANE_FRONT,							INDICE_QUAD, 		 FWD, 		Cull.Full, 			Dir.Front, 	GrowthTypes.HalfSide,		UV_QUAD),
	]),
	# Lower Gentle Slope
	Tile.new([
		TileSide.new(minv(PLANE_SLOPE,1,0.5),		INDICE_QUAD,		 UP+BACK,	Cull.Empty, Dir.Top, 	GrowthTypes.Full,				UV_QUAD_SLOPE),
		TileSide.new(PLANE_DOWN,					INDICE_QUAD, 		 DOWN, 		Cull.Full, Dir.Bottom,	GrowthTypes.None,				UV_QUAD_TOP),
		TileSide.new(minv(TRIANGLE_SLOPER,1,0.5),	INDICE_TRI,  		 RIGHT, 	Cull.LowerGentle_2, Dir.Left, GrowthTypes.SlopeSideL,	UV_TRI_HALFV2),
		TileSide.new(minv(TRIANGLE_SLOPEL,1,0.5),	INDICE_TRI_FLIPPED,  		 LEFT, 		Cull.LowerGentle_1, Dir.Right, GrowthTypes.SlopeSideR,	flip_u(UV_TRI_HALFV2)),
		TileSide.new(PLANE_FRONT_HALF,				INDICE_QUAD, 		 FWD, 		Cull.BottomSlab, Dir.Front, GrowthTypes.Unconditional,	UV_QUAD_HALFV2),
	]),
	# Lower Gentle Slope (Flipped)
	Tile.new([
		TileSide.new(flip_y(minv(PLANE_SLOPE,1,0.5)),		INDICE_QUAD_FLIPPED, DOWN+BACK,	Cull.Empty, Dir.Bottom, 		GrowthTypes.Full,			UV_QUAD_SLOPE),
		TileSide.new(PLANE_UP,								INDICE_QUAD, UP, 		Cull.Full, Dir.Top, 			GrowthTypes.None,					UV_QUAD_TOP),
		TileSide.new(flip_y(minv(TRIANGLE_SLOPER,1,0.5)),	INDICE_TRI_FLIPPED,	 RIGHT, 	Cull.UpperGentle_2, Dir.Left, 	GrowthTypes.SlopeSideR,		[Vector2(0,0),Vector2(0,.5),Vector2(1,0)]),
		TileSide.new(flip_y(minv(TRIANGLE_SLOPEL,1,0.5)),	INDICE_TRI,  LEFT, 		Cull.UpperGentle_1, Dir.Right, 	GrowthTypes.SlopeSideL,				flip_u([Vector2(0,0),Vector2(0,.5),Vector2(1,0)])),
		TileSide.new(flip_y(PLANE_FRONT_HALF),				INDICE_QUAD_FLIPPED, FWD, 		Cull.TopSlab, Dir.Front, 		GrowthTypes.HalfSide,		UV_QUAD_HALFV2),
	]),
	# Block
	Tile.new([
		TileSide.new(PLANE_UP,			INDICE_QUAD, UP, 		Cull.Full, Dir.Top, GrowthTypes.Full,			UV_QUAD_TOP),
		TileSide.new(PLANE_DOWN,INDICE_QUAD_FLIPPED, DOWN, 		Cull.Full, Dir.Bottom, GrowthTypes.None,		UV_QUAD_TOP),
		TileSide.new(PLANE_RIGHT,		INDICE_QUAD, RIGHT, 	Cull.Full, Dir.Left, GrowthTypes.NormalSide,	UV_QUAD_INVERSE),
		TileSide.new(PLANE_LEFT,		INDICE_QUAD, LEFT, 		Cull.Full, Dir.Right, GrowthTypes.NormalSide,	UV_QUAD),
		TileSide.new(PLANE_BACK,		INDICE_QUAD, BACK, 		Cull.Full, Dir.Back, GrowthTypes.NormalSide,	UV_QUAD),
		TileSide.new(PLANE_FRONT,		INDICE_QUAD, FWD, 		Cull.Full, Dir.Front, GrowthTypes.NormalSide,	UV_QUAD),
	]),
	# Sideways Slope
	Tile.new([
		TileSide.new(TRI_TOP,					INDICE_TRI,  			UP, 		Cull.TopTri, Dir.Top, GrowthTypes.Full,				UV_TRI_TOP),
		TileSide.new(flip_y(TRI_TOP),			INDICE_TRI_FLIPPED, 	DOWN, 		Cull.TopTri, Dir.Bottom, GrowthTypes.None,			UV_TRI_TOP),
		TileSide.new(PLANE_RIGHT,				INDICE_QUAD,			RIGHT, 		Cull.Full, Dir.Left, GrowthTypes.NormalSide,		UV_QUAD_INVERSE),
		TileSide.new(PLANE_VSLOPE,				INDICE_QUAD, 			LEFT+BACK, 	Cull.Empty, Dir.Right, GrowthTypes.DiagonalSide,	UV_QUAD_INVERSE),
		TileSide.new(PLANE_FRONT,				INDICE_QUAD, 			FWD, 		Cull.Full, Dir.Front, GrowthTypes.NormalSide,		UV_QUAD),
	]),
	# Vertical Slab
	Tile.new([
		TileSide.new(minv(PLANE_UP,2,0.5),			INDICE_QUAD, UP, 		Cull.TopHalf, Dir.Top, GrowthTypes.Full,			UV_QUAD_HALFV1),
		TileSide.new(minv(PLANE_DOWN,2,0.5),		INDICE_QUAD, DOWN, 		Cull.TopHalf, Dir.Bottom, GrowthTypes.None,			UV_QUAD_HALFV1),
		TileSide.new(minv(PLANE_RIGHT,2,0.5),		INDICE_QUAD, RIGHT, 	Cull.HalfSide_1, Dir.Left, GrowthTypes.NormalSide, 	UV_QUAD_HALFH),
		TileSide.new(minv(PLANE_LEFT,2,0.5),		INDICE_QUAD, LEFT, 		Cull.HalfSide_2, Dir.Right, GrowthTypes.NormalSide,	UV_QUAD_HALFH),
		TileSide.new(shift(PLANE_BACK,2,-0.5),		INDICE_QUAD, BACK, 		Cull.Empty, Dir.Back, GrowthTypes.NormalSide,		UV_QUAD),
		TileSide.new(PLANE_FRONT,					INDICE_QUAD, FWD, 		Cull.Full, Dir.Front, GrowthTypes.NormalSide, 		UV_QUAD),
	]),
	# Cull
	Tile.new([
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Top, GrowthTypes.None,		[]),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Bottom, GrowthTypes.None,	[]),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Left, GrowthTypes.None,		[]),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Right, GrowthTypes.None,		[]),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Back, GrowthTypes.None,		[]),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Front, GrowthTypes.None,		[]),
	]),
	# Troll Block
	null,
	# Fence
	Tile.new([
		TileSide.new(PLANE_FRONT_HALF,	INDICE_QUAD, FWD, 		Cull.Empty, Dir.Front, GrowthTypes.None, [Vector2(2,1),Vector2(0,1),Vector2(0,0),Vector2(2,0)]),
	]),
	# Pole
	null,
	# Bars
	null,
	# Water
	null
	
]

## Mesh Shortcuts
const PLANE_UP			: PackedVector3Array = [Vector3(0,1,1),Vector3(0,1,0),Vector3(1,1,0),Vector3(1,1,1)]
const PLANE_DOWN		: PackedVector3Array = [Vector3(0,0,1),Vector3(0,0,0),Vector3(1,0,0),Vector3(1,0,1)]
const PLANE_LEFT		: PackedVector3Array = [Vector3(1,0,0),Vector3(1,0,1),Vector3(1,1,1),Vector3(1,1,0)]
const PLANE_RIGHT		: PackedVector3Array = [Vector3(0,0,0),Vector3(0,1,0),Vector3(0,1,1),Vector3(0,0,1)]
const PLANE_BACK		: PackedVector3Array = [Vector3(1,0,1),Vector3(0,0,1),Vector3(0,1,1),Vector3(1,1,1)]
const PLANE_FRONT		: PackedVector3Array = [Vector3(0,0,0),Vector3(1,0,0),Vector3(1,1,0),Vector3(0,1,0)]

const PLANE_UP_HALF		: PackedVector3Array = [Vector3(0,.5,1),Vector3(0,.5,0),Vector3(1,.5,0),Vector3(1,.5,1)]
const PLANE_LEFT_HALF	: PackedVector3Array = [Vector3(1,0,0),Vector3(1,0,1),Vector3(1,.5,1),Vector3(1,.5,0)]
const PLANE_RIGHT_HALF	: PackedVector3Array = [Vector3(0,0,0),Vector3(0,0,1),Vector3(0,.5,1),Vector3(0,.5,0)]
const PLANE_BACK_HALF	: PackedVector3Array = [Vector3(1,0,1),Vector3(0,0,1),Vector3(0,.5,1),Vector3(1,.5,1)]
const PLANE_FRONT_HALF	: PackedVector3Array = [Vector3(0,0,0),Vector3(1,0,0),Vector3(1,.5,0),Vector3(0,.5,0)]

const PLANE_SLOPE		: PackedVector3Array = [Vector3(0,1,0),Vector3(1,1,0),Vector3(1,0,1),Vector3(0,0,1)]
const PLANE_VSLOPE		: PackedVector3Array = [Vector3(0,0,1),Vector3(0,1,1),Vector3(1,1,0),Vector3(1,0,0)]
const TRIANGLE_SLOPER	: PackedVector3Array = [Vector3(0,0,0),Vector3(0,1,0),Vector3(0,0,1)]
const TRIANGLE_SLOPEL	: PackedVector3Array = [Vector3(1,0,0),Vector3(1,1,0),Vector3(1,0,1)]
const TRIANGLE_SLOPEF	: PackedVector3Array = [Vector3(0,0,0),Vector3(1,0,0),Vector3(0,1,0)]
const TRIANGLE_SLOPEB	: PackedVector3Array = [Vector3(0,0,1),Vector3(0,0,0),Vector3(0,1,0)]

const TRI_SLOPER_BACK	: PackedVector3Array = [Vector3(0,1,0),Vector3(0,0,0),Vector3(1,0,0)]
const TRI_CORNER1		: PackedVector3Array = [Vector3(1,0,1),Vector3(0,0,1),Vector3(0,1,0)]
const TRI_CORNER2		: PackedVector3Array = [Vector3(1,0,1),Vector3(0,1,0),Vector3(1,0,0)]
const TRI_TOP			: PackedVector3Array = [Vector3(0,1,1),Vector3(0,1,0),Vector3(1,1,0)]

const TRI_INVERT1		: PackedVector3Array = [Vector3(1,0,1),Vector3(0,1,1),Vector3(0,1,0)]
const TRI_INVERT2		: PackedVector3Array = [Vector3(1,0,1),Vector3(0,1,0),Vector3(1,1,0)]

const TRI_CORNER_SLOPE	: PackedVector3Array = [Vector3(0,1,0),Vector3(1,0,0),Vector3(0,0,1)]

## Flips Y coordinate in set of vertices
func flip_y(verts : PackedVector3Array) -> PackedVector3Array:
	var new := PackedVector3Array()
	for vtx in verts:
		# Cursed
		vtx.y = (1 if vtx.y == 0 else 0) if vtx.y == 0 || vtx.y == 1 else vtx.y
		new.append(vtx)
	return new

## Shifts axis by count in set of vertices
func shift(verts : PackedVector3Array, axis : int, count : float) -> PackedVector3Array:
	var new := PackedVector3Array()
	for vtx in verts:
		match axis:
			0:	vtx.x += count
			1:	vtx.y += count
			2:	vtx.z += count
		new.append(vtx)
	return new

## Clamps axis by minimum count in set of vertices
func minv(verts : PackedVector3Array, axis : int, maximum : float) -> PackedVector3Array:
	var new := PackedVector3Array()
	for vtx in verts:
		match axis:
			0:	vtx.x = min(vtx.x, maximum)
			1:	vtx.y = min(vtx.y, maximum)
			2:	vtx.z = min(vtx.z, maximum)
		new.append(vtx)
	return new

## Clamps axis by maximum count in set of vertices
func maxv(verts : PackedVector3Array, axis : int, minimum : float) -> PackedVector3Array:
	var new := PackedVector3Array()
	for vtx in verts:
		match axis:
			0:	vtx.x = max(vtx.x, minimum)
			1:	vtx.y = max(vtx.y, minimum)
			2:	vtx.z = max(vtx.z, minimum)
		new.append(vtx)
	return new

## Calculates normal based on provided triangle points
func tri_to_normal(points : PackedVector3Array) -> Vector3:
	var a = points[1] - points[0]
	var b = points[2] - points[0]
	return Vector3(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	)


## Block indices
const INDICE_QUAD 			: PackedInt32Array = [0,1,2,0,2,3]
const INDICE_TRI  			: PackedInt32Array = [0,1,2]
const INDICE_QUAD_FLIPPED	: PackedInt32Array = [3,2,0,2,1,0]
const INDICE_TRI_FLIPPED	: PackedInt32Array = [2,1,0]

## UV
const UV_QUAD 			: PackedVector2Array = [Vector2(1,1),Vector2(0,1),Vector2(0,0),Vector2(1,0)]
const UV_QUAD_TOP 		: PackedVector2Array = [Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)]
const UV_QUAD_SLOPE		: PackedVector2Array = [Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1)]
const UV_QUAD_INVERSE 	: PackedVector2Array = [Vector2(0,1),Vector2(0,0),Vector2(1,0),Vector2(1,1)]
const UV_QUAD_HALFH		: PackedVector2Array = [Vector2(.5,1),Vector2(0,1),Vector2(0,0),Vector2(.5,0)]
const UV_QUAD_HALFV1 	: PackedVector2Array = [Vector2(1,0),Vector2(0,0),Vector2(0,.5),Vector2(1,.5)]
const UV_QUAD_HALFV2	: PackedVector2Array = [Vector2(1,1),Vector2(0,1),Vector2(0,.5),Vector2(1,.5)]
const UV_TRI 			: PackedVector2Array = [Vector2(1,1),Vector2(1,0),Vector2(0,1)]
const UV_TRI_HALFV1		: PackedVector2Array = [Vector2(0,.5),Vector2(0,0),Vector2(1,.5)]
const UV_TRI_HALFV2		: PackedVector2Array = [Vector2(0,1),Vector2(0,.5),Vector2(1,1)]
const UV_TRI_TOP 		: PackedVector2Array = [Vector2(0,1),Vector2(1,1),Vector2(1,0)]

## Flips u coordinate in set of uv coords
func flip_u(uvs : PackedVector2Array) -> PackedVector2Array:
	var new := PackedVector2Array()
	for uv in uvs:
		# Cursed
		uv.x = (1 if uv.x == 0 else 0) if uv.x == 0 || uv.x == 1 else uv.x
		new.append(uv)
	return new

## Flips v coordinate in set of uv coords
func flip_v(uvs : PackedVector2Array) -> PackedVector2Array:
	var new := PackedVector2Array()
	for uv in uvs:
		# Cursed
		uv.y = (1 if uv.y == 0 else 0) if uv.y == 0 || uv.y == 1 else uv.y
		new.append(uv)
	return new
