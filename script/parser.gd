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
## Raw data buffer, for web export
var web_buffer : PackedByteArray

func _ready() -> void:
	get_tree().root.files_dropped.connect(func(files : PackedStringArray): parse_file(files[0]))

## Parses a *.mb64 file.
func parse_file(path : String) -> void:
	# Declare variables
	var res = MB64Level.new()
	var file = FileAccess.open(path, FileAccess.READ)
	
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
	web_buffer = Marshalls.base64_to_raw(base64)
	var bytes_read : int = 0
	
	# Begin parsing
	res.level_name = file_name.rstrip(".mb64")
	res.file_header = web_buffer.slice(bytes_read, 0xA).get_string_from_ascii(); bytes_read += 0xA
	res.version = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.author = web_buffer.slice(bytes_read, 0x1F).get_string_from_ascii(); bytes_read += 0x1F
	res.picture = web_buffer.slice(bytes_read, 8192); bytes_read += 8192
	res.picture_img = build_image(res.picture)
	res.costume = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.music = web_buffer.slice(bytes_read, 0x5); bytes_read += 0x5
	res.envfx = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.theme = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.bg = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.boundary_mat = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.boundary = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.boundary_height = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.coinstar = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.size = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.waterlevel = web_buffer.decode_u8(bytes_read); bytes_read += 0x1
	res.secret = true if web_buffer.decode_u8(bytes_read) == 1 else false; bytes_read += 0x1
	res.game = true if web_buffer.decode_u8(bytes_read) == 1 else false; bytes_read += 0x1
	res.toolbar = web_buffer.slice(bytes_read, 0x9); bytes_read += 0x9
	res.toolbar_params = web_buffer.slice(bytes_read, 0x9); bytes_read += 0x9
	res.tile_count = web_buffer.decode_u16(bytes_read); bytes_read += 0x2
	res.object_count = web_buffer.decode_u16(bytes_read); bytes_read += 0x2
	
	# Set vars
	current_path = "./"
	current_res = res
	
	# End parsing, emit signal
	parsing_complete.emit(res)

## Writes metadata to file at path, then reloads
func write_meta(path : String) -> void:
	# Declare variables
	var res = current_res
	var base_file : PackedByteArray = FileAccess.get_file_as_bytes(current_path)
	var new_name : String = path
	var new_file = FileAccess.open(new_name, FileAccess.WRITE)
	
	# Begin writing
	new_file.store_buffer(prep_data(0xA, res.file_header.to_utf8_buffer()))
	new_file.store_8(res.version)
	new_file.store_buffer(prep_data(0x1F, res.author.to_utf8_buffer()))
	new_file.store_buffer(res.picture)
	new_file.store_8(res.costume)
	new_file.store_buffer(res.music)
	new_file.store_8(res.envfx)
	new_file.store_8(res.theme)
	new_file.store_8(res.bg)
	new_file.store_8(res.boundary_mat)
	new_file.store_8(res.boundary)
	new_file.store_8(res.boundary_height)
	new_file.store_8(res.coinstar)
	new_file.store_8(res.size)
	new_file.store_8(res.waterlevel)
	new_file.store_8(res.secret)
	new_file.store_8(res.game)
	new_file.store_buffer(res.toolbar)
	new_file.store_buffer(res.toolbar_params)
	new_file.store_16(res.tile_count)
	new_file.store_16(res.object_count)
	
	# End custom stuff, read rest from unmodified
	new_file.store_buffer(base_file.slice(new_file.get_position()))
	
	# Close file
	new_file.close()
	print("File saved successfully.")

## Web version of metadata writer
func write_meta_web(res : MB64Level) -> void:
	# Declare variables
	var bytes_written : int = 0
	var new_buf : PackedByteArray = []
	new_buf.resize(web_buffer.size())
	
	# Start writing to new buffer
	new_buf.append_array(prep_data(0xA, res.file_header.to_utf8_buffer())); bytes_written += 0xA
	new_buf.encode_u8(bytes_written, res.version); bytes_written += 0x1
	new_buf.append_array(prep_data(0x1F, res.author.to_utf8_buffer())); bytes_written += 0x1F
	new_buf.append_array(res.picture); bytes_written += 8192
	new_buf.encode_u8(bytes_written, res.costume); bytes_written += 0x1
	new_buf.append_array(res.music); bytes_written += 0x5
	new_buf.encode_u8(bytes_written, res.envfx); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.theme); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.bg); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.boundary_mat); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.boundary); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.boundary_height); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.coinstar); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.size); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.waterlevel); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.secret); bytes_written += 0x1
	new_buf.encode_u8(bytes_written, res.game); bytes_written += 0x1
	new_buf.append_array(res.toolbar); bytes_written += 0x9
	new_buf.append_array(res.toolbar_params); bytes_written += 0x9
	new_buf.encode_u16(bytes_written, res.tile_count); bytes_written += 0x2
	new_buf.encode_u16(bytes_written, res.object_count); bytes_written += 0x2
	
	# Splice old buf into new now
	new_buf.append_array(web_buffer.slice(bytes_written))
	JavaScriptBridge.download_buffer(new_buf, res.level_name + ".mb64")

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
	%export_dialog.current_path = current_path.get_base_dir() + "/"
	%export_dialog.current_file = current_res.level_name + ".mb64"
	%export_dialog.show()

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
