# boundary_builder.gd
@tool
class_name BoundaryBuilder extends Node

'''
Builds level boundaries when a level is finished parsing.
'''

## Terrain flags
const BOUNDARY_INNER_FLOOR : int =	1 << 0
const BOUNDARY_OUTER_FLOOR : int =	1 << 1
const BOUNDARY_INNER_WALLS : int =	1 << 2
const BOUNDARY_OUTER_WALLS : int =	1 << 3

## ArrayMesh format
const FORMAT = (
	ArrayMesh.ARRAY_FORMAT_VERTEX | 
	ArrayMesh.ARRAY_FORMAT_NORMAL |
	ArrayMesh.ARRAY_FORMAT_COLOR |
	ArrayMesh.ARRAY_FORMAT_INDEX
)

## Plane indices
const IND_PLANE : Array[int] = [0, 1, 2, 0, 2, 3]

## Default materials
const DEFAULT_MATS : Array = [
	preload("res://asset/mat/dirt.tres"),
	preload("res://asset/mat/grass.tres")
]

## Boundary types
const BOUNDARY_TABLE : Array = [
	# Void
	0,
	# Plain
	BOUNDARY_INNER_FLOOR | BOUNDARY_OUTER_FLOOR,
	# Valley
	BOUNDARY_INNER_FLOOR | BOUNDARY_OUTER_FLOOR | BOUNDARY_INNER_WALLS,
	# Chasm
	BOUNDARY_OUTER_FLOOR | BOUNDARY_INNER_WALLS,
	# Plataeu
	BOUNDARY_INNER_FLOOR | BOUNDARY_OUTER_WALLS
]

## Possible sizes
const SIZES : Array[int] = [
	32,
	48,
	64,
]

## Debug punchins
@export var size : int = 0 :
	set(value) : size = wrapi(value, 0, 3)
	get : return size
@export var height : int = 5 :
	set(value) : height = wrapi(value, 0, 65)
	get : return height
@export var type : int = 1 :
	set(value) : type = wrapi(value, 0, 5)
	get : return type
@export var generate : bool = false :
	set(value) : generate = false; build_mesh()
	get : return generate

## Mesh instance
@onready var mesh_instance := $boundary

## Builds a level boundary based on level boundary settings.
func build_boundary(result : MB64Level) -> void:
	# Create surface tool, get mat
	var theme := MDat.default_themes[result.theme]
	var mat_enums : Array = theme[result.boundary_mat]
	var mats : Array = [MDat.materials[mat_enums[0]], MDat.materials[mat_enums[1]]]
	size = result.size
	height = result.boundary_height
	type = result.boundary
	
	build_mesh(mats)
	
## Builds mesh with provided args
func build_mesh(mat : Array = DEFAULT_MATS) -> void:
	# Declare variables
	var floor_indice := 0
	var wall_indice := 0
	var st_floor := SurfaceTool.new()
	var st_wall := SurfaceTool.new()
	st_floor.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_wall.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Shift mesh instance
	mesh_instance.position = Vector3(16, 0, 16) - (Vector3(8, 0, 8) * size)
	
	# Create floor
	if (BOUNDARY_TABLE[type] & BOUNDARY_INNER_FLOOR):
		floor_indice = build_floor(st_floor, floor_indice, SIZES[size])
	
	# Create walls
	if (BOUNDARY_TABLE[type] & BOUNDARY_INNER_WALLS):
		wall_indice = build_walls(st_wall, wall_indice, SIZES[size], height, (BOUNDARY_TABLE[type] & BOUNDARY_INNER_FLOOR))
		if !(BOUNDARY_TABLE[type] & BOUNDARY_INNER_FLOOR):
			floor_indice = build_chasm(st_floor, floor_indice, SIZES[size])
	
	# Commit floor, walls
	var array_mesh := ArrayMesh.new()
	st_wall.commit(array_mesh, FORMAT)
	st_floor.commit(array_mesh, FORMAT)
	mesh_instance.mesh = array_mesh
	
	# Set materials
	var count := array_mesh.get_surface_count()
	for surface in range(array_mesh.get_surface_count()):
		array_mesh.surface_set_material(surface, mat[(surface + 1) if count == 1 else surface])
	
	print("Border generation complete")

## Builds floor of boundary
func build_floor(st : SurfaceTool, idc : int, floor_size : int) -> int:
	# Add verts
	var verts := [
		Vector3(0,0,1) * floor_size,
		Vector3(0,0,0) * floor_size,
		Vector3(1,0,0) * floor_size,
		Vector3(1,0,1) * floor_size
	]
	var uv := [
		Vector2(0,1) * floor_size,
		Vector2(1,1) * floor_size,
		Vector2(1,0) * floor_size,
		Vector2(0,0) * floor_size
	]
	for vtx in range(verts.size()):
		st.set_normal(Vector3.UP)
		st.set_smooth_group(-1)
		st.set_color(Color.WHITE)
		st.set_uv(uv[vtx])
		st.add_vertex(verts[vtx])
	
	# Add indices
	var ind := [0, 1, 2, 0, 2, 3]
	for i in ind:
		st.add_index(i)
	
	return idc + 4
	
## Builds walls of boundary
func build_walls(st : SurfaceTool, idc : int, f_s : int, w_h : int, floor : bool) -> int:
	# Declare variables
	var wall_verts := [
		Vector3(0, 0, 0 ),
		Vector3(0, 0, f_s),
		Vector3(0, w_h , f_s),
		Vector3(0, w_h , 0)
	]
	var chasm_verts := [
		Vector3(0, -16, 0 ),
		Vector3(0, -16, f_s),
		Vector3(0, 0, f_s),
		Vector3(0, 0, 0)
	]
	var uv := [
		Vector2(1*f_s,1*w_h),
		Vector2(0,1*w_h),
		Vector2(0,0),
		Vector2(1*f_s,0)
	]
	var uv_chasm := [
		Vector2(1*f_s,16),
		Vector2(0,16),
		Vector2(0,0),
		Vector2(1*f_s,0)
	]
	var idc_offset = idc
	
	# Add verts, indices for wall
	for rot in range(4):
		for vtx in range(wall_verts.size()):
			var vtx_rot = Meshbuilder.rotate_point(wall_verts[vtx], rot, f_s)
			st.set_normal(Meshbuilder.rotate_point(Vector3.LEFT, rot))
			st.set_smooth_group(-1)
			st.set_color(Color.WHITE)
			st.set_uv(uv[vtx])
			st.add_vertex(vtx_rot)
		
		# Add indices
		var ind = create_indice_offset(IND_PLANE, idc_offset) as Array[int]
		for i in ind:
			st.add_index(i)
		idc_offset += 4
	
	if floor:
		return idc_offset
	
	# Add verts, indices for chasm
	for rot in range(4):
		for vtx in range(chasm_verts.size()):
			var vtx_rot = Meshbuilder.rotate_point(chasm_verts[vtx], rot, f_s)
			st.set_normal(Meshbuilder.rotate_point(Vector3.LEFT, rot))
			st.set_smooth_group(-1)
			st.set_color(Color.BLACK if chasm_verts[vtx].y < 0 else Color.WHITE)
			st.set_uv(uv_chasm[vtx])
			st.add_vertex(vtx_rot)
		
		# Add indices
		var ind = create_indice_offset(IND_PLANE, idc_offset) as Array[int]
		for i in ind:
			st.add_index(i)
		idc_offset += 4
			
	return idc_offset

## Builds the boundary chasm
func build_chasm(st : SurfaceTool, idc : int, f_s : int) -> int:
	var chasm_floor_verts := [
		Vector3(0,-16,1*f_s),
		Vector3(0,-16,0),
		Vector3(1*f_s,-16,0),
		Vector3(1*f_s,-16,1*f_s)
	]
	var idc_offset = idc
	
	for vtx in range(chasm_floor_verts.size()):
		st.set_normal(Vector3.LEFT)
		st.set_smooth_group(-1)
		st.set_color(Color.BLACK)
		st.add_vertex(chasm_floor_verts[vtx])
	
	# Indices for chasm floor
	var ind = create_indice_offset(IND_PLANE, idc_offset) as Array[int]
	for i in ind:
		st.add_index(i)
	idc_offset += 4
			
	return idc_offset

## Builds outer floor of level
func build_outer_floor(st : SurfaceTool, idc : int, f_s : int, w_h : int) -> int:
	return 0

func create_indice_offset(array : Array, count : int) -> Array:
	var array_dupe = array.duplicate()
	for i in range(array.size()):
		array_dupe[i] += count
	return array_dupe
