# mesh_builder.gd
class_name Meshbuilder extends Node

'''
Builds a mesh from provided MB64Level data
'''

## Signaled when mesh is built
signal mesh_built()

const OPAQUE = "res://asset/mat/shader/n64_lit.gdshader"
const TRANSPARENT = "res://asset/mat/shader/n64_lit_transparent.gdshader"

## Reference to [MeshInstance]
@onready var mesh_instance := $built_mesh
## Reference to skybox
@onready var skybox := $skybox

## Tile grid
var grid : MB64Level.CMMTileGrid

## Placeholder materials
const placeholder_materials : Array[StandardMaterial3D] = [
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
	mesh_instance.mesh = mesh
	
	# Set skybox
	set_skybox(result.bg)
	
	# Setup tile sorted array
	# 10 entries for side tiles,
	# 10 entries for top tiles (different surfaces)
	# 4 entries for special tiles
	tiles_sorted.resize(24)
	
	# Get material array
	var mats := MDat.default_themes[result.theme]
	if !mats: mats = placeholder_materials
	
	# Iterate over tiles
	for tile in grid.map:
		match (tile[1].type):
			MDat.TileTypes.Fence:	tiles_sorted[20].push_back(tile[0])
			MDat.TileTypes.Pole:	tiles_sorted[21].push_back(tile[0])
			MDat.TileTypes.Bars:	tiles_sorted[22].push_back(tile[0])
			MDat.TileTypes.Water:	tiles_sorted[23].push_back(tile[0])
			_:
				tiles_sorted[tile[1].mat].push_back(tile[0])
				tiles_sorted[tile[1].mat + 10].push_back(tile[0])
		
		
	# Now iterate over materials
	for list in range(tiles_sorted.size()):
		# Prepare mesh array
		prepare_mesh_array(mesh_data_array)
		
		# Skip if nothing in list
		if tiles_sorted[list].is_empty():
			continue
		
		var total_ind : int = 0
		for tile in tiles_sorted[list]:
			if list < 10 || list >= 20:
				# Build sides if tiles_sorted subarray contains tile data
				total_ind = build_tile_sides(mesh_data_array, tiles_sorted, tile, total_ind)
			else:
				# Otherwise build tops
				total_ind = build_tile_top(mesh_data_array, tile, total_ind)
		
		# Make surface, if there is anything
		if mesh_data_array[Mesh.ARRAY_VERTEX].is_empty():
			continue
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data_array)
		
		# Assign material
		var count : int = mesh.get_surface_count() - 1
		var mat := obtain_material(mats, list)
		mesh_instance.set_surface_override_material(count, mat)
		mesh.generate_triangle_mesh()

## Builds all sides of a tile except tops.
func build_tile_sides(mesh_arr : Array[Variant], tile_list : Array, pos : Vector3, total_ind : int) -> int:
	# Determine tile type and position
	var tile : MB64Level.CMMTile = grid.tiles[pos.x][pos.y][pos.z]
	var tile_type : MDat.Tile =  MDat.tiles[tile.type]
	if !tile_type:
		tile_type = MDat.tiles[MDat.TileTypes.Block]
	
	# Build sides
	for side in tile_type.sides:
		for face in side:
			face = face as MDat.TileSide
			if face.dir == MDat.Dir.Top && tile.type < MDat.TileTypes.Fence && tile.type != MDat.TileTypes.Water:
				continue
			
			# Otherwise determine culling
			if !should_build(face, pos, face.dir, tile.rot):
				continue
			
			# Build triangle
			total_ind = build_tri(face, pos, tile, mesh_arr, total_ind)
		
	# Return indices
	return total_ind

## Builds top of tile
func build_tile_top(mesh_arr : Array[Variant], pos : Vector3, total_ind : int) -> int:
	# Get top side
	var tile : MB64Level.CMMTile = grid.tiles[pos.x][pos.y][pos.z]
	var tile_type : MDat.Tile =  MDat.tiles[tile.type]
	if !tile_type:
		tile_type = MDat.tiles[MDat.TileTypes.Block]
	var side := tile_type.sides[MDat.Dir.Top]
	
	for face in side:
		face = face as MDat.TileSide
		
		# Cull check
		if !should_build(face, pos, face.dir, tile.rot):
			continue
		
		# Build triangle
		total_ind = build_tri(face, pos, tile, mesh_arr, total_ind)
		
	return total_ind

## Builds triangle
func build_tri(face : MDat.TileSide, pos : Vector3, tile : MB64Level.CMMTile, mesh_arr : Array, total_ind : int) -> int:
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
	
	var d_rotated = rotate_enum(face.dir, tile.rot)
	var d_vec = vec_from_dir(d_rotated)
	mesh_arr[Mesh.ARRAY_TEX_UV].append_array(rotate_uv(d_vec, tile.rot, face.uv))
	
	# Increment
	return total_ind + indices_from_face(indices)

## Exports level model as GLTF binary
func export_model_process() -> void:
	# Generate model from mesh
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	state.base_path = "res://"
	
	# This fix is bullshit, maybe I'm missing something here but
	# Godot's GLTF classes only recognize standard 3D materials.
	# Sure, thats checks, completely understandable. However, the only 
	# way I can seem to pack materials into the GLTF file is by replacing
	# the shader ones with standard ones... ON THE MESH. That is so dumb.
	# Why Godot doesnt let me just write to the GLTFState and just
	# work from there is beyond me, but believe me I tried.
	var og : Array[Material] = []
	for idx in range(mesh_instance.get_surface_override_material_count()):
		# Get mat
		var mat : Material = mesh_instance.get_surface_override_material(idx)
		og.append(mat)
		
		# Convert
		var new : StandardMaterial3D = StandardMaterial3D.new()
		if mat is ShaderMaterial:
			var type := mat.shader.resource_path as String
			var cull : bool = true if type == OPAQUE else false
			var transparency : bool = true if type == TRANSPARENT else false
			new.albedo_texture = mat.get_shader_parameter("albedoTex")
			new.cull_mode = BaseMaterial3D.CULL_BACK if cull else BaseMaterial3D.CULL_DISABLED
			new.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR if transparency else BaseMaterial3D.TRANSPARENCY_DISABLED
			mesh_instance.set_surface_override_material(idx, new)
			continue
		mesh_instance.set_surface_override_material(idx, mat)
	document.append_from_scene(mesh_instance, state, GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
	
	if OS.get_name() != "Web":
		%export_model.show()
		%export_model.file_selected.connect(func(path : String) -> void: document.write_to_filesystem(state, path))
	else:
		var buf := document.generate_buffer(state)
		JavaScriptBridge.download_buffer(buf, "model.gltf", "application/gltf+json")
	
	# Reconvert
	for idx in range(mesh_instance.get_surface_override_material_count()):
		mesh_instance.set_surface_override_material(idx, og[idx])
	
## Debug input
func _unhandled_input(event: InputEvent) -> void:
	# Filter input
	if !event is InputEventKey:
		return
	
	# Toggle for UV overlay
	event = event as InputEventKey
	if event.pressed && event.keycode == KEY_B:
		mesh_instance.material_overlay = placeholder_materials[0] if !mesh_instance.material_overlay else null 

## Prepares mesh array for data
func prepare_mesh_array(mda : Array) -> void:
	mda.clear()
	mda.resize(Mesh.ARRAY_MAX)
	mda[Mesh.ARRAY_VERTEX] = PackedVector3Array([])
	mda[Mesh.ARRAY_INDEX] = PackedInt32Array([])
	mda[Mesh.ARRAY_NORMAL] = PackedVector3Array([])
	mda[Mesh.ARRAY_TEX_UV] = PackedVector2Array([])

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

## Obtains material from array based on position
func obtain_material(mats : Array, pos : int) -> Material:
	# Determine position and fetch enum
	var x := pos if pos < 10 else pos - 10
	var y := (0 if pos < 10 else 1) if pos < 20 else 0
	var mat_enum = mats[x]
	if mat_enum is Array:
		mat_enum = mat_enum[y]
	else:
		print("Fence")
	
	# Now that we have enum, we need to determine what to return
	match max(pos-19, 0):
		# Fence mats
		1:	
			return MDat.fence_materials[mat_enum]
		# Pole mats
		2:	return placeholder_materials[11]
		# Bar mats
		3:	return placeholder_materials[12]
		# Water mats
		4:	return MDat.water_materials[mat_enum]
		# Default material
		_:	return MDat.materials[mat_enum] if MDat.materials[mat_enum] else placeholder_materials[mat_enum % 10] 

## Sets skybox.
func set_skybox(id : int) -> void:
	var mat : Material = MDat.sb_materials[id]
	skybox.set_surface_override_material(0, mat)

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

## Rotates UV
func rotate_uv(dir : Vector3, rot : int, uvs : PackedVector2Array) -> PackedVector2Array:
	var new_uvs := PackedVector2Array([])
	for uv in uvs:
		match dir:
			Vector3.DOWN:		new_uvs.append(uv.rotated(rot * (PI/2)))
			Vector3.UP:			new_uvs.append(uv.rotated(rot * (PI/2)))
			_:					new_uvs.append(uv)
	return new_uvs
