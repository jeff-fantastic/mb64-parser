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

## Tile cull type enum
enum CullTypes { 
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

## Normal dirs
const UP				= Vector3.UP
const DOWN				= Vector3.DOWN
const RIGHT				= Vector3.RIGHT
const LEFT				= Vector3.LEFT
const BACK				= Vector3.BACK
const FWD			= Vector3.FORWARD

## Side class
class TileSide extends Resource:
	var mesh : PackedVector3Array
	var indices : PackedInt32Array
	var dir : Vector3
	var shape : CullTypes
	var growth : GrowthTypes
	var alt_uv : Array[Vector2]
	func _init(p_mesh : PackedVector3Array, p_ind : PackedInt32Array, p_dir : Vector3, 
	p_shape : CullTypes, p_growth : GrowthTypes, p_alt_uv : Array[Vector2] = []) -> void:
		self.mesh = p_mesh
		self.indices = p_ind
		self.dir = p_dir
		self.shape = p_shape
		self.growth = p_growth
		self.alt_uv = p_alt_uv

## Tile class
class Tile extends Resource:
	var sides : Array[TileSide]
	func _init(p_sides : Array[TileSide]) -> void:
		self.sides = p_sides

## Tiles
@onready var tiles : Array[Tile] = [
	# Empty
	null,
	# Null,
	null,
	# Slope
	Tile.new([
		TileSide.new(PLANE_SLOPE,		INDICE_QUAD_FLIPPED, UP+FWD,	CullTypes.Full, 	GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, 		 DOWN, 		CullTypes.Full, 	GrowthTypes.None),
		TileSide.new(TRIANGLE_SLOPER,	INDICE_TRI,  		 RIGHT, 	CullTypes.Tri_1, 	GrowthTypes.SlopeSideR),
		TileSide.new(TRIANGLE_SLOPEL,	INDICE_TRI,  		 LEFT, 		CullTypes.Tri_2, 	GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_BACK,		INDICE_QUAD, 		 BACK, 		CullTypes.Full, 	GrowthTypes.HalfSide),
	]),
	# Slope (Flipped)
	Tile.new([
		TileSide.new(PLANE_UP,					INDICE_QUAD, 		 UP, 		CullTypes.Full, 	GrowthTypes.Full),
		TileSide.new(flip_y(PLANE_SLOPE),		INDICE_QUAD, DOWN+FWD,	CullTypes.Full, 	GrowthTypes.None),
		TileSide.new(flip_y(TRIANGLE_SLOPER),	INDICE_TRI_FLIPPED,  RIGHT, 	CullTypes.Tri_1, 	GrowthTypes.SlopeSideR),
		TileSide.new(flip_y(TRIANGLE_SLOPEL),	INDICE_TRI_FLIPPED,  LEFT, 		CullTypes.Tri_2, 	GrowthTypes.SlopeSideL),
		TileSide.new(PLANE_BACK,				INDICE_QUAD,		 BACK, 		CullTypes.Full, 	GrowthTypes.HalfSide),
	]),
	# Slab
	Tile.new([
		TileSide.new(PLANE_UP_HALF,		INDICE_QUAD, UP, 		CullTypes.Full, GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, DOWN, 		CullTypes.Full, GrowthTypes.None),
		TileSide.new(PLANE_RIGHT_HALF,	INDICE_QUAD, RIGHT, 	CullTypes.Full, GrowthTypes.HalfSide),
		TileSide.new(PLANE_LEFT_HALF,	INDICE_QUAD, LEFT, 		CullTypes.Full, GrowthTypes.HalfSide),
		TileSide.new(PLANE_BACK_HALF,	INDICE_QUAD, BACK, 		CullTypes.Full, GrowthTypes.HalfSide),
		TileSide.new(PLANE_FRONT_HALF,	INDICE_QUAD, FWD, 		CullTypes.Full, GrowthTypes.HalfSide),
	]),
	# Slab (Flipped)
	Tile.new([
		TileSide.new(PLANE_UP,					INDICE_QUAD,		 UP, 		CullTypes.Full, GrowthTypes.Full),
		TileSide.new(PLANE_UP_HALF,				INDICE_QUAD_FLIPPED, DOWN, 		CullTypes.Full, GrowthTypes.None),
		TileSide.new(flip_y(PLANE_RIGHT_HALF),	INDICE_QUAD_FLIPPED, RIGHT, 	CullTypes.Full, GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_LEFT_HALF),	INDICE_QUAD_FLIPPED, LEFT, 		CullTypes.Full, GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_BACK_HALF),	INDICE_QUAD_FLIPPED, BACK, 		CullTypes.Full, GrowthTypes.HalfSide),
		TileSide.new(flip_y(PLANE_FRONT_HALF),	INDICE_QUAD_FLIPPED, FWD, 		CullTypes.Full, GrowthTypes.HalfSide),
	]),
	# Corner
	null,
	# Corner (Flipped)
	null,
	# Inverted Corner
	null,
	# Inverted Corner (Flipped)
	null,
	# Sloped Corner
	null,
	# Sloped Corner (Flipped)
	null,
	# Upper Gentle Slope
	null,
	# Upper Gentle Slope (Flipped)
	null,
	# Lower Gentle Slope
	null,
	# Lower Gentle Slope (Flipped)
	null,
	# Block
	Tile.new([
		TileSide.new(PLANE_UP,			INDICE_QUAD, UP, 		CullTypes.Full, GrowthTypes.Full),
		TileSide.new(PLANE_DOWN,		INDICE_QUAD, DOWN, 		CullTypes.Full, GrowthTypes.None),
		TileSide.new(PLANE_RIGHT,		INDICE_QUAD, RIGHT, 	CullTypes.Full, GrowthTypes.NormalSide),
		TileSide.new(PLANE_LEFT,		INDICE_QUAD, LEFT, 		CullTypes.Full, GrowthTypes.NormalSide),
		TileSide.new(PLANE_BACK,		INDICE_QUAD, BACK, 		CullTypes.Full, GrowthTypes.NormalSide),
		TileSide.new(PLANE_FRONT,		INDICE_QUAD, FWD, 		CullTypes.Full, GrowthTypes.NormalSide),
	]),
	# Sideways Slope
	null,
	# Vertical Slab
	null,
	# Cull
	null,
	# Troll Block
	null,
	# Fence
	null,
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

const PLANE_SLOPE		: PackedVector3Array = [Vector3(1,0,0),Vector3(0,0,0),Vector3(0,1,1),Vector3(1,1,1)]
const TRIANGLE_SLOPEL	: PackedVector3Array = [Vector3(0,0,0),Vector3(0,1,1),Vector3(0,0,1)]
const TRIANGLE_SLOPER	: PackedVector3Array = [Vector3(1,0,0),Vector3(1,0,1),Vector3(1,1,1)]

func flip_y(verts : PackedVector3Array) -> PackedVector3Array:
	var new := PackedVector3Array()
	for vtx in verts:
		# Cursed
		vtx.y = (1 if vtx.y == 0 else 0) if vtx.y == 0 || vtx.y == 1 else vtx.y
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

## Block UV
const UV_BLOCK : PackedVector2Array = [Vector2(1,1),Vector2(0,1),Vector2(0,0),Vector2(1,0)]
