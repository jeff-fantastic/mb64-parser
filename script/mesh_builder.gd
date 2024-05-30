# mesh_builder.gd
class_name Meshbuilder extends Node

'''
Builds a mesh from provided MB64Level data
'''

## Signaled when mesh is built
signal mesh_built()

## Reference to [MeshInstance]
@onready var mesh_instance := $built_mesh

## Tile grid
var grid : MB64Level.CMMTileGrid

## Materials
const materials : Array[StandardMaterial3D] = [
	preload("res://asset/mat/debug/debug0.tres"),
	preload("res://asset/mat/debug/debug1.tres"),
	preload("res://asset/mat/debug/debug2.tres"),
	preload("res://asset/mat/debug/debug3.tres"),
	preload("res://asset/mat/debug/debug4.tres"),
	preload("res://asset/mat/debug/debug5.tres"),
	preload("res://asset/mat/debug/debug6.tres"),
	preload("res://asset/mat/debug/debug7.tres"),
	preload("res://asset/mat/debug/debug8.tres"),
	preload("res://asset/mat/debug/debug9.tres"),
	preload("res://asset/mat/debug/fence_debug.tres"),
	preload("res://asset/mat/debug/pole_debug.tres"),
	preload("res://asset/mat/debug/bars_debug.tres"),
	preload("res://asset/mat/debug/water_debug.tres")
]

func build_mesh(result : MB64Level) -> void:
	# Declare variables
	var mesh : ArrayMesh = ArrayMesh.new()
	var tiles_sorted : Array[Array]
	var mesh_data_array : Array[Variant] = []
	grid = result.t_grid
	
	# Setup arrays
	tiles_sorted.resize(14)
	
	# Iterate over tiles
	for tile in grid.map:
		match (tile[1].type):
			MDat.TileTypes.Fence:	tiles_sorted[10].push_back(tile[0])
			MDat.TileTypes.Pole:	tiles_sorted[11].push_back(tile[0])
			MDat.TileTypes.Bars:	tiles_sorted[12].push_back(tile[0])
			MDat.TileTypes.Water:	tiles_sorted[13].push_back(tile[0])
			_:						tiles_sorted[tile[1].mat].push_back(tile[0])
		
		
	# Now iterate over materials
	for list in range(tiles_sorted.size()):
		# Prepare mesh array
		prepare_mesh_array(mesh_data_array)
		
		# Skip if nothing in list
		if tiles_sorted[list].is_empty():
			continue
		
		# Build surface
		var total_ind : int = 0
		for tile in tiles_sorted[list]:
			total_ind = build_tile(mesh_data_array, tile, total_ind)
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data_array)
		var count : int = mesh.get_surface_count() - 1
		mesh.surface_set_material(count, materials[list])
		mesh.generate_triangle_mesh()
	
	# Build and set mesh
	mesh_instance.mesh = mesh

## Builds a tile based on type, and assigns it a material
func build_tile(mesh_arr : Array[Variant], pos : Vector3, total_ind : int) -> int:
	# Determine tile type and position
	var tile : MB64Level.CMMTile = grid.tiles[pos.x][pos.y][pos.z]
	var tile_type : MDat.Tile =  MDat.tiles[tile.type]
	if !tile_type:
		tile_type = MDat.tiles[MDat.TileTypes.Block]
	
	# Build sides
	for side in tile_type.sides:
		for face in side:
			# Determine cull
			face = face as MDat.TileSide
			if !should_build(face, pos, face.dir, tile.rot):
				continue
			
			# Get side information
			var vertices := PackedVector3Array([])
			var indices : PackedInt32Array = face.indices 
			
			# Build vertices array
			for vtx in face.mesh:
				var v_pos = rotate_point(vtx, tile.rot) + pos
				var dir = face.normal.rotated(Vector3.UP, tile.rot * -PI/2)
				vertices.push_back(v_pos)
				mesh_arr[Mesh.ARRAY_NORMAL].push_back(dir)
			
			# Determine indice offset (this sucks)
			var offset : PackedInt32Array = indices.duplicate()
			for idx in range(offset.size()):
				offset[idx] += total_ind
			
			# Append verts, indices, uvs
			mesh_arr[Mesh.ARRAY_VERTEX].append_array(vertices)
			mesh_arr[Mesh.ARRAY_INDEX].append_array(offset)
			
			# Increment
			total_ind += indices_from_face(indices)
		
	# Return indices
	return total_ind

func prepare_mesh_array(mda : Array) -> void:
	mda.clear()
	mda.resize(Mesh.ARRAY_MAX)
	mda[Mesh.ARRAY_VERTEX] = PackedVector3Array([])
	mda[Mesh.ARRAY_INDEX] = PackedInt32Array([])
	mda[Mesh.ARRAY_NORMAL] = PackedVector3Array([])

## Determines if building a side is necessary based on culling checks
func should_build(face : MDat.TileSide, pos : Vector3, dir : MDat.Dir, rot : int) -> bool:
	# Get outbound cull, dont cull if -1
	var outbound_cull = face.cullid
	if outbound_cull == MDat.Cull.Empty:
		return true
	
	# Continue with rotation
	var d_rotated = rotate_enum(dir, rot)
	var d_vec = add_vec(vec_from_dir(d_rotated), pos)
	var outbound_tile = grid.tiles[pos.x][pos.y][pos.z]
	var inbound_tile = grid.tiles[d_vec.x][d_vec.y][d_vec.z]
	
	# If theres no tile, always build
	if !inbound_tile || d_vec == pos:
		return true
	
	# Otherwise check adjacent face and compare priority
	inbound_tile = inbound_tile as MB64Level.CMMTile
	var inbound_tile_dat = MDat.tiles[inbound_tile.type]
	if !inbound_tile_dat:
		inbound_tile_dat = MDat.tiles[MDat.TileTypes.Block]
	var inbound_faces = inbound_tile_dat.sides[rotate_enum(d_rotated, ((4-inbound_tile.rot) % 4)) ^ 1]
	
	if inbound_faces.is_empty():
		return true
	
	# Do culling checks
	for iface in inbound_faces:
		# Edge cases
		if iface.cullid == MDat.Cull.Empty:
			return true
		if iface.cullid == MDat.Cull.Full:
			return false
		if face.cullid == MDat.Cull.Full:
			return true
		if (face.cullid == MDat.Cull.TopTri || face.cullid == MDat.Cull.TopHalf):
			if (face.cullid == iface.cullid):
				return false
		if face.cullid == MDat.Cull.BottomSlab || face.cullid == MDat.Cull.TopSlab || face.cullid == MDat.Cull.PoleTop:
			if (face.cullid == iface.cullid):
				return false
		print(face.cullid, iface.cullid^1, face.cullid == iface.cullid^1)
		if (face.cullid == iface.cullid^1):
			return false
		if (face.cullid & 0x10) && (iface.cullid & 0x10) ||\
		   (face.cullid & 0x20) && (iface.cullid & 0x20):
			return (face.cullid < iface.cullid)
	return true

## "Rotates" direction enum by provided factor
func rotate_enum(dir : MDat.Dir, rot : int) -> int:
	# Return self if dir is not in rotation, otherwise rotate
	return MDat.dir_rot[rot][dir]

## Converts direction enum into vector3
func vec_from_dir(dir : MDat.Dir) -> Vector3:
	match dir:
		MDat.Dir.Front:		return Vector3.FORWARD
		MDat.Dir.Back:		return Vector3.BACK
		MDat.Dir.Left:		return Vector3.LEFT
		MDat.Dir.Right:		return Vector3.RIGHT
		MDat.Dir.Top:		return Vector3.UP
		MDat.Dir.Bottom:	return Vector3.DOWN
	return Vector3.ZERO

## Adds vectors.. safely
func add_vec(vec1 : Vector3, vec2 : Vector3) -> Vector3:
	return Vector3(
		clamp(vec1.x + vec2.x, 0, 63),
		clamp(vec1.y + vec2.y, 0, 63),
		clamp(vec1.z + vec2.z, 0, 63),
	)

## Returns indice offset based on size of input indices array
func indices_from_face(indices : PackedInt32Array) -> int:
	return 2 + (indices.size() / 3)

## Rotates a tile
func rotate_point(pos : Vector3, rot : int) -> Vector3:
	return (pos - (Vector3.ONE * 0.5)).rotated(Vector3.UP, rot * PI/2) + (Vector3.ONE * 0.5)
