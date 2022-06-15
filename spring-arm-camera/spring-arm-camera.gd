class_name SpringArmCamera
extends Spatial

export (NodePath) var Target

export var SPRING_LENGTH: float = 3 setget set_spring_length
export var FOLLOW_HEIGHT: float = 2 setget set_follow_height
export var FOLLOW_ANGLE: float = 30 setget set_follow_angle

export var CAMERA_CONTROLLER_ROTATION_SPEED = 0.1
# A minimum angle lower than or equal to -90 breaks movement if the player is looking upward.
export var CAMERA_X_ROT_MIN = -89.9
export var CAMERA_X_ROT_MAX = 70
export var CAMERA_AIM_SPEED = 0.5

#------------

export var current_aim = false
export var camera_x_rot = 0.0

export var camera_basis = Vector3.ZERO
export var camera_z = Vector3.ZERO
export var camera_x = Vector3.ZERO



#------------

var aiming = false
var camera_speed = CAMERA_CONTROLLER_ROTATION_SPEED

#export var spring_length: float set
#------------

onready var camera_animation = $Animation
onready var camera_rot = $CameraRot
onready var camera_spring_arm = $CameraRot/SpringArm
onready var camera = $CameraRot/SpringArm/Camera
onready var target := get_node(Target)
	
##------------
func set_target(_target: Spatial=null):
	target = _target
	
## Commands
## attach to object
## rotate
## change distance
## change position
## change FOV

var camera_move := Vector2.ZERO
var initial_position: Vector3

func reset_position():
	global_transform.origin = initial_position
	
func _onready():
	initial_position = global_transform.origin

func _process(delta):
	if target:
		global_transform.origin = target.global_transform.origin
			
	camera_basis = camera_rot.global_transform.basis
	camera_z = camera_basis.z
	camera_x = camera_basis.x

	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
		
	# Basis
	# 2D basis
# ---------------------------
func move(vect):
	camera_move = vect

func rotate_relative(relative):
	rotate_camera(relative * camera_speed)
		
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

func set_aiming(_aiming):
	current_aim = _aiming
	
	if aiming != current_aim:
		aiming = current_aim
		if aiming:
			camera_animation.play("shoot")
		else:
			camera_animation.play("far")
			
	if(aiming):
		camera_speed = CAMERA_AIM_SPEED * CAMERA_CONTROLLER_ROTATION_SPEED
	else:
		camera_speed = CAMERA_CONTROLLER_ROTATION_SPEED
		
	
	
func set_current():
	camera.current = true

func set_spring_length(length: float):
	SPRING_LENGTH = length
	$CameraRot/SpringArm.spring_length = length
	
func spring_length(spring_delta: float):
	$CameraRot/SpringArm.spring_length = $CameraRot/SpringArm.spring_length + spring_delta
	
func inc_spring_length():
	$CameraRot/SpringArm.set = $CameraRot/SpringArm.spring_length + 0.1

func dec_spring_length():
	$CameraRot/SpringArm.spring_length = $CameraRot/SpringArm.spring_length - 0.1

func set_follow_height(_height: float):
	FOLLOW_HEIGHT = _height
	$CameraRot/SpringArm.translate(Vector3(0, FOLLOW_HEIGHT, 0))

func set_follow_angle(_angle: float):
	FOLLOW_ANGLE = _angle
	$CameraRot/SpringArm.rotate(Vector3(FOLLOW_ANGLE, 0, 0))


#---------------------

func get_rotation_quat():
	return global_transform.basis.get_rotation_quat()

func get_plain_basis() -> Basis:
	var camera_basis = Basis.IDENTITY
				
	camera_basis.x = camera_x
	camera_basis.y = Vector3.ZERO
	camera_basis.z = camera_z
	
	return camera_basis
