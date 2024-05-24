GDPC                �
                                                                         T   res://.godot/exported/133200997/export-2c9d660a8f7e2c62577ddcd6fc2207d5-ui_theme.res�J      	      Qm��5�����y��5e    P   res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn@�      �5      �Y$u���.�F�IQ�03    `   res://.godot/exported/133200997/export-377efd6eca0b0da0ee0a32e6a29f411e-upload_file_example.scn �      C      ��zoVZV-\�hE`ZX    `   res://.godot/exported/133200997/export-a185f18a5cb5abed0b64d6a429edcecc-song_config_window.scn  0�      j	      <�ʃ9�G��b;�ơ    `   res://.godot/exported/133200997/export-a2f3f81d3116925ac6ae30de373dd90d-upload_image_example.scnp(      }      f�t��$�%Dn���    d   res://.godot/exported/133200997/export-fd26c97c4e59e8eff4ea97bb215687fa-upload_to_server_example.scn A      A      �'Y�Ƃ?�-�N�M��    ,   res://.godot/global_script_class_cache.cfg  `�      r      %=�3� � vj&��̤    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctexP�            ：Qt�E�cO���    T   res://.godot/imported/thumb_placeholder.png-6c2a1473e74c9c95653922f94ea81684.ctex   pE      p      ��/�^��LS��vR�       res://.godot/uid_cache.bin  ��      �       γҨ�HU��<�,��R    4   res://addons/FileAccessWeb/core/file_access_web.gd          �      �W�m��̧��2�$�    <   res://addons/FileAccessWeb/examples/upload_file_example.gd  �      P      �i��T��]��1 ў    D   res://addons/FileAccessWeb/examples/upload_file_example.tscn.remap  ��      p       F(��`*�o�i    <   res://addons/FileAccessWeb/examples/upload_image_example.gd 0"      7      �?߹�zrx�VG�g�    D   res://addons/FileAccessWeb/examples/upload_image_example.tscn.remap �      q       ��GPZ�!��`���$�    @   res://addons/FileAccessWeb/examples/upload_to_server_example.gd �9      -      ����w��'�V���߄    H   res://addons/FileAccessWeb/examples/upload_to_server_example.tscn.remap ��      u       �/O����9~��7&    ,   res://asset/gui/thumb_placeholder.png.import�I      �       D<<�寧�4%��|u        res://asset/ui_theme.tres.remap �      e       %�I!4�J=�p$��M       res://icon.svg  ��      �      k����X3Y���f       res://icon.svg.import   p�      �       鼢p���<����W]h       res://main.tscn.remap   ��      a       �J�Sw� ������       res://project.binary@�            Ր-�u��$v�����       res://script/parser.gd  �S      �!      8%��c4�=/���*       res://script/res_mb64.gd`u      �      ��m��8����Ū�       res://script/song_config.gd 0�      �      ����g��)�ā#F�       res://script/ui.gd  ��      i	      D���w�laabCu7    $   res://song_config_window.tscn.remap ��      o       	b�ʺi���t!��        class_name FileAccessWeb
extends RefCounted

signal load_started(file_name: String)
signal loaded(file_name: String, file_type: String, base64_data: String)
signal progress(current_bytes: int, total_bytes: int)
signal error()

var _file_uploading: JavaScriptObject

var _on_file_load_start_callback: JavaScriptObject
var _on_file_loaded_callback: JavaScriptObject
var _on_file_progress_callback: JavaScriptObject
var _on_file_error_callback: JavaScriptObject

func _init() -> void:
	if _is_not_web():
		_notify_error()
		return
	
	JavaScriptBridge.eval(js_source_code, true)
	_file_uploading = JavaScriptBridge.get_interface("godotFileAccessWeb")
	
	_on_file_load_start_callback = JavaScriptBridge.create_callback(_on_file_load_start)
	_on_file_loaded_callback = JavaScriptBridge.create_callback(_on_file_loaded)
	_on_file_progress_callback = JavaScriptBridge.create_callback(_on_file_progress)
	_on_file_error_callback = JavaScriptBridge.create_callback(_on_file_error)
	
	_file_uploading.setLoadStartCallback(_on_file_load_start_callback)
	_file_uploading.setLoadedCallback(_on_file_loaded_callback)
	_file_uploading.setProgressCallback(_on_file_progress_callback)
	_file_uploading.setErrorCallback(_on_file_error_callback)

func open(accept_files: String = "*") -> void:
	if _is_not_web():
		_notify_error()
		return
	
	_file_uploading.setAcceptFiles(accept_files)
	_file_uploading.open()

func _is_not_web() -> bool:
	return OS.get_name() != "Web"

func _notify_error() -> void:
	push_error("File Access Web worked only for HTML5 platform export!")

func _on_file_load_start(args: Array) -> void:
	var file_name: String = args[0]
	load_started.emit(file_name)

func _on_file_loaded(args: Array) -> void:
	var file_name: String = args[0]
	var splitted_args: PackedStringArray = args[1].split(",", true, 1)
	var file_type: String = splitted_args[0].get_slice(":", 1). get_slice(";", 0)
	var base64_data: String = splitted_args[1]
	loaded.emit(file_name, file_type, base64_data)

func _on_file_progress(args: Array) -> void:
	var current_bytes: int = args[0]
	var total_bytes: int = args[1]
	progress.emit(current_bytes, total_bytes)

func _on_file_error(args: Array) -> void:
	error.emit()

const js_source_code = """
function godotFileAccessWebStart() {
	var loadedCallback;
	var progressCallback;
	var errorCallback;
	var loadStartCallback;

	var input = document.createElement("input");
	input.setAttribute("type", "file")

	var interface = {
		setLoadedCallback: (loaded) => loadedCallback = loaded,
		setProgressCallback: (progress) => progressCallback = progress,
		setErrorCallback: (error) => errorCallback = error,
		setLoadStartCallback: (start) => loadStartCallback = start,

		setAcceptFiles: (files) => input.setAttribute("accept", files),
		open: () => input.click()
	}
	
	input.onchange = (event) => {
		var file = event.target.files[0];
		
		var reader = new FileReader();
		reader.readAsDataURL(file)

		reader.onloadstart = (loadStartEvent) => {
			loadStartCallback(file.name);
		}

		reader.onload = (readerEvent) => {
			if (readerEvent.target.readyState === FileReader.DONE) {
				loadedCallback(file.name, readerEvent.target.result);
			}
		}
		
		reader.onprogress = (progressEvent) => {
			if (progressEvent.lengthComputable)
				progressCallback(progressEvent.loaded, progressEvent.total);
		}

		reader.onerror = (errorEvent) => {
			errorCallback();
		}
	}

	return interface;
}

var godotFileAccessWeb = godotFileAccessWebStart();
"""

     class_name UploadFileExample
extends Control

@onready var upload_button: Button = %"Upload Button" as Button
@onready var progress: ProgressBar = %"Progress Bar" as ProgressBar
@onready var success_label: Label = %"Success Label" as Label

var file_access_web: FileAccessWeb = FileAccessWeb.new()

func _ready() -> void:
	upload_button.pressed.connect(_on_upload_pressed)
	file_access_web.load_started.connect(_on_file_load_started)
	file_access_web.loaded.connect(_on_file_loaded)
	file_access_web.progress.connect(_on_progress)
	file_access_web.error.connect(_on_error)

func _on_file_load_started(file_name: String) -> void:
	progress.visible = true
	success_label.visible = false

func _on_upload_pressed() -> void:
	file_access_web.open()

func _on_progress(current_bytes: int, total_bytes: int) -> void:
	var percentage: float = float(current_bytes) / float(total_bytes) * 100
	progress.value = percentage

func _on_file_loaded(file_name: String, type: String, base64_data: String) -> void:
	progress.visible = false
	success_label.visible = true

func _on_error() -> void:
	push_error("Error!")

RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom 	   bg_color    draw_center    skew    border_width_left    border_width_top    border_width_right    border_width_bottom    border_color    border_blend    corner_radius_top_left    corner_radius_top_right    corner_radius_bottom_right    corner_radius_bottom_left    corner_detail    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    shadow_color    shadow_size    shadow_offset    anti_aliasing    anti_aliasing_size    script 	   _bundled       Script ;   res://addons/FileAccessWeb/examples/upload_file_example.gd ��������	      local://StyleBoxFlat_3h46t �         local://StyleBoxFlat_k6sdq          local://StyleBoxFlat_v0hm0 x         local://StyleBoxFlat_eqd2r �         local://StyleBoxFlat_owjfu          local://StyleBoxFlat_t5wel ;         local://StyleBoxFlat_yx3xo p         local://StyleBoxFlat_fwgxq �         local://PackedScene_h2jub �         StyleBoxFlat                        �?	         
                                    StyleBoxFlat                        �?	         
                                    StyleBoxFlat          ��,>��,>��,>  �?	         
                                    StyleBoxFlat          ���>���>���>  �?         StyleBoxFlat                       StyleBoxFlat                        �?         StyleBoxFlat          ��H>���>��8?  �?         StyleBoxFlat              	         
                                    PackedScene          	         names "   +      Upload File Example    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    Window Background    anchor_left    anchor_top    offset_left    offset_top    offset_right    offset_bottom    theme_override_styles/panel    Panel    Margin Container %   theme_override_constants/margin_left $   theme_override_constants/margin_top &   theme_override_constants/margin_right '   theme_override_constants/margin_bottom    MarginContainer    VBoxContainer    Upload Button    unique_name_in_owner    custom_minimum_size    theme_override_styles/normal    theme_override_styles/hover    theme_override_styles/pressed    theme_override_styles/focus    text    Button    Progress Bar    visible !   theme_override_styles/background    theme_override_styles/fill    ProgressBar    Borders    Success Label !   theme_override_colors/font_color    Label    	   variants    "                    �?                                  ?      �      C     ��             
         
          B                                          Upload File        
     �C         �@     �C     B                                       �B     C     B       ��v?      �?   	   Success!       node_count             nodes     �   ��������       ����                                                             	   ����               
                                       	      
                                      ����
                                                                                ����                    !      ����                                                               &   "   ����         #                                                            $      %                    '   ����                                                        *   (   ����         #                                                            )           !             conn_count              conns               node_paths              editable_instances              version             RSRC             class_name UploadImageExample
extends Control

@onready var upload_button: Button = %"Upload Button" as Button
@onready var canvas: TextureRect = %Canvas as TextureRect
@onready var progress: ProgressBar = %"Progress Bar" as ProgressBar

var file_access_web: FileAccessWeb = FileAccessWeb.new()
var image_type: String = ".jpg"

func _ready() -> void:
	upload_button.pressed.connect(_on_upload_pressed)
	file_access_web.loaded.connect(_on_file_loaded)
	file_access_web.progress.connect(_on_progress)

func _on_upload_pressed() -> void:
	file_access_web.open(image_type)

func _on_progress(current_bytes: int, total_bytes: int) -> void:
	var percentage: float = float(current_bytes) / float(total_bytes) * 100
	progress.value = percentage

func _on_file_loaded(file_name: String, type: String, base64_data: String) -> void:
	var raw_data: PackedByteArray = Marshalls.base64_to_raw(base64_data)
	raw_draw(type, raw_data)

func raw_draw(type: String, data: PackedByteArray) -> void:
	var image := Image.new()
	var error: int = _load_image(image, type, data)
	
	if not error:
		canvas.texture = _create_texture_from(image)
	else:
		push_error("Error %s id" % error)

func _load_image(image: Image, type: String, data: PackedByteArray) -> int:
	match type:
		"image/png":
			return image.load_png_from_buffer(data)
		"image/jpeg":
			return image.load_jpg_from_buffer(data)
		"image/webp":
			return image.load_webp_from_buffer(data)
		_:
			return Error.FAILED

func _create_texture_from(image: Image) -> ImageTexture:
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

         RSRC                    PackedScene            ��������                                                   resource_local_to_scene    resource_name    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom 	   bg_color    draw_center    skew    border_width_left    border_width_top    border_width_right    border_width_bottom    border_color    border_blend    corner_radius_top_left    corner_radius_top_right    corner_radius_bottom_right    corner_radius_bottom_left    corner_detail    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    shadow_color    shadow_size    shadow_offset    anti_aliasing    anti_aliasing_size    script    image 	   _bundled       Script <   res://addons/FileAccessWeb/examples/upload_image_example.gd ��������      local://StyleBoxFlat_3h46t          local://StyleBoxFlat_7ifsm l         local://StyleBoxFlat_k6sdq �         local://StyleBoxFlat_v0hm0 6         local://StyleBoxFlat_eqd2r �         local://StyleBoxFlat_owjfu �         local://ImageTexture_yurbi �         local://StyleBoxFlat_t5wel          local://StyleBoxFlat_yx3xo K         local://StyleBoxFlat_fwgxq �         local://PackedScene_c88yu �         StyleBoxFlat                        �?	         
                                    StyleBoxFlat                        �?	         
                                    StyleBoxFlat                        �?	         
                                    StyleBoxFlat          ��,>��,>��,>  �?	         
                                    StyleBoxFlat          ���>���>���>  �?         StyleBoxFlat                       ImageTexture             StyleBoxFlat                        �?         StyleBoxFlat          ��H>���>��8?  �?         StyleBoxFlat              	         
                                    PackedScene          	         names "   .      Upload Image Example    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    Window Background    anchor_left    anchor_top    offset_left    offset_top    offset_right    offset_bottom    theme_override_styles/panel    Panel    Margin Container %   theme_override_constants/margin_left $   theme_override_constants/margin_top &   theme_override_constants/margin_right '   theme_override_constants/margin_bottom    MarginContainer    Content Background    clip_contents    VBoxContainer    Upload Button    unique_name_in_owner    custom_minimum_size    theme_override_styles/normal    theme_override_styles/hover    theme_override_styles/pressed    theme_override_styles/focus    text    Button    Canvas    size_flags_vertical    texture    expand_mode    TextureRect    Progress Bar !   theme_override_styles/background    theme_override_styles/fill    ProgressBar    Borders    	   variants                        �?                                  ?      �      C             
                  
          B                                          Upload File          
     �C               ��C     �C     �C                        	         node_count    
         nodes     �   ��������       ����                                                             	   ����               
                                       	      	                  
                    ����               
                                       	      	                                                        ����                                      ����
                                                                                ����                    #      ����                                        !      "                 (   $   ����               %       &      '                  ,   )   ����                                       *      +                    -   ����                                                       conn_count              conns               node_paths              editable_instances              version             RSRC   class_name UploadToServerExample
extends Control

@onready var upload_image_example: UploadImageExample = $"Upload Image Example" as UploadImageExample
@onready var http: HTTPRequest = $HTTPRequest as HTTPRequest

var url: String = "http://localhost:5072/images"

func _ready() -> void:
	upload_image_example.file_access_web.loaded.connect(_on_file_loaded)
	http.request_completed.connect(_on_request_completed)

func _on_file_loaded(file_name: String, type: String, base64_data: String) -> void:
	_send_to_server(file_name, type, base64_data)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print(body.get_string_from_ascii())

func _send_to_server(file_name: String, file_type: String, file_base64: String) -> void:
	const boundary: String = "GodotFileUploadBoundaryZ29kb3RmaWxl"
	var headers = [ "Content-Type: multipart/form-data; boundary=%s" % boundary]
	var body = _form_data_packet(boundary, "image", file_name, file_type, file_base64)
	http.request_raw(url, headers, HTTPClient.METHOD_PUT, body)

func _form_data_packet(boundary: String, endpoint_argument_name: String, file_name: String, file_type: String, file_base64: String) -> PackedByteArray:	
	var packet := PackedByteArray()
	var boundary_start = ("\r\n--%s" % boundary).to_utf8_buffer()
	var disposition = ("\r\nContent-Disposition: form-data; name=\"%s\"; filename=\"%s\"" % [endpoint_argument_name, file_name]).to_utf8_buffer()
	var content_type = ("\r\nContent-Type: %s\r\n\r\n" % file_type).to_utf8_buffer()
	var boundary_end = ("\r\n--%s--\r\n" % boundary).to_utf8_buffer()

	packet.append_array(boundary_start)
	packet.append_array(disposition)
	packet.append_array(content_type)
	packet.append_array(Marshalls.base64_to_raw(file_base64))
	packet.append_array(boundary_end)
	return packet
   RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script @   res://addons/FileAccessWeb/examples/upload_to_server_example.gd ��������   PackedScene >   res://addons/FileAccessWeb/examples/upload_image_example.tscn ��i�x_*      local://PackedScene_h0mkb �         PackedScene          	         names "         Upload To Server Example    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    Upload Image Example    HTTPRequest    	   variants                        �?                                     node_count             nodes     %   ��������       ����                                                          ���	                           
   
   ����              conn_count              conns               node_paths              editable_instances              version             RSRC               GST2   @   @      ����               @ @        8  RIFF0  WEBPVP8L$  /?� O帶m'9�}`=0g�o�t�k���8�$G��91{h���	XAl�b#I���8��M��W��C��;�� �qx��c�9�Ѓ�`x��>:6=`c0P$PPl�		YP��@��҃����c�0`0		�1d�����ב,h�?�@c�`>`0y��?���Y�n�Z=�u�UD�w%����ev��()�i�B��CDU�$ED�������I����Y6)J%)��B����)�>��C=/Q%EDI!EDI�;��R@��j�N��I*�V���e����N�����������_�?n�w�m$�@��1�'ħKM�%GJ��n�$I�1�Nq�Hֺ����(nwW$2�VGF���9l�����b��94lFell,2�1=L�H[W�ޤi����{Xt����--�zK8�Z0��;�ۃ���-z����ǰ����'�
�e8Ma�z������:�@oƸ(�~�җ&�ʚ�Ϋ ����,F8[ ��O �d	S�uY� ����+g�������Ylq3�x���ht>��ч4s�Fiܝ����`9f�PJc�[G��A�i�\��]p����%��X����W���A ��?�*��! ?�f	1`�y��>Bkh��tg��t�C��5`��0_3�(�X�ͼ�B�0��|��z��r�F����=�m��p�u
��Q�wW,~.�r0�8�������s�~��	�wlP��	����d�h��.^?)�]"�Txݼ�6�t�pP^�l�"�Q�rؤ���_�cJ/.����˗k��D�Ov�S��ǡ��5^�@�������R��q.Q�s\���7�s.:(�=>���[.mQ�1t������w�s8a�"��x����Kث@DP�>�+�oP���(��($N@fC^�$&k�'LO��d��Cc!a�g�����PSVS�Km)KI-K�?�JKK���646i�^�EcM�5\��ٺ�k�����3={|LBRr������J�R+��MUUdYU�5�$9%Y�$��=99)>����� [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://c2psown8f2nhy"
path="res://.godot/imported/thumb_placeholder.png-6c2a1473e74c9c95653922f94ea81684.ctex"
metadata={
"vram_texture": false
}
   RSRC                    Theme            ��������                                            /      resource_local_to_scene    resource_name    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom 	   bg_color    draw_center    skew    border_width_left    border_width_top    border_width_right    border_width_bottom    border_color    border_blend    corner_radius_top_left    corner_radius_top_right    corner_radius_bottom_right    corner_radius_bottom_left    corner_detail    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    shadow_color    shadow_size    shadow_offset    anti_aliasing    anti_aliasing_size    script    color    grow_begin 	   grow_end 
   thickness 	   vertical    default_base_scale    default_font    default_font_size    Button/styles/hover    Button/styles/normal    Button/styles/pressed    HSeparator/styles/separator    PanelContainer/styles/panel +   RichTextLabel/font_sizes/italics_font_size *   RichTextLabel/font_sizes/normal_font_size    Tree/constants/v_separation    Tree/font_sizes/font_size           local://StyleBoxFlat_vruoc s         local://StyleBoxFlat_3ockb          local://StyleBoxFlat_vmvlm �         local://StyleBoxLine_83gam V         local://StyleBoxFlat_6kvsa �         local://Theme_2las8 �         StyleBoxFlat            �@        �@        �@        �@      fff>fff>fff>��?                                                      StyleBoxFlat             A        �@         A        �@      ���=���=���=��?                                                      StyleBoxFlat            �@        �@        �@        �@                  ��?                                                      StyleBoxLine 	           �@                  �@                %\ ?6\ ?%\ ?  �?         �          �!                  StyleBoxFlat             A         A         A         A      ���=���=���=��?                                                      Theme 
   &             '            (            )            *            +         ,         -         .               RSRC      # parser.gd
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
	var data : PackedByteArray = Marshalls.base64_to_raw(base64)
	var bytes_read : int = 0
	
	# Begin parsing
	res.level_name = file_name.rstrip(".mb64")
	res.file_header = data.slice(bytes_read, 0xA).get_string_from_ascii(); bytes_read += 0xA
	res.version = data.decode_u8(bytes_read); bytes_read += 0x1
	res.author = data.slice(bytes_read, 0x1F).get_string_from_ascii(); bytes_read += 0x1F
	res.picture = data.slice(bytes_read, 8192); bytes_read += 8192
	res.picture_img = build_image(res.picture)
	res.costume = data.decode_u8(bytes_read); bytes_read += 0x1
	res.music = data.slice(bytes_read, 0x5); bytes_read += 0x1
	res.envfx = data.decode_u8(bytes_read); bytes_read += 0x1
	res.theme = data.decode_u8(bytes_read); bytes_read += 0x1
	res.bg = data.decode_u8(bytes_read); bytes_read += 0x1
	res.boundary_mat = data.decode_u8(bytes_read); bytes_read += 0x1
	res.boundary = data.decode_u8(bytes_read); bytes_read += 0x1
	res.boundary_height = data.decode_u8(bytes_read); bytes_read += 0x1
	res.coinstar = data.decode_u8(bytes_read); bytes_read += 0x1
	res.size = data.decode_u8(bytes_read); bytes_read += 0x1
	res.waterlevel = data.decode_u8(bytes_read); bytes_read += 0x1
	res.secret = true if data.decode_u8(bytes_read) == 1 else false; bytes_read += 0x1
	res.game = true if data.decode_u8(bytes_read) == 1 else false; bytes_read += 0x1
	res.toolbar = data.slice(bytes_read, 0x9); bytes_read += 0x9
	res.toolbar_params = data.slice(bytes_read, 0x9); bytes_read += 0x9
	res.tile_count = data.decode_u16(bytes_read); bytes_read += 0x2
	res.object_count = data.decode_u16(bytes_read); bytes_read += 0x2
	
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
   # res_mb64.gd
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
      # song_config.gd
class_name SongConfig extends Window

'''
Configues the song selection for a level
'''

## 1.0.0's list of music names
const music : Array[String] = [
	## Vanilla, 14 tracks
	"Bob-omb Battlefield",
	"Slider",
	"Dire, Dire Docks",
	"Dire, Dire Docks (Underwater)",
	"Lethal Lava Land",
	"Cool, Cool Mountain",
	"Big Boo's Haunt",
	"Hazy Maze Cave",
	"Hazy Maze Cave (Haze)",
	"Koopa's Road",
	"Stage Boss",
	"Koopa's Theme",
	"Ultimate Koopa",
	"Inside the Castle Walls",
	
	## BTCM, also 14 tracks
	"Cosmic Castle",
	"Red-Hot Reservoir",
	"Lonely Floating Farm",
	"Jurassic Savanna",
	"The Phantom Strider",
	"Virtuaplex",
	"Immense Residence",
	"Thwomp Towers",
	"Cursed Boss",
	"Road To The Boss",
	"Urbowser",
	"The Show's Finale",
	"Parasite Moon",
	"AGAMEMNON",
	
	## Imports, 68 tracks
	"Bianco Hills (Super Mario Sunshine)",
	"Sky and Sea (Super Mario Sunshine)",
	"Secret Course (Super Mario Sunshine)",
	"Comet Observatory (Mario Galaxy)",
	"Buoy Base Galaxy (Mario Galaxy)",
	"Battlerock Galaxy (Mario Galaxy)",
	"Ghostly Galaxy (Mario Galaxy)",
	"Purple Comet (Mario Galaxy)",
	"Honeybloom Galaxy (Mario Galaxy 2)",
	"Piranha Creeper Creek (3D World)",
	"Desert (New Super Mario Bros.)",

	"Koopa Troopa Beach (Mario Kart 64)",
	"Frappe Snowland (Mario Kart 64)",
	"Bowser's Castle (Mario Kart 64)",
	"Rainbow Road (Mario Kart 64)",
	"Waluigi Pinball (Mario Kart DS)",
	"Rainbow Road (Mario Kart 8)",

	"Mario's Pad (Super Mario RPG)",
	"Nimbus Land (Super Mario RPG)",
	"Forest Maze (Super Mario RPG)",
	"Sunken Ship (Super Mario RPG)",

	"Dry Dry Desert (Paper Mario 64)",
	"Forever Forest (Paper Mario 64)",
	"Petal Meadows (Paper Mario: TTYD)",
	"Riddle Tower (Paper Mario: TTYD)",
	"Rogueport Sewers (Paper Mario: TTYD)",
	"X-Naut Fortress (Paper Mario: TTYD)",
	"Flipside (Super Paper Mario)",
	"Lineland Road (Super Paper Mario)",
	"Sammer Kingdom (Super Paper Mario)",
	"Floro Caverns (Super Paper Mario)",
	"Overthere Stair (Super Paper Mario)",

	"Yoshi's Tropical Island (Mario Party)",
	"Rainbow Castle (Mario Party)",
	"Behind Yoshi Village (Partners in Time)",
	"Gritzy Desert (Partners in Time)",
	"Bumpsy Plains (Bowser's Inside Story)",
	"Deep Castle (Bowser's Inside Story)",

	"Overworld (Yoshi's Island)",
	"Underground (Yoshi's Island)",
	"Title (Yoshi's Story)",

	"Kokiri Forest (Ocarina of Time)",
	"Lost Woods (Ocarina of Time)",
	"Gerudo Valley (Ocarina of Time)",
	"Stone Tower Temple (Majora's Mask)",
	"Outset Island (Wind Waker)",
	"Lake Hylia (Twilight Princess)",
	"Gerudo Desert (Twilight Princess)",
	"Skyloft (Skyward Sword)",

	"Frantic Factory (Donkey Kong 64)",
	"Hideout Helm (Donkey Kong 64)",
	"Creepy Castle (Donkey Kong 64)",
	"Gloomy Galleon (Donkey Kong 64)",
	"Fungi Forest (Donkey Kong 64)",
	"Crystal Caves (Donkey Kong 64)",
	"Angry Aztec (Donkey Kong 64)",
	"In a Snow-Bound Land (DKC 2)",

	"Bubblegloop Swamp (Banjo-Kazooie)",
	"Freezeezy Peak (Banjo-Kazooie)",
	"Gobi's Valley (Banjo-Kazooie)",

	"Factory Inspection (Kirby 64)",
	"Green Garden (Bomberman 64)",
	"Black Fortress (Bomberman 64)",
	"Windy Hill (Sonic Adventure)",
	"Sky Tower (Pokemon Mystery Dungeon)",
	"Youkai Mountain (Touhou 10)",
	"Forest Temple (Final Fantasy VII)",
	# "Band Land is love, Band Land is life" I say, shovelling dry ass chalk 
	# into my mouth, similar to that of a derranged lunatic
	"Band Land (Rayman)", 
	
	## Retro, 7 tracks
	"Overworld (Super Mario Bros.)",
	"Castle Mix (Super Mario Bros.)",
	"Overworld (Super Mario Bros. 2)",
	"Overworld Mix (Super Mario Bros. 3)",
	"Fortress (Super Mario Bros. 3)",
	"Athletic (Super Mario World)",
	"Castle (Super Mario World)",
]

## Points to define a parent group
const points : Array[int] = [
	0,
	14,
	28,
	96
]

## Number of songs in each category
const song_count : Array[int] = [
	14,
	14,
	68,
	7
]

## Category names
const category : Array[String] = [
	"Super Mario 64 OST",
	"Beyond the Cursed Mirror OST",
	"ROM Hack Music Ports",
	"Retro 2D Mario Music"
]

## Dropdown names
const dropdown_names : Array[String] = [
	"Level Song - %s",
	"Race Song - %s",
	"Boss Song - %s"
]

## Current [MB64Level] resource
var current_res : MB64Level :
	set(value) : current_res = value; prepare_backup(); update_fields()
	get : return current_res
## Backup fields
var backup_fields : Array[int]

func _ready() -> void:
	visibility_changed.connect(update_fields.bind())

## Updates dropdown and tree view of songs
func update_fields() -> void:
	update_tree()
	update_categories()

## Update song list
func update_tree() -> void:
	# Prepare tree
	%list.clear()
	var root : TreeItem
	var category_item : TreeItem
	
	# Create root item
	root = %list.create_item(null)
	root.set_text(0, "Songs")
	
	# Update tree
	for index in range(music.size()):
		for point in range(points.size()):
			if index == points[point]:
				category_item = %list.create_item(root, index) as TreeItem
				category_item.set_text(0, category[point])
				break
		var item = %list.create_item(category_item, index) as TreeItem
		item.set_text(0, music[index])

## Update song categories
func update_categories() -> void:
	# Iterate
	for index in range(dropdown_names.size()):
		%type.set_item_text(index, dropdown_names[index] % music[backup_fields[index]])

## Prepares backup fields
func prepare_backup() -> void:
	backup_fields.clear()
	for track in range(current_res.music.size()):
		backup_fields.append(current_res.music[track])

## Called when user selects song
func song_selected() -> void:
	var item : TreeItem = %list.get_selected()
	if item.get_parent() == %list.get_root():
		return
	var song_idx : int = item.get_index()
	var category_idx : int = item.get_parent().get_index()
	backup_fields[%type.selected] = points[category_idx] + song_idx
	update_categories()
	
## Called when dropdown selection is changed
func dropdown_changed(index : int) -> void:
	var selection = byte_to_index(backup_fields[index])
	var target : TreeItem = %list.get_root().get_child(selection[0]).get_child(selection[1])
	target.select(0)
	%list.scroll_to_item(target, true)

## Called when user requests to apply data change
func apply_pressed() -> void:
	current_res.music = backup_fields
	hide()

## Called when user denies data change
func cancel_pressed() -> void:
	backup_fields.clear()
	hide()

## Converts byte song id to album and song index
func byte_to_index(byte : int) -> Array[int]:
	var index : Array[int] = [0, 0]
	var song : int = byte 
	
	for x in range(song_count.size()):
		if song <= song_count[x]:
			index[0] = x
			index[1] = song
			break
		song -= song_count[x]
	return index
     # ui.gd
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

## Sent when a parse is requested
signal parse_requested(path : String)
## Sent when editing ability is changed
signal editing_changed(mode : bool)

## Web file access class
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
	facc.loaded.connect(%parser.parse_web_file())
	facc.open("*.mb64")
	
	
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

## Toggles metadata window field visibility
func toggle_metadata_fields(mode : bool) -> void:
	%meta_container.visible = mode
	%meta_message.visible = !mode
       GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://diqng8usf174o"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                RSRC                    PackedScene            ��������                                            %      resource_local_to_scene    resource_name    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom 	   bg_color    draw_center    skew    border_width_left    border_width_top    border_width_right    border_width_bottom    border_color    border_blend    corner_radius_top_left    corner_radius_top_right    corner_radius_bottom_right    corner_radius_bottom_left    corner_detail    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    shadow_color    shadow_size    shadow_offset    anti_aliasing    anti_aliasing_size    script    line_spacing    font 
   font_size    font_color    outline_size    outline_color 	   _bundled       Script    res://script/parser.gd ��������   Theme    res://asset/ui_theme.tres /��Gj   Script    res://script/ui.gd ��������
   Texture2D &   res://asset/gui/thumb_placeholder.png �k	%E�\   PackedScene    res://song_config_window.tscn E�X�J      local://StyleBoxFlat_unneb �         local://StyleBoxFlat_t1iys          local://LabelSettings_cjteh          local://PackedScene_ogb7k 2         StyleBoxFlat 	            A         A         A         A      ���=���=���=��?                                    StyleBoxFlat 	            A         A         A         A      ���=���=���=��?                                    LabelSettings                       PackedScene    $      	         names "   �      main    Node    parser    unique_name_in_owner    script    ui    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    theme    metadata/_edit_use_anchors_    metadata/_edit_lock_    Control    import_panel    offset_left    offset_top    offset_right    offset_bottom    mouse_filter 
   hide_show    anchor_top    size_flags_horizontal    theme_override_styles/normal    text    Button    panel    size_flags_vertical    PanelContainer    VBoxContainer    label    bbcode_enabled    RichTextLabel    load_sm64_rom 	   disabled    open_file_diag    title    size    ok_button_text 
   file_mode    access    filters    use_native_dialog    FileDialog    load_level    level_diag 
   meta_data    anchor_left    custom_minimum_size    meta_container $   theme_override_constants/separation 	   category    size_flags_stretch_ratio    fit_content 
   thumbnail    icon    flat    icon_alignment    expand_icon    thumbnail_diag 	   metadata    scroll    horizontal_scroll_mode    ScrollContainer    vbox 
   alignment    info    label_settings    Label    seperator3    HSeparator    level_name_property    HBoxContainer 
   meta_name    level_name    placeholder_text    max_length    clear_button_enabled 	   LineEdit    level_author_property    level_author    generic 
   seperator    song_property    song    song_config_window    visible    envfx_property    environment    item_count 	   selected    fit_to_longest_item    popup/item_0/text    popup/item_0/id    popup/item_1/text    popup/item_1/id    popup/item_2/text    popup/item_2/id    popup/item_3/text    popup/item_3/id    popup/item_4/text    popup/item_4/id    OptionButton    theme_property    popup/item_5/text    popup/item_5/id    popup/item_6/text    popup/item_6/id    popup/item_7/text    popup/item_7/id    popup/item_8/text    popup/item_8/id    popup/item_9/text    popup/item_9/id    popup/item_10/text    popup/item_10/id    popup/item_11/text    popup/item_11/id    background_property    background    coin_star_property 
   coin_star 
   max_value    step    value    suffix    SpinBox    water_property    water_level    prefix    secret_property    secret_theme 	   CheckBox    btcm_property 
   btcm_mode 	   boundary    seperator2    boundary_type_property    bound_type    boundary_height_property    bound_height    boundary_material_id_property 
   bound_mat    btcm    seperator4    costume_property    costume    popup/item_12/text    popup/item_12/id    popup/item_13/text    popup/item_13/id    popup/item_14/text    popup/item_14/id    export    tooltip_text    export_dialog    initial_position    meta_message    horizontal_alignment 
   container    Node3D    built_mesh    MeshInstance3D 
   update_ui    parsing_complete    toggle_metadata_fields    editing_changed    parse_file    parse_requested    mb64_import_requested    pressed    mb64_selected    file_selected    painting_import_requested    load_picture_for_import    set_level_name    text_changed    set_author    open_song_config 
   set_envfx    item_selected 
   set_theme    set_background    coin_star_changed    value_changed    water_level_changed    secret_theme_toggled    toggled    btcm_mode_toggled    bound_type_selected    bound_height_changed    bound_mat_changed    set_costume    open_save_dialog    write_meta    	   variants    �                                    �?                                    �A     bC     �C   tZ�   �	�;     RC     �B     kC     :C                      >    tZ=     �C   �   [b]Mario Builder 64 
Parser Tool[/b]

[i]Original hack by Rovertronic, Arthurtilly, and co. Parser created by Jefftastic

[s]Select a valid SM64 rom to extract assets from,[/s] then load a valid level file (.mb64)       Load SM64 ROM       Open a File -   �  �         Open "         *.mb64       Load Level           ���    ��C    ���    ���               < 
     RC  �C   �t��   H�ZA   '�n�     ��             [b]Level Metadata[/b]
 
         �B         "         *.png    *.jpg    *.jpeg    *.bmp    �   [fill][i]HeaderString: {header_string}
MB64Version: {mb64_version}
GridSize:	 {grid_size}x{grid_size}

TileCount: {tile_count}
ObjectCount: {object_count}
             Information                Title 
      C       
         Level Name    2         Author       Level Author             Generic       Song       Open Config                       Environment             None       Ashes       Snow       Rain    
   Sandstorm             Theme 
     HC                Shifting Sand Land       Red Hot Reservoir       Hazy Maze Cave       Peach's Castle       Virtualplex       Snowy Palace       Big Boo's Haunt             Jolly Roger Bay    
   Retroland    	         Custom    
   Minecraft             BG       Ocean Hills       Cloudy Sky    
   Fiery Sky       Green Cave       Haunted Forest       Ice Mountains       Desert Pyramids       Underwater City    	   Pink Sky    
   Coin Star 
     C        `�E     �A      Coins       Water Level      �B      Y       Enable Secret Theme 
         �A      Enable BTCM gamemode    	   Boundary       Boundary Type       Void       Plain       Valley       Chasm       Plateau       Boundary Height       Boundary Material ID      A      BTCM Exclusive       Costume       Mario       Fire Mario       Glitchy       Luigi       Wario       Disco Mario       Undead Pirate       Mocap Mario       Darius       Butler Mario       Retro Mario    	   Thwompio       Builder Mario       Showrunner             Cosmic Phant.          &   Writes changed metadata to .mb64 file       Export Modified Level       Export Modified Level...       Load a level first!       node_count    N         nodes        ��������       ����                      ����                                  ����
                     	      
                                                       ����                  	      	      
                                       ����                     	                                                                        ����         	                                                            ����                    "       ����               !                           #   ����         $                        -   %   ����   &      '      (      )      *      +      ,                     .   ����                   
       -   /   ����          &      '      (      )      *      +      ,                     0   ����                     	      
                                          ����         1            	                      !      "            #      $                           ����   2   %         1            	         &      '      (      )                                          3   ����                4                 "   5   ����               6   *   !          +   7                     8   ����          2   ,         9   -   :       ;      <                  -   =   ����          &      '      (      )      *      +   .   ,                  "   >   ����                !          /   7                  A   ?   ����               @                    B   ����                  0   C                 F   D   ����            1   E   2              H   G   ����                    J   I   ����                    F   K   ����            3              P   L   ����          2   4            5   M   6   N   7   O                  J   Q   ����                    F   K   ����            8              P   R   ����          2   4            5   M   9   N   :   O                  F   S   ����            ;   E   2              H   T   ����                    J   U   ����                     F   K   ����            <                  V   ����   2   4            5      =   C          "       ���W   >             X   ?              J   Y   ����             $       F   K   ����            @       $       h   Z   ����          2   4            5   [   A   \      ]   ?   ^   B   _      `   C   a      b   D   c      d   E   e      f   F   g   G              J   i   ����             '       F   K   ����            H       '       h      ����          2   I            5   [   J   \      ]   ?   ^   ;   _      `   K   a      b   L   c      d   M   e      f   N   g   G   j   O   k   A   l   P   m   0   n   Q   o   R   p   S   q      r   T   s   U   t   V   u   5   v   W   w   X              J   x   ����             *       F   K   ����            Y       *       h   y   ����          2   I            5   [   5   \      ^   Z   _      `   [   a      b   \   c      d   ]   e      f   ^   g   G   j   _   k   A   l   `   m   0   n   a   o   R   p   b   q      r   B   s   U              J   z   ����             -       F   K   ����            c       -       �   {   ����          2   d            5   |   e   }   f   ~   f      g              J   �   ����             0       F   K   ����            h       0       �   �   ����                   5   |   i   �   j              J   �   ����             3       F   K   ����            k       3       �   �   ����          2   l            5              J   �   ����             6       F   K   ����            m       6       �   �   ����          2   l            5              F   �   ����            n   E   2              H   �   ����                    J   �   ����             ;       F   K   ����            o       ;       h   �   ����          2   4            5   [   A   \      ^   p   _      `   q   a      b   r   c      d   s   e      f   t   g   G              J   �   ����             >       F   K   ����            u       >       �   �   ����                   5   |   i   �   j              J   �   ����             A       F   K   ����            v       A       �   �   ����                   5   |   w              F   �   ����            x   E   2              H   �   ����                    J   �   ����             F       F   K   ����            y       F       h   �   ����$          2   4            5   [      \      ^   z   _      `   {   a      b   |   c      d   }   e      f   ~   g   G   j      k   A   l   �   m   0   n   �   o   R   p   �   q      r   �   s   U   t   �   u   5   v   �   w   X   �   �   �   J   �   �   �   �   �   �   �   �                 �   ����         �   �      �       I       -   �   ����          &   �   �   G   *      +      ,                  F   �   ����          X   ?            �   �                  �   �   ����        L       �   �   ����              conn_count             conns     �         �   �                    �   �                    �   �              
      �   �                    �   �                    �   �                    �   �                    �   �                    �   �              "      �   �              &      �   �              )      �   �              ,      �   �              /      �   �              2      �   �              5      �   �              8      �   �              =      �   �              @      �   �              C      �   �              H      �   �              I      �   �              J      �   �                    node_paths              editable_instances              version             RSRC       RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Theme    res://asset/ui_theme.tres /��Gj   Script    res://script/song_config.gd ��������      local://PackedScene_jxxtt C         PackedScene          	         names "   3      song_config_window    title    initial_position    size 
   exclusive    theme    script    Window    margin    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical %   theme_override_constants/margin_left $   theme_override_constants/margin_top &   theme_override_constants/margin_right '   theme_override_constants/margin_bottom    MarginContainer    vbox    layout_mode    VBoxContainer    type    unique_name_in_owner    custom_minimum_size    item_count 	   selected    fit_to_longest_item    allow_reselect    popup/item_0/text    popup/item_0/id    popup/item_1/text    popup/item_1/id    popup/item_2/text    popup/item_2/id    OptionButton    list    size_flags_vertical 
   hide_root    scroll_horizontal_enabled    Tree    hbox    HBoxContainer    cancel    size_flags_horizontal    text    Button    apply    dropdown_changed    item_selected    song_selected    	   variants             Song Configuration       -   �                                        �?            
         �A                          Level Song - %s       Race Song - %s             Boss Song - %s       Cancel       Apply       node_count             nodes     �   ��������       ����                                                          ����	   	      
                           	      	      	      	                    ����                    #      ����            
                                                          !      "                 (   $   ����               %      &      '                 *   )   ����                    .   +   ����         ,      -                 .   /   ����         ,      -                conn_count             conns               1   0                     1   2                    node_paths              editable_instances              version             RSRC      [remap]

path="res://.godot/exported/133200997/export-377efd6eca0b0da0ee0a32e6a29f411e-upload_file_example.scn"
[remap]

path="res://.godot/exported/133200997/export-a2f3f81d3116925ac6ae30de373dd90d-upload_image_example.scn"
               [remap]

path="res://.godot/exported/133200997/export-fd26c97c4e59e8eff4ea97bb215687fa-upload_to_server_example.scn"
           [remap]

path="res://.godot/exported/133200997/export-2c9d660a8f7e2c62577ddcd6fc2207d5-ui_theme.res"
           [remap]

path="res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn"
               [remap]

path="res://.godot/exported/133200997/export-a185f18a5cb5abed0b64d6a429edcecc-song_config_window.scn"
 list=Array[Dictionary]([{
"base": &"RefCounted",
"class": &"FileAccessWeb",
"icon": "",
"language": &"GDScript",
"path": "res://addons/FileAccessWeb/core/file_access_web.gd"
}, {
"base": &"Resource",
"class": &"MB64Level",
"icon": "",
"language": &"GDScript",
"path": "res://script/res_mb64.gd"
}, {
"base": &"Node",
"class": &"Parser",
"icon": "",
"language": &"GDScript",
"path": "res://script/parser.gd"
}, {
"base": &"Window",
"class": &"SongConfig",
"icon": "",
"language": &"GDScript",
"path": "res://script/song_config.gd"
}, {
"base": &"Control",
"class": &"UI",
"icon": "",
"language": &"GDScript",
"path": "res://script/ui.gd"
}, {
"base": &"Control",
"class": &"UploadFileExample",
"icon": "",
"language": &"GDScript",
"path": "res://addons/FileAccessWeb/examples/upload_file_example.gd"
}, {
"base": &"Control",
"class": &"UploadImageExample",
"icon": "",
"language": &"GDScript",
"path": "res://addons/FileAccessWeb/examples/upload_image_example.gd"
}, {
"base": &"Control",
"class": &"UploadToServerExample",
"icon": "",
"language": &"GDScript",
"path": "res://addons/FileAccessWeb/examples/upload_to_server_example.gd"
}])
              <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
              )����<�G<   res://addons/FileAccessWeb/examples/upload_file_example.tscn��i�x_*=   res://addons/FileAccessWeb/examples/upload_image_example.tscn%���U�i6A   res://addons/FileAccessWeb/examples/upload_to_server_example.tscn�k	%E�\%   res://asset/gui/thumb_placeholder.png/��Gj   res://asset/ui_theme.tresHtv���k   res://icon.svg���*'�   res://main.tscnE�X�J   res://song_config_window.tscn          ECFG      application/config/name         MB64 Parser    application/run/main_scene         res://main.tscn    application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg  (   debug/gdscript/warnings/integer_division             editor_plugins/enabled4   "      &   res://addons/FileAccessWeb/plugin.cfg   #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility  