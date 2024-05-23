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
	print(file.get_position())
	res.picture = file.get_buffer(8192)
	res.picture_img = build_image(res.picture)
	# @bug
	# Seems like a weird inconsistency between the struct and
	# how the file is saved. Painting is offset by 43 bytes instead
	# of the expected 42
	res.costume = file.get_8()
	res.music = file.get_buffer(5)
	
	# End parsing, emit signal
	file.close()
	parsing_complete.emit(res)
	
	# Set vars
	current_path = path
	current_res = res

## Writes metadata to file at path, then reloads
func write_meta():
	# Declare variables
	var res = current_res
	var base_file : PackedByteArray = FileAccess.get_file_as_bytes(current_path)
	var new_name : String = current_path.get_base_dir().path_join(res.level_name + ".mb64") 
	var new_file = FileAccess.open(new_name, FileAccess.WRITE)
	
	# Begin writing
	new_file.store_buffer(res.file_header.rpad(0xA).to_ascii_buffer())
	new_file.store_8(res.version)
	new_file.store_buffer(res.author.rpad(0x1F).to_ascii_buffer())
	new_file.store_buffer(res.picture)
	new_file.store_8(res.costume)
	new_file.store_buffer(res.music)
	
	# End custom stuff, read rest from unmodified
	new_file.store_buffer(base_file.slice(new_file.get_position()))
	
	# Close file
	new_file.close()
	print("File saved successfully.")

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

## SETTERS
##------------------------------------------------------------------------------

func set_level_name(new_name : String) -> void:
	current_res.level_name = new_name

func set_author(new_author: String) -> void:
	current_res.author = new_author
