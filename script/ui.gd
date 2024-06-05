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
GridSize:	 {grid_size}x{grid_size}

TileCount: {tile_count}
ObjectCount: {object_count}
"""
## GitHub link
const GITHUB_LINK : String = "https://github.com/jeff-fantastic/mb64-parser"
## Show/hide icons
const _T_SHOW_HIDE = [
	preload("res://asset/gui/svg/show.svg"),
	preload("res://asset/gui/svg/hide.svg")
]

## Sent when a parse is requested
signal parse_requested(path : String)
## Sent when a model export is requested
signal export_requested()
## Sent when editing ability is changed
signal editing_changed(mode : bool)

## File access web
@onready var facc = FileAccessWeb.new()

## Whether or not editing is enabled
var edit_mode : bool = false :
	set(value) : edit_mode = value; editing_changed.emit(value)
	get : return edit_mode

func _ready() -> void:
	edit_mode = false

## Called when load level is pressed
func mb64_import_requested() -> void:
	# Normal import if on client
	if facc._is_not_web():
		%level_diag.show()
		return
	
	# Otherwise queue import
	facc.loaded.connect(%parser.parse_web_file.bind(), CONNECT_ONE_SHOT)
	facc.open(".mb64")
	
## Called when painting image is pressed
func painting_import_requested() -> void:
	if facc._is_not_web():
		%thumbnail_diag.show()
		return
	
	facc.loaded.connect(%parser.overwrite_image_web.bind(), CONNECT_ONE_SHOT)
	facc.open(".png")

## Called when song config is requested
func open_song_config():
	%song_config_window.show()

## Called when GitHub button is pressed
func open_github_repo() -> void:
	if facc._is_not_web():
		OS.shell_open(GITHUB_LINK)
	else:
		JavaScriptBridge.eval("window.location.href='%s'" % GITHUB_LINK, false)
		

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
			"grid_size" : 32 + 16 * res.size,
			"tile_count" : res.tile_count,
			"object_count" : res.object_count
		}
	)
	%level_name.text = res.level_name
	%level_author.text = res.author
	%costume.selected = res.costume
	%song_config_window.current_res = res
	%environment.selected = res.envfx
	%theme.selected = res.theme
	%background.selected = res.bg
	%coin_star.value = res.coinstar * 20
	%water_level.value = res.waterlevel
	%secret_theme.button_pressed = res.secret
	%btcm_mode.button_pressed = res.game
	%bound_type.selected = res.boundary
	%bound_height.value = res.boundary_height
	%bound_mat.value = res.boundary_mat
	%tab_bar.current_tab = 1

## Toggles window field visibility
func toggle_metadata_fields(mode : bool) -> void:
	%meta_container.visible = mode
	%model_container.visible = mode
	%meta_message.visible = !mode
	%model_message.visible = !mode

func show_hide_toggle(toggled_on: bool) -> void:
	var tw := create_tween()
	if toggled_on:
		%showhide.icon = _T_SHOW_HIDE[1]
		%main_win_anim.play("showhide")
		tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tw.tween_property(%main_win, "position:x", %ui.size.x, 0.5).from(%ui.size.x - 325)
	else:
		%showhide.icon = _T_SHOW_HIDE[0]
		%main_win_anim.play_backwards("showhide")
		tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tw.tween_property(%main_win, "position:x", %ui.size.x - 325, 0.5)

func tab_changed(tab: int) -> void:
	match tab:
		# Import tab
		0:
			%tab_import.visible = true
			%tab_metadata.visible = false
			%tab_model.visible = false
			%tab_info.visible = false
		1:
			%tab_import.visible = false
			%tab_metadata.visible = true
			%tab_model.visible = false
			%tab_info.visible = false
		2:
			%tab_import.visible = false
			%tab_metadata.visible = false
			%tab_model.visible = true
			%tab_info.visible = false
		4:
			%tab_import.visible = false
			%tab_metadata.visible = false
			%tab_model.visible = false
			%tab_info.visible = true

func export_request() -> void:
	export_requested.emit()
