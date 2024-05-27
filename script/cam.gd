# cam.gd
class_name UserCam extends Camera3D

'''
User camera control
'''

## Speed values
const SPEED_NORMAL = 15
const SPEED_FAST = 40

## Whether or not camera control is enabled
var in_control : bool = false

func _unhandled_input(event: InputEvent) -> void:
	# Diverge if mouse input
	if event is InputEventMouseMotion && in_control:
		look(event)
		return
	
	# Only accept key events
	if not event is InputEventKey:
		return
	event = event as InputEventKey
	
	# Toggle control
	if event.is_pressed() && event.keycode == KEY_C:
		in_control = !in_control
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if in_control else Input.MOUSE_MODE_VISIBLE
	# Toggle wireframe
	if event.is_pressed() && event.keycode == KEY_V:
		RenderingServer.set_debug_generate_wireframes(true)
		get_tree().root.debug_draw = Viewport.DEBUG_DRAW_DISABLED if get_tree().root.debug_draw == Viewport.DEBUG_DRAW_WIREFRAME else Viewport.DEBUG_DRAW_WIREFRAME

func look(event : InputEventMouseMotion) -> void:
	# Rotate camera directly
	rotation.x -= (event.relative.y) * 0.25 * get_process_delta_time()
	rotation.y -= (event.relative.x) * 0.25 * get_process_delta_time()
	
	# Clamp and wrap target values
	rotation.x = clamp(rotation.x, -80.0, 80.0)
	rotation.y = wrapf(rotation.y, -180.0, 180.0)

func _physics_process(delta : float) -> void:
	# Skip if no control
	if !in_control:
		return
	
	# Look for movement vectors
	var vec := Input.get_vector("cam_left", "cam_right", "cam_back", "cam_forward")
	var vertical := Input.get_axis("cam_down", "cam_up")
	
	# Move
	self.translate_object_local(Vector3(vec.x, 0, -vec.y) * SPEED_NORMAL * delta)
	self.translate(Vector3.UP * vertical * SPEED_NORMAL * delta)
