class_name SpringArmCamera
extends Spatial

export (NodePath) var target

export var CAMERA_MOUSE_ROTATION_SPEED = 0.001
export var CAMERA_CONTROLLER_ROTATION_SPEED = 3.0
# A minimum angle lower than or equal to -90 breaks movement if the player is looking upward.
export var CAMERA_X_ROT_MIN = -89.9
export var CAMERA_X_ROT_MAX = 70

#------------

export var current_aim = false
export var camera_x_rot = 0.0

export var camera_basis = Vector3.ZERO
export var camera_z = Vector3.ZERO
export var camera_x = Vector3.ZERO

#------------

var aiming = false


#------------

onready var camera_animation = $Animation
onready var camera_rot = $CameraRot
onready var camera_spring_arm = $CameraRot/SpringArm
onready var camera = $CameraRot/SpringArm/Camera

	
##------------

## Commands
## attach to object
## rotate
## change distance
## change position
## change FOV

var camera_move := Vector2.ZERO
			
func _process(delta):
	if target:
		global_transform.origin = get_node(target).global_transform.origin
		
func _physics_process(delta):
	var camera_speed_this_frame = delta * CAMERA_CONTROLLER_ROTATION_SPEED
	if aiming:
		camera_speed_this_frame *= 0.5
	rotate_camera(camera_move * camera_speed_this_frame)

	camera_basis = camera_rot.global_transform.basis
	camera_z = camera_basis.z
	camera_x = camera_basis.x

	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()

	if aiming != current_aim:
		aiming = current_aim
		if aiming:
			camera_animation.play("shoot")
		else:
			camera_animation.play("far")

# ---------------------------
func move(vect):
	camera_move = vect

func rotate_relative(relative):
	var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
	if aiming:
		camera_speed_this_frame *= 0.75
	rotate_camera(relative * camera_speed_this_frame)
		
func project_ray_origin(ch_pos):
	return camera.project_ray_origin(ch_pos)

func project_ray_normal(ch_pos):
	return camera.project_ray_normal(ch_pos)

func rotate_camera(move):
	rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	orthonormalize()
	camera_x_rot += move.y
	camera_x_rot = clamp(camera_x_rot, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	camera_rot.rotation.x = camera_x_rot

#------------------

func add_camera_shake_trauma(amount):
	camera.add_trauma(amount)

func set_aiming(aiming):
	current_aim = aiming
	
func set_current():
	camera.current = true
