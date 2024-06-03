# cam.gd
class_name UserCam extends Camera3D

'''
User camera control
'''

## Speed values
const SPEED_NORMAL = 15
const SPEED_FAST = 30

## Boundaries
const MIN = -16.0
const MAX = 80.0

## FOV bounds
const MIN_FOV = 25
const MAX_FOV = 120
@onready var target_fov = self.fov

## Whether or not camera control is enabled
var in_control : bool = false

func _init() -> void:
	RenderingServer.set_debug_generate_wireframes(true)

func _unhandled_input(event: InputEvent) -> void:
	# Diverge if mouse input
	if event is InputEventMouseMotion && in_control:
		look(event)
		return
	
	# Handle mouse scroll
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_fov = min(target_fov + 5, MAX_FOV)
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_fov = max(target_fov - 5, MIN_FOV)
	
	# Only accept key events from now on
	if not event is InputEventKey:
		return
	event = event as InputEventKey
	
	# Toggle control
	if event.is_pressed() && event.keycode == KEY_C:
		in_control = !in_control
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if in_control else Input.MOUSE_MODE_VISIBLE
	# Toggle wireframe
	if event.is_pressed() && event.keycode == KEY_V:
		get_tree().root.debug_draw = Viewport.DEBUG_DRAW_DISABLED if get_tree().root.debug_draw == Viewport.DEBUG_DRAW_WIREFRAME else Viewport.DEBUG_DRAW_WIREFRAME

func look(event : InputEventMouseMotion) -> void:
	# Rotate camera directly
	rotation.x -= (event.relative.y) * 0.25 * get_process_delta_time()
	rotation.y -= (event.relative.x) * 0.25 * get_process_delta_time()
	
	# Clamp and wrap target values
	rotation_degrees.x = clampf(rotation_degrees.x, -80.0, 80.0)
	rotation_degrees.y = wrapf(rotation_degrees.y, -180.0, 180.0)

func _process(_delta: float) -> void:
	# Interpolate to target FOV
	self.fov = lerpf(self.fov, target_fov, 0.1)

func _physics_process(delta : float) -> void:
	# Skip if no control
	if !in_control:
		return
	
	# Look for movement vectors
	var vec := Input.get_vector("cam_left", "cam_right", "cam_back", "cam_forward")
	var vertical := Input.get_axis("cam_down", "cam_up")
	var modifier := Input.is_action_pressed("modifier")
	
	# Move
	var speed := (SPEED_NORMAL if !modifier else SPEED_FAST)
	self.translate_object_local(Vector3(vec.x, 0, -vec.y) * speed * delta)
	self.translate(Vector3.UP * vertical * speed * delta)
	
	# Clamp into bounds
	position.x = clampf(position.x, MIN, MAX)
	position.z = clampf(position.z, MIN, MAX)
