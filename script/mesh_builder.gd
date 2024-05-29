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
	preload("res://asset/mat/debug0.tres"),
	preload("res://asset/mat/debug1.tres"),
	preload("res://asset/mat/debug2.tres"),
	preload("res://asset/mat/debug3.tres"),
	preload("res://asset/mat/debug4.tres"),
	preload("res://asset/mat/debug5.tres"),
	preload("res://asset/mat/debug6.tres"),
	preload("res://asset/mat/debug7.tres"),
	preload("res://asset/mat/debug8.tres"),
	preload("res://asset/mat/debug9.tres"),
	preload("res://asset/mat/fence_debug.tres"),
	preload("res://asset/mat/pole_debug.tres"),
	preload("res://asset/mat/bars_debug.tres"),
	preload("res://asset/mat/water_debug.tres")
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
		# Get side information
		var vertices := PackedVector3Array([])
		var indices := side.indices 
		
		# Build vertices array
		for vtx in side.mesh:
			var v_pos = rotate_point(vtx, tile.rot) + pos
			var dir = side.dir.rotated(Vector3.UP, tile.rot * -PI/2)
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

func should_build() -> bool:
	return false

## Returns indice offset based on size of input indices array
func indices_from_face(indices : PackedInt32Array) -> int:
	return 2 + (indices.size() / 3)

## Rotates a tile
func rotate_point(pos : Vector3, rot : int) -> Vector3:
	return (pos - (Vector3.ONE * 0.5)).rotated(Vector3.UP, rot * PI/2) + (Vector3.ONE * 0.5)
