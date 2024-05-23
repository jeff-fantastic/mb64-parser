# song_config.gd
class_name SongConfig extends Window

'''
Configues the song selection for a level
'''

## Current [MB64Level] resource
var current_res : MB64Level :
	set(value) : current_res = value; prepare_backup(); update_fields()
	get : return current_res
## Backup fields
var backup_fields : PackedByteArray

## Updates dropdown and tree view of songs
func update_fields() -> void:
	pass

## Prepares backup fields
func prepare_backup() -> void:
	pass

## Generates tree list of songs
func generate_tree() -> void:
	pass

## Called when dropdown selection is changed
func dropdown_changed() -> void:
	pass

## Called when user requests to apply data change
func apply_pressed() -> void:
	pass

## Called when user denies data change
func cancel_pressed() -> void:
	pass
