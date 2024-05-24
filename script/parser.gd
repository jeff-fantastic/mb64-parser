# parser.gd
class_name Parser extends Node

'''
Parses a .mb64 file, along with other operations
involving the .mb64 file format
'''

## Emitted when parsing complete
signal parsing_complete(result : MB64Level)

## Current path
var current_path : String = ""
## Current [MB64Level] resource
var current_res : MB64Level
## Current data buffer (unmodified byte data)
var current_buffer : PackedByteArray

func _ready() -> void:
	get_tree().root.files_dropped.connect(func(files : PackedStringArray): parse_file(files[0]))

## Parses a *.mb64 file.
func parse_file(path : String) -> void:
	# Declare variables
	var res = MB64Level.new()
	var file = FileAccess.open(path, FileAccess.READ)
	
	# Write buffer
	current_buffer = file.get_file_as_bytes(path)
	
	# Begin parsing
	res.level_name = path.get_file()
	res.file_header = file.get_buffer(0xA).get_string_from_ascii()
	res.version = file.get_8()
	res.author = file.get_buffer(0x1F).get_string_from_ascii()
	res.picture = file.get_buffer(8192)
	res.picture_img = build_image(res.picture)
	res.costume = file.get_8()
	res.music = file.get_buffer(5)
	res.envfx = file.get_8()
	res.theme = file.get_8()
	res.bg = file.get_8()
	res.boundary_mat = file.get_8()
	res.boundary = file.get_8()
	res.boundary_height = file.get_8()
	res.coinstar = file.get_8()
	res.size = file.get_8()
	res.waterlevel = file.get_8()
	res.secret = true if file.get_8() == 1 else false
	res.game = true if file.get_8() == 1 else false
	res.toolbar = file.get_buffer(0x9)
	res.toolbar_params = file.get_buffer(0x9)
	res.tile_count = file.get_16()
	res.object_count = file.get_16()
	
	# Set vars
	current_path = path
	current_res = res
	
	# End parsing, emit signal
	file.close()
	parsing_complete.emit(res)

## Parses a *.mb64 file, web exclusive
func parse_web_file(file_name : String, file_type : String, base64 : String) -> void:
	# Declare variables
	var res = MB64Level.new()
	var stream : StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = Marshalls.base64_to_raw(base64)
	print("MB64 stream : %0d" % stream.data_array.size())
	
	# Begin parsing
	res.level_name = file_name.rstrip(".mb64")
	res.file_header = PackedByteArray(stream.get_data(0xA)[1]).get_string_from_ascii()
	res.version = stream.get_u8()
	res.author = PackedByteArray(stream.get_data(0x1F)[1]).get_string_from_ascii()
	res.picture = PackedByteArray(stream.get_data(8192)[1])
	res.picture_img = build_image(res.picture)
	res.costume = stream.get_u8()
	res.music = PackedByteArray(stream.get_data(0x5)[1])
	res.envfx = stream.get_u8()
	res.theme = stream.get_u8()
	res.bg = stream.get_u8()
	res.boundary_mat = stream.get_u8()
	res.boundary = stream.get_u8()
	res.boundary_height = stream.get_u8()
	res.coinstar = stream.get_u8()
	res.size = stream.get_u8()
	res.waterlevel = stream.get_u8()
	res.secret = true if stream.get_u8() == 1 else false
	res.game = true if stream.get_u8() == 1 else false
	res.toolbar = PackedByteArray(stream.get_data(0x9)[1])
	res.toolbar_params = PackedByteArray(stream.get_data(0x9)[1])
	res.tile_count = stream.get_u16()
	res.object_count = stream.get_u16()
	
	# Debug print
	for property in res.get_property_list():
		print(res.get(property.name))
	
	# Set vars
	current_buffer = stream.data_array
	current_path = "./"
	current_res = res
	
	# End parsing, emit signal
	parsing_complete.emit(res)

## Writes metadata to file at path, then reloads
func write_meta(path : String) -> void:
	# Declare variables
	var facc : FileAccessWeb = FileAccessWeb.new()
	var res = current_res
	var new_name : String = path
	var new_data : StreamPeerBuffer = StreamPeerBuffer.new()
	
	# Begin writing to stream buffer
	new_data.put_data(prep_data(0xA, res.file_header.to_utf8_buffer()))
	new_data.put_u8(res.version)
	new_data.put_data(prep_data(0x1F, res.author.to_utf8_buffer()))
	new_data.put_data(res.picture)
	new_data.put_u8(res.costume)
	new_data.put_data(res.music)
	new_data.put_u8(res.envfx)
	new_data.put_u8(res.theme)
	new_data.put_u8(res.bg)
	new_data.put_u8(res.boundary_mat)
	new_data.put_u8(res.boundary)
	new_data.put_u8(res.boundary_height)
	new_data.put_u8(res.coinstar)
	new_data.put_u8(res.size)
	new_data.put_u8(res.waterlevel)
	new_data.put_u8(res.secret)
	new_data.put_u8(res.game)
	new_data.put_data(res.toolbar)
	new_data.put_data(res.toolbar_params)
	new_data.put_u16(res.tile_count)
	new_data.put_u16(res.object_count)
	new_data.put_data(current_buffer.slice(new_data.get_position()))
	
	# Export buffer to download if on web
	if !facc._is_not_web():
		JavaScriptBridge.download_buffer(new_data.data_array, res.level_name + ".mb64")
		print("File exported from web.")
		return
	
	# Otherwise just dump buffer into file
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(new_data.data_array)
	file.close()
	print("File exported successfully.")

## Builds an image from RGBA16 data
func build_image(data : PackedByteArray) -> Image:
	# Create blank image
	var image : Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	
	# Since Godot doesnt have RGBA16 conversion,
	# we'll have to do it ourselves!
	for byte in range(data.size()/2):
		# Obtain u16... but not using the default decode_u16
		# method as that returns bad data for some reason
		var u81 : int = data.decode_u8(byte*2) << 8
		var u82 : int = data.decode_u8(byte*2+1)
		var pixel : int = u81 | u82
		
		# Get RGBA values (5,5,5,1)
		var red : float = ((pixel >> 11) & 0x1F) / 31.0
		var green : float = ((pixel >> 6) & 0x1F) / 31.0
		var blue : float = ((pixel >> 1) & 0x1F) / 31.0
		var alpha : float = (pixel & 0x0001)
		
		# Write to image
		image.set_pixel(byte%64, int(byte/64), Color(red, green, blue, alpha))
	
	# Return image
	return image

## Creates RGBA16 image data from RGBA8 (32 bit) data
func overwrite_image(image : Image) -> PackedByteArray:
	# Create byte array
	var bytes : PackedByteArray = []
	bytes.resize(8192)
	image.convert(Image.FORMAT_RGBA8)
	
	# We're going to convert an RGBA8 (32 bit) image
	# into RGBA16 (16 bit, 5551)
	for byte in range(image.get_size().x * image.get_size().y):
		# Get color at pixel
		var color : Color = image.get_pixel(byte%64,int(byte/64))
		
		# Get each color byte
		var red : int = color.r8 / 8 * 2048
		var green : int = color.g8 / 8 * 64
		var blue : int = color.b8 / 8 * 2
		var alpha : int = 1 if color.a8 > 0 else 0
		
		# Create two bytes (u16) and put in array
		var value = red + green + blue + alpha
		bytes.encode_u8(byte*2, (value >> 8) & 0xFF)
		bytes.encode_u8(byte*2+1, value & 0xFF)
	
	# Return bytes
	return bytes

## Creates RGBA16 image data from web image
func overwrite_image_web(file_name : String, file_type : String, base64 : String) -> void:
	# Get array of bytes from base64
	var bytes : PackedByteArray = Marshalls.base64_to_raw(base64)
	var image : Image = Image.new()
	image.load_png_from_buffer(bytes)
	overwrite_image(image)

## Converts user image into valid painting dimensions (64x64)
func load_picture_for_import(path : String) -> void:
	# Load image, check for bad import
	var image = Image.new()
	var result : Error = image.load(path)
	if result != OK:
		push_error("Error when importing image, likely bad file format")
		return
	
	# Resize, overwrite, rebuild, signal
	image.resize(64, 64, Image.INTERPOLATE_NEAREST)
	current_res.picture = overwrite_image(image)
	current_res.picture_img = build_image(current_res.picture)
	parsing_complete.emit(current_res)

## Prepares empty space in a data packet
func prep_data(length : int, buf : PackedByteArray) -> PackedByteArray:
	var pad : PackedByteArray = []
	var target : int = length - buf.size()
	pad.resize(target)
	pad.fill(0)
	buf.append_array(pad)
	return buf

## Opens file save dialog
func open_save_dialog() -> void:
	# Declare variables
	var facc : FileAccessWeb = FileAccessWeb.new()
	
	# Non web save
	if facc._is_not_web():
		%export_dialog.current_path = current_path.get_base_dir() + "/"
		%export_dialog.current_file = current_res.level_name + ".mb64"
		%export_dialog.show()
		return
	
	# Otherwise just save
	write_meta("")

## SETTERS
##------------------------------------------------------------------------------

func set_level_name(new_name : String) -> void:
	current_res.level_name = new_name

func set_author(new_author: String) -> void:
	current_res.author = new_author

func set_costume(new_costume : int) -> void:
	current_res.costume = new_costume

func set_envfx(index : int) -> void:
	current_res.envfx = index

func set_theme(index : int) -> void:
	current_res.theme = index

func set_background(index : int) -> void:
	current_res.bg = index

func coin_star_changed(value : float) -> void:
	current_res.coinstar = int(value / 20)

func water_level_changed(value : float) -> void:
	current_res.waterlevel = int(value)

func secret_theme_toggled(toggled_on: bool) -> void:
	current_res.secret = toggled_on

func btcm_mode_toggled(toggled_on: bool) -> void:
	current_res.game = toggled_on

func bound_type_selected(index: int) -> void:
	current_res.boundary = index

func bound_height_changed(value: float) -> void:
	current_res.boundary_height = int(value)

func bound_mat_changed(value: float) -> void:
	current_res.boundary_mat = int(value)
