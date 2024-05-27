# mesh_builder.gd
class_name Meshbuilder extends Node

'''
Builds a mesh from provided MB64Level data
'''

## Signaled when mesh is built
signal mesh_built()

## Reference to [MeshInstance]
@onready var mesh_instance := $built_mesh

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
]

func build_mesh(result : MB64Level) -> void:
	# Declare variables
	var grid : MB64Level.CMMTileGrid = result.t_grid
	var mesh : ArrayMesh = ArrayMesh.new()
	var tile_mat : Array[Array]
	var mesh_data_array : Array[Variant] = []
	
	# Setup arrays
	tile_mat.resize(10)
	
	# Iterate over tiles
	for tile in grid.tiles:
		var arr = tile_mat[tile.mat]
		arr.push_back(tile)
	
	# Now iterate over materials
	for list in tile_mat:
		mesh_data_array.clear()
		mesh_data_array.resize(Mesh.ARRAY_MAX)
		mesh_data_array[Mesh.ARRAY_VERTEX] = PackedVector3Array([])
		mesh_data_array[Mesh.ARRAY_INDEX] = PackedInt32Array([])
		mesh_data_array[Mesh.ARRAY_NORMAL] = PackedVector3Array([])
		
		# Build surface
		var total_ind : int = 0
		for tile in list:
			total_ind = build_tile(mesh_data_array, tile, total_ind)
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data_array)
		var count : int = mesh.get_surface_count() - 1
		mesh.surface_set_material(count, materials[count])
	
	# Build and set mesh
	mesh_instance.mesh = mesh

## Builds a tile based on type, and assigns it a material
func build_tile(mesh_arr : Array[Variant], tile : MB64Level.CMMTile, total_ind : int) -> int:
	# Determine tile type and position
	var tile_type : MDat.Tile = MDat.tiles[0] 
	var pos = tile.pos as Vector3
	
	# Build sides
	for side in tile_type.sides:
		var vertices := PackedVector3Array([])
		for vtx in side.mesh:
			var v_pos = vtx + pos
			vertices.push_back(v_pos)
			mesh_arr[Mesh.ARRAY_NORMAL].push_back(side.dir)
		
		# Determine indice offset (this sucks)
		var offset : PackedInt32Array = side.indices.duplicate()
		for idx in range(offset.size()):
			offset[idx] += total_ind
		
		# Append verts, indices, uvs
		mesh_arr[Mesh.ARRAY_VERTEX].append_array(vertices)
		mesh_arr[Mesh.ARRAY_INDEX].append_array(offset)
		
		# Increment
		total_ind += 4
	
	# Return indices
	return total_ind


func should_build() -> bool:
	return false
