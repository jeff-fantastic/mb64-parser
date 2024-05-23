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
@export var tile_count : int :
	set(value) : if value >= 0 && value <= 0xFFFF: tile_count = value;
	get : return tile_count

## Object count, two bytes
@export var object_count : int :
	set(value) : if value >= 0 && value <= 0xFFFF: object_count = value;
	get : return object_count

@export_group("LevelTile")

@export_group("LevelObject")
