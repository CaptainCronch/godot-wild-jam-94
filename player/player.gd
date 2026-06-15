extends CharacterBody2D
class_name Player

const BASE_SPEED := 15000.0
const BASE_ACCELERATION := 18.0
const BASE_FRICTION := 10.0  
const BASE_AIR_ACCELERATION := 8.0
const BASE_AIR_FRICTION := 0.5
const BASE_JUMP_FORCE := -12.0
const BASE_GRAVITY := 25.0
const BASE_FALL_BOOST := 1.8
const BASE_JUMP_BOOST := 250.0
const BASE_DIVE_BOOST := 500.0
const BASE_DIVE_JUMP_BOOST := -5.0
#const BASE_JUMP_BOOST_DECAY := 3.0
const JUMP_BUFFER := 30.0
const COYOTE_TIME := 0.1

@export var puppet: Node2D
@export var sprite: Polygon2D
@export var shadow: Polygon2D
@export var weapon: Weapon
@export var weapon_holder: Node2D
@export var camera_holder: CameraHolder
@export var world_area: Area2D
@export var debug_text: Label

var speed := BASE_SPEED
var acceleration := BASE_ACCELERATION
var friction := BASE_FRICTION
var air_acceleration := BASE_AIR_ACCELERATION
var air_friction := BASE_AIR_FRICTION
var jump_force := BASE_JUMP_FORCE
var gravity := BASE_GRAVITY
var jump_boost := 1.0
var airborne := false
var in_jump_buffer := true
var jump_cut := false
var diving := false
var coyote_timer := 0.0
var desired_velocity := Vector2()
var velocity_z := 0.0
var position_z := 0.0
var floor_height := 0.0
var dir := Vector2()

@onready var camera := camera_holder.camera


func _ready() -> void:
	pass
	#print(Global.tilemaps)


func _process(delta: float) -> void:
	dir = Input.get_vector("left", "right", "up", "down").normalized()
	
	if Input.is_action_just_pressed("space"):
		jump()
	elif Input.is_action_just_released("space") and airborne and velocity_z < 0:
		jump_cut = true
	
	if Input.is_action_just_pressed("shift"):
		kick()
	
	if Input.is_action_just_pressed("mouse1"):
		weapon.fire()
	
	weapon_holder.rotation = weapon_holder.global_position.direction_to(get_global_mouse_position()).angle()
	if absf(weapon_holder.rotation) > PI/2.0:
		weapon_holder.scale.y = -1.0
	else:
		weapon_holder.scale.y = 1.0
	#debug_text.text = str(weapon_holder.rotation)
	
	coyote_timer = minf(coyote_timer + delta, COYOTE_TIME)
	
	#shadow.position.y = -floor_height


func _physics_process(delta: float) -> void:
	movement_z(delta)
	
	desired_velocity = dir * speed * delta * jump_boost
	
	#jump_boost = Global.decay_towards(jump_boost, 1.0, BASE_JUMP_BOOST_DECAY, delta)
	
	var decay := Vector2()
	if diving:
		decay = Vector2(BASE_AIR_FRICTION, BASE_AIR_FRICTION)
	elif not airborne:
		decay = Vector2(acceleration if absf(dir.x) > 0 else friction,
				acceleration if absf(dir.y) > 0 else friction)
	else:
		decay = Vector2(air_acceleration if absf(dir.x) > 0 else air_friction,
				air_acceleration if absf(dir.y) > 0 else air_friction)
	
	velocity.x = Global.decay_towards(velocity.x, desired_velocity.x, decay.x, delta)
	velocity.y = Global.decay_towards(velocity.y, desired_velocity.y, decay.y, delta)
	move_and_slide()


func movement_z(delta: float) -> void:
	gravity = BASE_GRAVITY * (1.0 if velocity_z < 0.0 and not jump_cut else BASE_FALL_BOOST) 
	velocity_z += gravity * delta
	position_z = minf(position_z + velocity_z, -floor_height)
	if is_equal_approx(position_z, -floor_height):
		if not (diving and Input.is_action_pressed("space")):
			diving = false
			sprite.rotation = 0.0
		airborne = false
		coyote_timer = 0.0
		jump_cut = false
		velocity_z = 0.0
	else:
		airborne = true
	
	in_jump_buffer = position_z - -floor_height > -JUMP_BUFFER
	
	# Base tilemap always on, contains the impassable walls
	set_collision_mask_value(1, position_z > -Global.TILE_HEIGHT)
	set_collision_mask_value(2, position_z > -Global.TILE_HEIGHT * 2)
	set_collision_mask_value(3, position_z > -Global.TILE_HEIGHT * 3)
	
	var found := false
	for body in world_area.get_overlapping_bodies():
		if body is WorldLayer:
			if body.height * Global.TILE_HEIGHT >= floor_height:
				floor_height = body.height * Global.TILE_HEIGHT
				found = true
	if not found: floor_height = 0.0
	
	#debug_text.text = str(roundf(position_z)) + " | " + str(floor_height)
	
	puppet.position.y = position_z


func jump() -> void:
	if in_jump_buffer or coyote_timer < COYOTE_TIME:
		velocity_z = jump_force
		velocity += dir * BASE_JUMP_BOOST
		coyote_timer = COYOTE_TIME
		jump_cut = false
	elif airborne and not diving:
		velocity = (dir if dir.length() > 0.0 else velocity.normalized()) * BASE_DIVE_BOOST
		velocity_z = BASE_DIVE_JUMP_BOOST
		diving = true
		sprite.rotation = PI/2.0
		#jump_boost = BASE_JUMP_BOOST


func kick() -> void:
	pass
