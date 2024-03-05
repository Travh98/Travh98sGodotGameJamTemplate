extends CharacterBody3D

## First Person Player Controller
## Made with the help of Lukky's Ultimate FPS Controller tutorial: https://www.youtube.com/watch?v=xIKErMgJ1Yk

# Player's child nodes
@onready var head_pcam: PhantomCamera3D = $Neck/Head/Eyes/FpsCharPcam
@onready var eyes = $Neck/Head/Eyes
@onready var head: Node3D = $Neck/Head
@onready var neck: Node3D = $Neck
@onready var standing_col: CollisionShape3D = $StandingCol
@onready var crouching_col: CollisionShape3D = $CrouchingCol
@onready var standing_room_cast = $StandingRoomCast

# Speed variables
var current_speed: = 5.0
const WalkingSpeed: float = 5.0
const SprintingSpeed: float = 8.0
const CrouchingSpeed: float = 3.0
const JumpVelocity = 4.5

# Player Height
var crouching_depth: float = -0.5
var head_height: float = 1.7

# Player Controls
const mouse_sens: float = 0.25
var lerp_speed: float = 10.0
var direction: Vector3 = Vector3.ZERO

# Player State
var is_walking: bool = false
var is_sprinting: bool = false
var is_crouching: bool = false
var is_free_looking: bool = false
var is_sliding: bool = false

# Camera Controls
var free_look_tilt_amount: float = 5.0

# Slide Variables
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector: Vector2 = Vector2.ZERO
var slide_speed: float = 10.0

# Head Bob Variables
const HeadBobSprintSpeed: float = 22.0
const HeadBobWalkSpeed: float = 14.0
const HeadBobCrouchSpeed: float = 10.0

const HeadBobSprintIntensity: float = 0.20
const HeadBobWalkIntensity: float = 0.10
const HeadBobCrouchIntensity: float = 0.05

var head_bobbing_vector = Vector2.ZERO # Keeps track of x y movement
var head_bobbing_index: float = 0.0 # How far we are along the sine function
var head_bobbing_intensity: float = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Activate first person camera on startup
	head_pcam.set_priority(2)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event is InputEventMouseMotion:
		if is_free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_pressed("crouch") or is_sliding:
		current_speed = CrouchingSpeed
		head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
		standing_col.disabled = true
		crouching_col.disabled = false
		
		# If we were currently sprinting and moving
		if is_sprinting and input_dir != Vector2.ZERO:
			# Sliding begin logic
			is_sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			is_free_looking = true
			print("Slide begin")
		
		is_walking = false
		is_sprinting = false
		is_crouching = true
	
	# Make sure we can uncrouch
	elif !standing_room_cast.is_colliding():
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		standing_col.disabled = false
		crouching_col.disabled = true
		
		if Input.is_action_pressed("sprint"):
			current_speed = SprintingSpeed
			
			is_walking = false
			is_sprinting = true
			is_crouching = false
		else:
			current_speed = WalkingSpeed
			is_walking = true
			is_sprinting = false
			is_crouching = false
	
	# Handle free look
	if Input.is_action_pressed("free_look") or is_sliding:
		is_free_looking = true
		
		if is_sliding:
			head_pcam.rotation.z = lerp(head_pcam.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
		else:
			head_pcam.rotation.z = deg_to_rad(-neck.rotation.y * free_look_tilt_amount)
	else:
		is_free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		head_pcam.rotation.z = lerp(head_pcam.rotation.z, 0.0, delta * lerp_speed)
	
	# Handle Sliding
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			# Slide end 
			is_sliding = false
			is_free_looking = false
			print("Slide end")
	
	# Handle Headbob
	if is_sprinting:
		head_bobbing_intensity = HeadBobSprintIntensity
		head_bobbing_index += HeadBobSprintSpeed * delta
	elif is_walking:
		head_bobbing_intensity = HeadBobWalkIntensity
		head_bobbing_index += HeadBobWalkSpeed * delta
	else:
		head_bobbing_intensity = HeadBobCrouchIntensity
		head_bobbing_index += HeadBobCrouchSpeed * delta
	
	if is_on_floor() and !is_sliding and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_intensity / 2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JumpVelocity
		is_sliding = false

	if is_sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()

	# Acceleration
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if is_sliding:
			velocity.x = direction.x * (slide_timer + 0.1) * slide_speed
			velocity.z = direction.z * (slide_timer + 0.1) * slide_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
