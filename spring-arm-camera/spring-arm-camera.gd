@icon("res://addons/lunco-cameras/spring-arm-camera/spring_arm_camera.svg")
class_name SpringArmCamera
extends Node3D

## Camera Far side can't be more than 1000000 otherwise there is an error
@export var target: Node3D

@export var SPRING_LENGTH: float = 3: set = set_spring_length
@export var FOLLOW_HEIGHT: float = 2: set = set_follow_height
@export var FOLLOW_ANGLE: float = 30: set = set_follow_angle

@export var CAMERA_CONTROLLER_ROTATION_SPEED = 0.1
# A minimum angle lower than or equal to -90 breaks movement if the player is looking upward.
@export var CAMERA_X_ROT_MIN = -89.9
@export var CAMERA_X_ROT_MAX = 70
@export var CAMERA_AIM_SPEED = 0.5

#------------

@export var current_aim = false
@export var camera_x_rot = 0.0

@export var camera_basis = Vector3.ZERO
@export var camera_z = Vector3.ZERO
@export var camera_x = Vector3.ZERO



#------------

var aiming = false
var camera_speed = CAMERA_CONTROLLER_ROTATION_SPEED

#export var spring_length: float set
#------------

@onready var camera_animation = $Animation
@onready var camera_rot = $CameraRot
@onready var camera_spring_arm = $CameraRot/SpringArm
@onready @export var camera = $CameraRot/SpringArm/Camera
	
##------------

	
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
	
func _ready():
	initial_position = global_transform.origin

func _process(delta):
#	print(target)
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
	if relative.length_squared() > 0.0: #TBD: Why is this check here?
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
	camera_x_rot = clamp(camera_x_rot, deg_to_rad(CAMERA_X_ROT_MIN), deg_to_rad(CAMERA_X_ROT_MAX))
	camera_rot.rotation.x = camera_x_rot

#------------------

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
	if length < 0.1: # Setting min follow distance. TBD to settings
		length = 0.1
	SPRING_LENGTH = length
	$CameraRot/SpringArm.spring_length = SPRING_LENGTH
	
func inc_spring_length(spring_delta: float = 0.1):
	SPRING_LENGTH = SPRING_LENGTH + spring_delta #TBD Better scale curve

func dec_spring_length(spring_delta: float = 0.1):
	SPRING_LENGTH = SPRING_LENGTH - spring_delta

func set_follow_height(_height: float):
	FOLLOW_HEIGHT = _height
	$CameraRot/SpringArm.position = Vector3(0, FOLLOW_HEIGHT, 0)

func set_follow_angle(_angle: float):
	FOLLOW_ANGLE = _angle
	$CameraRot/SpringArm.rotate(Vector3(1, 0, 0), FOLLOW_ANGLE)
#	Node3D.rotate()

func add_excluded_object(rid):
	if rid:
		$CameraRot/SpringArm.add_excluded_object(rid)
	
func remove_excluded_object (rid) -> bool:
	if rid:
		return $CameraRot/SpringArm.remove_excluded_object(rid)
	else:
		return true
	
#---------------------
func get_camera_x_rot():
	return $CameraRot.rotation.x
	
func get_camera_base_quaternion() -> Quaternion:
	return global_transform.basis.get_rotation_quaternion()

func get_camera_rotation_basis() -> Basis:
	return $CameraRot.global_transform.basis

func get_plain_basis() -> Basis:
	var camera_basis = Basis.IDENTITY
				
	camera_basis.x = camera_x
	camera_basis.y = Vector3(0, 1, 0)
	camera_basis.z = camera_z
	
	return camera_basis
