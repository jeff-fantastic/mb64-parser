# ui.gd
class_name UI extends Control

'''
Manages self and sends signals to other
components, such as the parser
'''

## Default metadata string to format
const DEFAULT_METADATA : String = \
"""[fill][i]HeaderString: {header_string}
MB64Version: {mb64_version}

Vertices: {vert_percent}%
	 {vert_count}
Tiles: {tile_percent}%
	 {tile_count}"""

## Sent when a parse is requested
signal parse_requested(path : String)
## Sent when editing ability is changed
signal editing_changed(mode : bool)

## Whether or not editing is enabled
var edit_mode : bool = false :
	set(value) : edit_mode = value; editing_changed.emit(value)
	get : return edit_mode

func _ready() -> void:
	edit_mode = false

## Called when load level is pressed
func mb64_import_requested() -> void:
	%level_diag.show()
	
## Called when painting image is pressed
func painting_import_requested() -> void:
	%thumbnail_diag.show()

## Called when song config is requested
func open_song_config():
	%song_config_window.show()

## Called when level is selected
func mb64_selected(path : String) -> void:
	parse_requested.emit(path)

## Updates UI based on provided MB64Level resource
func update_ui(res : MB64Level) -> void:
	edit_mode = true
	%thumbnail.icon = ImageTexture.create_from_image(res.picture_img)
	%metadata.text = DEFAULT_METADATA.format(
		{
			"header_string" : res.file_header,
			"mb64_version" : res.version,
		}
	)
	%level_name.text = res.level_name
	%level_author.text = res.author
	%costume.selected = res.costume
	%song_config_window.current_res = res

## Toggles metadata window field visibility
func toggle_metadata_fields(mode : bool) -> void:
	%meta_container.visible = mode
	%meta_message.visible = !mode



