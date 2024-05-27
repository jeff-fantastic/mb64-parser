# res_mb64.gd
class_name MB64Level extends Resource

'''
Mario Builder 64 level format, represented
by a custom Godot resource
'''

@export_category("LevelHeader")

## Name of the level, taken from filename
@export var level_name : String :
	set(value) : level_name = value.rstrip(".mb64")
	get : return level_name
## Header of MB64 file, 10 bytes long
@export var file_header : String :
	set(value) : if value.length() <= 10: file_header = value;
	get : return file_header
## Version byte
@export var version : int :
	set(value) : if value >= 0 && value <= 0xFF: version = value;
	get : return version
## Author, 31 bytes long
@export var author : String :
	set(value) : if value.length() <= 31: author = value;
	get : return author
## RGBA16 Picture data, 4096 u16 bytes
@export var picture : PackedByteArray
## RGBA16 Picture data, image-ified
@export var picture_img : Image
## Costume byte
@export var costume : int :
	set(value) : if value >= 0 && value <= 0xFF: costume = value;
	get : return costume
## Music selection, 5 bytes, though only 3 are actually used
@export var music : PackedByteArray
## Environment byte
@export var envfx : int :
	set(value) : if value >= 0 && value <= 0xFF: envfx = value;
	get : return envfx
## Theme byte
@export var theme : int :
	set(value) : if value >= 0 && value <= 0xFF: theme = value;
	get : return theme
## Background byte
@export var bg : int :
	set(value) : if value >= 0 && value <= 0xFF: bg = value;
	get : return bg
## Boundary material byte
@export var boundary_mat : int :
	set(value) : if value >= 0 && value <= 0xFF: boundary_mat = value;
	get : return boundary_mat
## Boundary type byte
@export var boundary : int :
	set(value) : if value >= 0 && value <= 0xFF: boundary = value;
	get : return boundary
## Boundary height byte
@export var boundary_height : int :
	set(value) : if value >= 0 && value <= 0xFF: boundary_height = value;
	get : return boundary_height
## Coin star value byte
@export var coinstar : int :
	set(value) : if value >= 0 && value <= 0xFF: coinstar = value;
	get : return coinstar
## Size byte
@export var size : int :
	set(value) : if value >= 0 && value <= 0xFF: size = value;
	get : return size
## Water level byte
@export var waterlevel : int :
	set(value) : if value >= 0 && value <= 0xFF: waterlevel = value;
	get : return waterlevel
## Secret flag
@export var secret : bool
## Game-mode flag
@export var game : bool
## Toolbar array, 9 bytes, not really used for anything in this program
@export var toolbar : PackedByteArray
## Toolbar params, 9 bytes, not really used for anything in this program
@export var toolbar_params : PackedByteArray
## Tile count, two bytes
@export var tile_count : int
## Object count, two bytes
@export var object_count : int

@export_group("LevelCustomTheme")

## Custom theme, 36 bytes
@export var custom_theme : CMMCustomTheme
## Custom theme resource class
class CMMCustomTheme extends Resource:
	var mats : PackedByteArray = []
	var topmats : PackedByteArray = []
	var topmatsEnabled : PackedByteArray = []
	var fence : int
	var pole : int
	var bars : int
	var water : int
	
	## Deserializes data to custom resource
	func deserialize(data : PackedByteArray) -> CMMCustomTheme:
		mats = data.slice(0, 10)
		topmats = data.slice(10, 20)
		topmatsEnabled = data.slice(20, 30)
		fence = data.decode_u8(30)
		pole = data.decode_u8(31)
		bars = data.decode_u8(32)
		water = data.decode_u8(33)
		return self
	
	## Reserializes custom resource back into byte data
	func serialize(stream : StreamPeerBuffer) -> void:
		# Create and populate buffer
		var buf : PackedByteArray = []
		buf.append_array(self.mats)
		buf.append_array(self.topmats)
		buf.append_array(self.topmatsEnabled)
		buf.append(fence)
		buf.append(pole)
		buf.append(bars)
		buf.append(water)
		
		# Write to stream
		stream.put_data(buf)

@export_group("LevelTrajectory")

## Trajectory data, 4000 bytes!
@export var trajectories : CMMTrajectories
## Trajectory point resource class
class CMMTrajectoryPoint extends Resource:
	var t : int
	var pos : Vector3i = Vector3i.ZERO
	
	## Constructor
	func _init(p_t : int, p_x : int, p_y : int, p_z : int) -> void:
		self.t = p_t
		self.pos.x = p_x
		self.pos.y = p_y
		self.pos.z = p_z
	
	## Checks if self is all zeroes, usually an indicator
	## of there being no further data in a block.
	func is_zero() -> bool:
		return t == 0 && pos.x == 0 && pos.y == 0 && pos.x == 0
	
	## Alternate check for 0x1F fields. These seem like
	## they exist to pad trajectory data for their entire
	## data block (of about 200 bytes) but they also just 
	## sometimes populate entire data blocks. Might just
	## be remnants of track data that was then deleted
	## but improperly cleared, leading to unoptimal data
	## being written to the save
	func is_0x1F() -> bool:
		return pos.x == 0x1F && pos.y == 0x1F && pos.z == 0x1F
	
	## Whether or not t value is -1
	func is_stub() -> bool:
		return false if t != -1 else true
		
## Trajectory track resource class
class CMMTrajectory extends Resource:
	var points : Array[CMMTrajectoryPoint]
## Trajectory manager resource class
class CMMTrajectories extends Resource:
	var list : Array[CMMTrajectory]
	
	## Deserializes data to custom resource
	func deserialize(data : PackedByteArray) -> CMMTrajectories:
		# Iterate over trajectories
		for x in range((data.size()/200)):
			var trajectory := CMMTrajectory.new()
			var traj_points := data.slice(200 * x, 200 * (x + 1))
			var zeroes = 0
			
			# Iterate over points
			for y in range((traj_points.size()/4)):
				var p_a := traj_points.slice(y * 4, (y + 1) * 4)
				var point := CMMTrajectoryPoint.new(
					p_a.decode_s8(0), 
					p_a.decode_u8(1), 
					p_a.decode_u8(2), 
					p_a.decode_u8(3)
				)
				trajectory.points.append(point)
				
				## Cancel adding point if the block is
				## just empty or dummy data
				if point.is_zero() || point.is_0x1F():
					zeroes += 1
					if zeroes > 1:
						trajectory.points.clear()
						break
				
				## Otherwise, when coming to a stub,
				## we know thats the end of the track
				if point.is_stub():
					break
			
			# Append trajectory to list, continue
			self.list.append(trajectory)
			
		return self
	
	## Serializes resource back into bytes
	func serialize(stream : StreamPeerBuffer) -> void:
		# Declare variables
		var buf : PackedByteArray = []
		
		# Data preparation loops
		for trajectory in self.list:
			# Create data block
			var traj_buf : PackedByteArray = []
			
			# Read existing points
			for p in trajectory.points:
				traj_buf.append_array([p.t, p.pos.x, p.pos.y, p.pos.z])
				if p.is_stub():
					break
			
			# Fill rest with NOTHING and send to main buffer
			var empty : PackedByteArray = []
			empty.resize(200-traj_buf.size()); empty.fill(0)
			traj_buf.append_array(empty)
			buf.append_array(traj_buf)
		
		# Write to stream
		stream.put_data(buf)

@export_group("LevelTile")

## Tile grid resource, 10000 bytes
@export var t_grid : CMMTileGrid

class CMMTile extends Resource:
	var pos : Vector3i
	var type : MDat.TileTypes
	var mat : int
	var rot : int
	var waterlogged : bool
	
	## Constructor
	func _init(p_x : int, p_y : int, p_z : int, p_type : int, 
	p_mat : int, p_rot : int, p_waterlogged : bool) -> void:
		self.pos.x = p_x
		self.pos.y = p_y
		self.pos.z = p_z
		self.type = p_type as MDat.TileTypes
		self.mat = p_mat
		self.rot = p_rot
		self.waterlogged = p_waterlogged
	
class CMMTileGrid extends Resource:
	## Array of tile data
	var tiles : Array[CMMTile]
	
	## Deserializes byte data into tiles
	func deserialize(data : PackedByteArray, tile_count : int) -> CMMTileGrid:
		
		# Begin preparing array
		for x in range(data.size()/4):
			# Get value
			var u8 : Array[int] = [
				data.decode_u8((x * 4)),
				data.decode_u8((x * 4) + 1),
				data.decode_u8((x * 4) + 2),
				data.decode_u8((x * 4) + 3),
			]
			var value : int = (u8[0] << 24) | (u8[1] << 16) | (u8[2] << 8) | (u8[3])
			if is_null(value):
				continue
			
			# Split u32 into values
			var pos_x : int = (value >> 26) & 0x3F
			var pos_y : int = (value >> 20) & 0x3F
			var pos_z : int = (value >> 14) & 0x3F
			var type : int = (value >> 9) & 0x1F
			var mat : int = (value >> 5) & 0x0F
			var rot : int = (value >> 3) & 0x03
			var waterlogged : bool = true if ((value >> 2) & 0x01) == 1 else false
			
			# Create tile
			var tile : CMMTile = CMMTile.new(
				pos_x, pos_y, pos_z,
				type, mat, rot,
				waterlogged
			)
			
			# Add to list
			tiles.append(tile)
		
		# Return self
		return self
		
	## Returns whether or not theres no data
	func is_null(u32 : int) -> bool:
		return u32 == 0

@export_group("LevelObject")
