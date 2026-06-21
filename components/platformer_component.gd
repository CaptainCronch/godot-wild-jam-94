extends Node2D
class_name PlatformerComponent

signal bounced

@export_category("Values")
@export var base_speed := 7500.0
@export var base_acceleration := 18.0
@export var base_friction := 10.0
@export var base_air_acceleration := 8.0
@export var base_air_friction := 0.5
@export var base_jump_force := -6.0
@export var base_gravity := 12.5
@export var base_fall_boost := 1.8
@export var bouncy := false
@export var bounce_factor := 0.8
@export var override_functions := false

@export_category("Nodes")
@export var target: CharacterBody2D
@export var world_area: Area2D
@export var puppet: Node2D
@export var health_comp: HealthComponent
@export var hitbox: HitboxComponent
@export var hurtbox: HurtBoxComponent

var airborne := false
var jumping := false
var enabled := true
var desired_velocity := Vector2()
var decay := Vector2()
var velocity_z := 0.0
var position_z := 0.0
var floor_height := 0.0
var dir := Vector2()

@onready var speed := base_speed
@onready var acceleration := base_acceleration
@onready var friction := base_friction
@onready var air_acceleration := base_air_acceleration
@onready var air_friction := base_air_friction
@onready var jump_force := base_jump_force
@onready var gravity := base_gravity


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if is_instance_valid(hurtbox): hurtbox.attack.height = position_z
	if is_instance_valid(hitbox): hitbox.height = position_z


func _physics_process(delta: float) -> void:
	if override_functions: return
	movement_z(delta)
	
	desired_velocity = (dir * (1.0 if enabled and not health_comp.is_stunned else 0.0)) * speed * delta
	
	if not airborne:
		decay = Vector2(acceleration if absf(dir.x) > 0 else friction,
				acceleration if absf(dir.y) > 0 else friction)
	else:
		decay = Vector2(air_acceleration if absf(dir.x) > 0 else air_friction,
				air_acceleration if absf(dir.y) > 0 else air_friction)
	
	target.velocity.x = Global.decay_towards(target.velocity.x, desired_velocity.x, decay.x, delta)
	target.velocity.y = Global.decay_towards(target.velocity.y, desired_velocity.y, decay.y, delta)
	
	if not bouncy:
		target.move_and_slide()
	else:
		var result := target.move_and_collide(target.velocity * delta)
		if is_instance_valid(result):
			target.velocity = target.velocity.reflect(Vector2.from_angle(result.get_angle())) * bounce_factor
			bounced.emit()


func movement_z(delta: float) -> void:
	if override_functions: return
	
	var found := false
	for body in world_area.get_overlapping_bodies():
		if body is WorldLayer:
			if body.height * Global.TILE_HEIGHT <= floor_height:
				floor_height = body.height * Global.TILE_HEIGHT
				found = true
	if not found: floor_height = 0.0
	
	gravity = base_gravity * (1.0 if velocity_z < 0.0 or not jumping else base_fall_boost) 
	velocity_z += gravity * delta
	position_z += velocity_z
	
	if bouncy and position_z > floor_height:
		velocity_z *= -bounce_factor
		if airborne and absf(velocity_z) > absf(base_jump_force/2.0): bounced.emit()
	
	position_z = minf(position_z, floor_height)
	if is_equal_approx(position_z, floor_height):
		airborne = false
		jumping = false
		if not bouncy: velocity_z = 0.0
	else:
		airborne = true
	
	# Base tilemap always on, contains the impassable walls
	target.set_collision_mask_value(1, position_z > Global.TILE_HEIGHT)
	target.set_collision_mask_value(2, position_z > Global.TILE_HEIGHT * 2)
	target.set_collision_mask_value(3, position_z > Global.TILE_HEIGHT * 3)
	
	puppet.position.y = position_z


func jump() -> void:
	if override_functions: return
	if airborne and enabled and not health_comp.is_stunned:
		velocity_z = jump_force
		jumping = true


func is_colliding() -> bool: return target.is_on_ceiling() or target.is_on_floor() or target.is_on_wall()
