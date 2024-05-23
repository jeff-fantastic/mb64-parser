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
	set(value) : if value >= 0 && value <= 255: version = value;
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
	set(value) : if value >= 0 && value <= 255: costume = value;
	get : return costume

## Music selection, 5 bytes, though only 3 are actually used
@export var music : PackedByteArray

@export_group("LevelTile")

@export_group("LevelObject")
