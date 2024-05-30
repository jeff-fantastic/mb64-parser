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
	var alt_uv : Array[Vector2]
	func _init(p_mesh : PackedVector3Array, p_ind : PackedInt32Array, p_normal : Vector3, 
	p_cullid : int, p_dir : Dir, p_growth : GrowthTypes, p_alt_uv : Array[Vector2] = []) -> void:
		self.mesh = p_mesh
		self.indices = p_ind
		self.normal = p_normal
		self.dir = p_dir
		self.cullid = p_cullid
		self.growth = p_growth
		self.alt_uv = p_alt_uv

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
		TileSide.new(PLANE_SLOPE,		INDICE_QUAD,		 UP+BACK,	Cull.Empty, Dir.Top,		GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, 		 DOWN, 		Cull.Full, Dir.Bottom,		GrowthTypes.None),
		TileSide.new(TRIANGLE_SLOPER,	INDICE_TRI,  		 RIGHT, 	Cull.Tri_1, Dir.Left,		GrowthTypes.SlopeSideR),
		TileSide.new(TRIANGLE_SLOPEL,	INDICE_TRI,  		 LEFT, 		Cull.Tri_2, Dir.Right,		GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_FRONT,		INDICE_QUAD, 		 FWD, 		Cull.Full, Dir.Front,		GrowthTypes.HalfSide),
	]),
	# Slope (Flipped)
	Tile.new([
		TileSide.new(PLANE_UP,					INDICE_QUAD, 		 UP, 		Cull.Full, Dir.Top,	GrowthTypes.Full),
		TileSide.new(flip_y(PLANE_SLOPE),		INDICE_QUAD_FLIPPED, DOWN+BACK,	Cull.Empty, Dir.Bottom,	GrowthTypes.None),
		TileSide.new(flip_y(TRIANGLE_SLOPER),	INDICE_TRI_FLIPPED,  RIGHT, 	Cull.DownTri_1, Dir.Left,	GrowthTypes.SlopeSideR),
		TileSide.new(flip_y(TRIANGLE_SLOPEL),	INDICE_TRI_FLIPPED,  LEFT, 		Cull.DownTri_2, Dir.Right,	GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_FRONT,				INDICE_QUAD,		 FWD, 		Cull.Full, Dir.Front,	GrowthTypes.HalfSide),
	]),
	# Slab
	Tile.new([
		TileSide.new(PLANE_UP_HALF,		INDICE_QUAD, UP, 		Cull.Empty, Dir.Top,	GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, DOWN, 		Cull.Full, Dir.Bottom,	GrowthTypes.None),
		TileSide.new(PLANE_RIGHT_HALF,	INDICE_QUAD, RIGHT, 	Cull.BottomSlab,	Dir.Left,	GrowthTypes.Unconditional),
		TileSide.new(PLANE_LEFT_HALF,	INDICE_QUAD, LEFT, 		Cull.BottomSlab, 	Dir.Right,	GrowthTypes.Unconditional),
		TileSide.new(PLANE_BACK_HALF,	INDICE_QUAD, BACK, 		Cull.BottomSlab, 	Dir.Back,	GrowthTypes.Unconditional),
		TileSide.new(PLANE_FRONT_HALF,	INDICE_QUAD, FWD, 		Cull.BottomSlab, 	Dir.Front,	GrowthTypes.Unconditional),
	]),
	# Slab (Flipped)
	Tile.new([
		TileSide.new(PLANE_UP,					INDICE_QUAD,		 UP, 	Cull.Full, Dir.Top, GrowthTypes.Full),
		TileSide.new(PLANE_UP_HALF,				INDICE_QUAD_FLIPPED, DOWN, 	Cull.Empty, Dir.Bottom, GrowthTypes.None),
		TileSide.new(flip_y(PLANE_RIGHT_HALF),	INDICE_QUAD_FLIPPED, RIGHT, Cull.TopSlab, Dir.Left, GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_LEFT_HALF),	INDICE_QUAD_FLIPPED, LEFT, 	Cull.TopSlab, Dir.Right, GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_BACK_HALF),	INDICE_QUAD_FLIPPED, BACK, 	Cull.TopSlab, Dir.Back, GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_FRONT_HALF),	INDICE_QUAD_FLIPPED, FWD, 	Cull.TopSlab, Dir.Front, GrowthTypes.HalfSide),
	]),
	# Corner
	Tile.new([
		TileSide.new(TRI_CORNER1,		INDICE_TRI,  UP+BACK,	Cull.Empty, Dir.Back, GrowthTypes.Full),
		TileSide.new(TRI_CORNER2,		INDICE_TRI,  UP+LEFT,	Cull.Empty, Dir.Right, GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, DOWN, 		Cull.Full, Dir.Bottom, GrowthTypes.None),
		TileSide.new(TRI_SLOPER_BACK,	INDICE_TRI,  FWD,	 	Cull.Tri_1, 	Dir.Front, GrowthTypes.NormalSide),
		TileSide.new(TRIANGLE_SLOPEB,	INDICE_TRI,  RIGHT, 	Cull.Tri_2, 	Dir.Left, GrowthTypes.NormalSide),
	]),
	# Corner (Flipped)
	Tile.new([
		TileSide.new(flip_y(TRI_CORNER1),		INDICE_TRI_FLIPPED, DOWN+BACK,	Cull.Empty, Dir.Back, GrowthTypes.Full),
		TileSide.new(flip_y(TRI_CORNER2),		INDICE_TRI_FLIPPED, DOWN+LEFT,	Cull.Empty, Dir.Left, GrowthTypes.Full),
		TileSide.new(PLANE_UP,					INDICE_QUAD, 		UP, 		Cull.Full, Dir.Top, GrowthTypes.None),
		TileSide.new(flip_y(TRI_SLOPER_BACK),	INDICE_TRI_FLIPPED, FWD,	 	Cull.DownTri_1, Dir.Front, GrowthTypes.NormalSide),
		TileSide.new(flip_y(TRIANGLE_SLOPEB),	INDICE_TRI_FLIPPED, RIGHT, 		Cull.DownTri_2,  Dir.Right, GrowthTypes.NormalSide),
	]),
	# Inverted Corner
	Tile.new([
		TileSide.new(TRIANGLE_SLOPEL,			INDICE_TRI,  			LEFT, 		Cull.Tri_1, Dir.Left, 	GrowthTypes.SlopeSideL),
		TileSide.new(shift(TRI_SLOPER_BACK,2,1),INDICE_TRI_FLIPPED,  	BACK, 		Cull.Tri_2, Dir.Back, 	GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_DOWN,				INDICE_QUAD,		 	DOWN, 		Cull.Full, Dir.Bottom,	GrowthTypes.None),
		TileSide.new(PLANE_RIGHT,				INDICE_QUAD,			RIGHT, 		Cull.Full, Dir.Right, 	GrowthTypes.NormalSide),
		TileSide.new(TRI_INVERT1,				INDICE_TRI, 			LEFT+UP, 	Cull.Empty, Dir.Top, 	GrowthTypes.NormalSide),
		TileSide.new(TRI_INVERT2,				INDICE_TRI, 			BACK+UP, 	Cull.Empty, Dir.Top, 	GrowthTypes.NormalSide),
		TileSide.new(PLANE_FRONT,				INDICE_QUAD, 			FWD, 		Cull.Full, Dir.Front, 	GrowthTypes.NormalSide),
	]),
	# Inverted Corner (Flipped)
	Tile.new([
		TileSide.new(flip_y(TRIANGLE_SLOPEL),			INDICE_TRI_FLIPPED, LEFT, 		Cull.DownTri_1,	Dir.Left, 	GrowthTypes.SlopeSideL),
		TileSide.new(flip_y(shift(TRI_SLOPER_BACK,2,1)),INDICE_TRI,  		BACK, 		Cull.DownTri_2,	Dir.Back, 	GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_UP,							INDICE_QUAD,		UP, 		Cull.Full, Dir.Bottom, GrowthTypes.None),
		TileSide.new(PLANE_RIGHT,						INDICE_QUAD,		RIGHT, 		Cull.Full, Dir.Right, 	GrowthTypes.NormalSide),
		TileSide.new(flip_y(TRI_INVERT1),				INDICE_TRI_FLIPPED, LEFT+DOWN, 	Cull.Empty, Dir.Top, 	GrowthTypes.NormalSide),
		TileSide.new(flip_y(TRI_INVERT2),				INDICE_TRI_FLIPPED, BACK+DOWN, 	Cull.Empty, Dir.Top, 	GrowthTypes.NormalSide),
		TileSide.new(PLANE_FRONT,						INDICE_QUAD, 		FWD, 		Cull.Full, Dir.Front, 	GrowthTypes.NormalSide),
	]),
	# Sloped Corner
	Tile.new([
		TileSide.new(TRIANGLE_SLOPER,		INDICE_TRI,			RIGHT, 				Cull.Tri_1, Dir.Right, 	GrowthTypes.SlopeSideR),
		TileSide.new(TRIANGLE_SLOPEF,		INDICE_TRI, 		FWD, 				Cull.Tri_2, Dir.Front, 	GrowthTypes.SlopeSideL),
		TileSide.new(TRI_CORNER_SLOPE,		INDICE_TRI,			BACK/2+LEFT/2+UP,	Cull.Empty,Dir.Top, 	GrowthTypes.NormalSide),
		TileSide.new(flip_y(TRI_TOP),		INDICE_TRI_FLIPPED, DOWN, 				Cull.TopTri,Dir.Bottom, GrowthTypes.None),
	]),
	# Sloped Corner (Flipped)
	Tile.new([
		TileSide.new(flip_y(TRIANGLE_SLOPER),	INDICE_TRI_FLIPPED,	RIGHT, 				Cull.DownTri_1, Dir.Right, GrowthTypes.NormalSide),
		TileSide.new(flip_y(TRIANGLE_SLOPEF),	INDICE_TRI_FLIPPED, FWD, 				Cull.DownTri_2, Dir.Front, GrowthTypes.NormalSide),
		TileSide.new(flip_y(TRI_CORNER_SLOPE),	INDICE_TRI_FLIPPED,	BACK/2+LEFT/2+DOWN, Cull.Empty, Dir.Bottom, GrowthTypes.DiagonalSide),
		TileSide.new(TRI_TOP,					INDICE_TRI, 		UP, 				Cull.TopTri, Dir.Top, GrowthTypes.Full),
	]),
	# Upper Gentle Slope
	Tile.new([
		TileSide.new(PLANE_RIGHT_HALF,				INDICE_QUAD, 		 RIGHT, 	Cull.BottomSlab, 	Dir.Left, 	GrowthTypes.HalfSide),
		TileSide.new(PLANE_LEFT_HALF,				INDICE_QUAD, 		 LEFT, 		Cull.BottomSlab, 	Dir.Right, 	GrowthTypes.HalfSide),
		TileSide.new(PLANE_BACK_HALF,				INDICE_QUAD, 		 BACK, 		Cull.BottomSlab, 	Dir.Back, 	GrowthTypes.HalfSide),
		TileSide.new(maxv(PLANE_SLOPE,1,0.5),		INDICE_QUAD,		 UP+BACK,	Cull.Empty, Dir.Back, 	GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,					INDICE_QUAD, 		 DOWN, 		Cull.Full, Dir.Bottom,	GrowthTypes.None),
		TileSide.new(maxv(TRIANGLE_SLOPER,1,0.5),	INDICE_TRI,  		 RIGHT, 	Cull.UpperGentle_1, Dir.Left, 	GrowthTypes.SlopeSideR),
		TileSide.new(maxv(TRIANGLE_SLOPEL,1,0.5),	INDICE_TRI,  		 LEFT, 		Cull.UpperGentle_2, Dir.Right, 	GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_FRONT,					INDICE_QUAD, 		 FWD, 		Cull.Full, Dir.Front, 	GrowthTypes.HalfSide),
	]),
	# Upper Gentle Slope (Flipped)
	Tile.new([
		TileSide.new(flip_y(PLANE_RIGHT_HALF),				INDICE_QUAD_FLIPPED, RIGHT, 	Cull.TopSlab, Dir.Left, 	GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_LEFT_HALF),				INDICE_QUAD_FLIPPED, LEFT, 		Cull.TopSlab, Dir.Right, 	GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_BACK_HALF),				INDICE_QUAD_FLIPPED, BACK, 		Cull.TopSlab, Dir.Back, 	GrowthTypes.HalfSide),
		TileSide.new(flip_y(maxv(PLANE_SLOPE,1,0.5)),		INDICE_QUAD_FLIPPED, DOWN+BACK,	Cull.Empty, Dir.Back,	GrowthTypes.Full),
		TileSide.new(PLANE_UP,								INDICE_QUAD, 		 UP, 		Cull.Full, Dir.Top,	GrowthTypes.None),
		TileSide.new(flip_y(maxv(TRIANGLE_SLOPER,1,0.5)),	INDICE_TRI_FLIPPED,	 RIGHT, 	Cull.LowerGentle_1, 	Dir.Left, GrowthTypes.SlopeSideR),
		TileSide.new(flip_y(maxv(TRIANGLE_SLOPEL,1,0.5)),	INDICE_TRI_FLIPPED,  LEFT, 		Cull.LowerGentle_2, 	Dir.Right, GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_FRONT,							INDICE_QUAD, 		 FWD, 		Cull.Full, Dir.Front, 	GrowthTypes.HalfSide),
	]),
	# Lower Gentle Slope
	Tile.new([
		TileSide.new(minv(PLANE_SLOPE,1,0.5),		INDICE_QUAD,		 UP+BACK,	Cull.Empty, Dir.Top, 	GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,					INDICE_QUAD, 		 DOWN, 		Cull.Full, Dir.Bottom,	GrowthTypes.None),
		TileSide.new(minv(TRIANGLE_SLOPER,1,0.5),	INDICE_TRI,  		 RIGHT, 	Cull.LowerGentle_2, Dir.Left, GrowthTypes.SlopeSideL),
		TileSide.new(minv(TRIANGLE_SLOPEL,1,0.5),	INDICE_TRI,  		 LEFT, 		Cull.LowerGentle_1, Dir.Right, GrowthTypes.SlopeSideR),
		TileSide.new(PLANE_FRONT_HALF,				INDICE_QUAD, 		 FWD, 		Cull.BottomSlab, Dir.Front, GrowthTypes.Unconditional),
	]),
	# Lower Gentle Slope (Flipped)
	Tile.new([
		TileSide.new(flip_y(minv(PLANE_SLOPE,1,0.5)),		INDICE_QUAD_FLIPPED, DOWN+BACK,	Cull.Empty, Dir.Bottom, 	GrowthTypes.Full),
		TileSide.new(PLANE_UP,								INDICE_QUAD, 		 UP, 		Cull.Full, Dir.Top, 	GrowthTypes.None),
		TileSide.new(flip_y(minv(TRIANGLE_SLOPER,1,0.5)),	INDICE_TRI_FLIPPED,	 RIGHT, 	Cull.UpperGentle_2, Dir.Left, 	GrowthTypes.SlopeSideR),
		TileSide.new(flip_y(minv(TRIANGLE_SLOPEL,1,0.5)),	INDICE_TRI_FLIPPED,  LEFT, 		Cull.UpperGentle_1, Dir.Right, 	GrowthTypes.SlopeSideL),
		TileSide.new(flip_y(PLANE_FRONT_HALF),				INDICE_QUAD_FLIPPED, FWD, 		Cull.TopSlab, Dir.Front, 	GrowthTypes.HalfSide),
	]),
	# Block
	Tile.new([
		TileSide.new(PLANE_UP,			INDICE_QUAD, UP, 		Cull.Full, Dir.Top, GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, DOWN, 		Cull.Full, Dir.Bottom, GrowthTypes.None),
		TileSide.new(PLANE_RIGHT,		INDICE_QUAD, RIGHT, 	Cull.Full, Dir.Left, GrowthTypes.NormalSide),
		TileSide.new(PLANE_LEFT,		INDICE_QUAD, LEFT, 		Cull.Full, Dir.Right, GrowthTypes.NormalSide),
		TileSide.new(PLANE_BACK,		INDICE_QUAD, BACK, 		Cull.Full, Dir.Back, GrowthTypes.NormalSide),
		TileSide.new(PLANE_FRONT,		INDICE_QUAD, FWD, 		Cull.Full, Dir.Front, GrowthTypes.NormalSide),
	]),
	# Sideways Slope
	Tile.new([
		TileSide.new(TRI_TOP,					INDICE_TRI,  			UP, 		Cull.TopTri, Dir.Top, GrowthTypes.Full),
		TileSide.new(flip_y(TRI_TOP),			INDICE_TRI_FLIPPED, 	DOWN, 		Cull.TopTri, Dir.Bottom, GrowthTypes.None),
		TileSide.new(PLANE_RIGHT,				INDICE_QUAD,			RIGHT, 		Cull.Full, Dir.Left, GrowthTypes.NormalSide),
		TileSide.new(PLANE_VSLOPE,				INDICE_QUAD_FLIPPED, 	LEFT+BACK, 	Cull.Empty, Dir.Right, GrowthTypes.DiagonalSide),
		TileSide.new(PLANE_FRONT,				INDICE_QUAD, 			FWD, 		Cull.Full, Dir.Front, GrowthTypes.NormalSide),
	]),
	# Vertical Slab
	Tile.new([
		TileSide.new(minv(PLANE_UP,2,0.5),			INDICE_QUAD, UP, 		Cull.TopHalf, Dir.Top, GrowthTypes.Full),
		TileSide.new(minv(PLANE_DOWN,2,0.5),		INDICE_QUAD, DOWN, 		Cull.TopHalf, Dir.Bottom, GrowthTypes.None),
		TileSide.new(minv(PLANE_RIGHT,2,0.5),		INDICE_QUAD, RIGHT, 	Cull.HalfSide_1, Dir.Left, GrowthTypes.NormalSide),
		TileSide.new(minv(PLANE_LEFT,2,0.5),		INDICE_QUAD, LEFT, 		Cull.HalfSide_2, Dir.Right, GrowthTypes.NormalSide),
		TileSide.new(shift(PLANE_BACK,2,-0.5),		INDICE_QUAD, BACK, 		Cull.Empty, Dir.Back, GrowthTypes.NormalSide),
		TileSide.new(PLANE_FRONT,					INDICE_QUAD, FWD, 		Cull.Full, Dir.Front, GrowthTypes.NormalSide),
	]),
	# Cull
	Tile.new([
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Top, GrowthTypes.None),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Bottom, GrowthTypes.None),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Left, GrowthTypes.None),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Right, GrowthTypes.None),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Back, GrowthTypes.None),
		TileSide.new([],	[], Vector3.ZERO, 		Cull.Full, Dir.Front, GrowthTypes.None),
	]),
	# Troll Block
	null,
	# Fence
	Tile.new([
		TileSide.new(PLANE_FRONT_HALF,	INDICE_QUAD, FWD, 		Cull.Empty, Dir.Front, GrowthTypes.HalfSide),
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
const PLANE_DOWN		: PackedVector3Array = [Vector3(0,0,1),Vector3(1,0,1),Vector3(1,0,0),Vector3(0,0,0)]
const PLANE_LEFT		: PackedVector3Array = [Vector3(1,0,0),Vector3(1,0,1),Vector3(1,1,1),Vector3(1,1,0)]
const PLANE_RIGHT		: PackedVector3Array = [Vector3(0,0,0),Vector3(0,1,0),Vector3(0,1,1),Vector3(0,0,1)]
const PLANE_BACK		: PackedVector3Array = [Vector3(1,0,1),Vector3(0,0,1),Vector3(0,1,1),Vector3(1,1,1)]
const PLANE_FRONT		: PackedVector3Array = [Vector3(0,0,0),Vector3(1,0,0),Vector3(1,1,0),Vector3(0,1,0)]

const PLANE_UP_HALF		: PackedVector3Array = [Vector3(0,.5,1),Vector3(0,.5,0),Vector3(1,.5,0),Vector3(1,.5,1)]
const PLANE_LEFT_HALF	: PackedVector3Array = [Vector3(1,0,1),Vector3(1,.5,1),Vector3(1,.5,0),Vector3(1,0,0)]
const PLANE_RIGHT_HALF	: PackedVector3Array = [Vector3(0,.5,1),Vector3(0,0,1),Vector3(0,0,0),Vector3(0,.5,0)]
const PLANE_BACK_HALF	: PackedVector3Array = [Vector3(1,0,1),Vector3(0,0,1),Vector3(0,.5,1),Vector3(1,.5,1)]
const PLANE_FRONT_HALF	: PackedVector3Array = [Vector3(1,.5,0),Vector3(0,.5,0),Vector3(0,0,0),Vector3(1,0,0)]

const PLANE_SLOPE		: PackedVector3Array = [Vector3(0,1,0),Vector3(1,1,0),Vector3(1,0,1),Vector3(0,0,1)]
const PLANE_VSLOPE		: PackedVector3Array = [Vector3(0,1,1),Vector3(0,0,1),Vector3(1,0,0),Vector3(1,1,0)]
const TRIANGLE_SLOPER	: PackedVector3Array = [Vector3(0,0,0),Vector3(0,1,0),Vector3(0,0,1)]
const TRIANGLE_SLOPEL	: PackedVector3Array = [Vector3(1,0,0),Vector3(1,0,1),Vector3(1,1,0)]
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
const UV_QUAD : PackedVector2Array = [Vector2(1,1),Vector2(0,1),Vector2(0,0),Vector2(1,0)]
const UV_TRI : PackedVector2Array = [Vector2(1,1),Vector2(0,1),Vector2(0,0)]

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
