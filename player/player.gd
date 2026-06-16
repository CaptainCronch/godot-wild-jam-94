extends CharacterBody2D
class_name Player

const BASE_JUMP_BOOST := 250.0
const BASE_DIVE_BOOST := 500.0
const BASE_DIVE_JUMP_BOOST := -5.0
const JUMP_BUFFER := 30.0
const COYOTE_TIME := 0.1
const KICK_SELF_KNOCKBACK := 500.0

@export var plat_comp: PlatformerComponent
@export var health_comp: HealthComponent
@export var hurtbox: HurtBoxComponent
@export var sprite: Polygon2D
@export var leg: Polygon2D
@export var weapon: Weapon
@export var weapon_holder: Node2D
@export var camera_holder: CameraHolder
@export var debug_text: Label

var in_jump_buffer := true
var jump_cut := false
var diving := false
var coyote_timer := 0.0

@onready var camera := camera_holder.camera


func _ready() -> void:
	Global.player = self
	#print(Global.tilemaps)


func _process(delta: float) -> void:
	plat_comp.dir = Input.get_vector("left", "right", "up", "down").normalized()
	#debug_text.text = str(plat_comp.dir)
	
	if Input.is_action_just_pressed("space"):
		jump()
	elif Input.is_action_just_released("space") and plat_comp.airborne and plat_comp.velocity_z < 0:
		jump_cut = true
	
	if Input.is_action_just_pressed("shift"):
		kick()
	
	if Input.is_action_just_pressed("mouse1"):
		weapon.fire()
	
	weapon_holder.rotation = weapon_holder.global_position.direction_to(get_global_mouse_position()).angle()
	hurtbox.rotation = weapon_holder.rotation
	if absf(weapon_holder.rotation) > PI/2.0:
		weapon_holder.scale.y = -1.0
	else:
		weapon_holder.scale.y = 1.0
	#debug_text.text = str(weapon_holder.rotation)
	
	coyote_timer = minf(coyote_timer + delta, COYOTE_TIME)


func _physics_process(delta: float) -> void:
	movement_z(delta)
	
	plat_comp.desired_velocity = (plat_comp.dir * (1.0 if plat_comp.enabled else 0.0)) * plat_comp.speed * delta
	
	if diving:
		plat_comp.decay = Vector2(plat_comp.base_air_friction, plat_comp.base_air_friction)
	elif not plat_comp.airborne:
		plat_comp.decay = Vector2(plat_comp.acceleration if absf(plat_comp.dir.x) > 0 else plat_comp.friction,
				plat_comp.acceleration if absf(plat_comp.dir.y) > 0 else plat_comp.friction)
	else:
		plat_comp.decay = Vector2(plat_comp.air_acceleration if absf(plat_comp.dir.x) > 0 else plat_comp.air_friction,
				plat_comp.air_acceleration if absf(plat_comp.dir.y) > 0 else plat_comp.air_friction)
	
	velocity.x = Global.decay_towards(velocity.x, plat_comp.desired_velocity.x, plat_comp.decay.x, delta)
	debug_text.text = str(Vector2i(velocity))
	velocity.y = Global.decay_towards(velocity.y, plat_comp.desired_velocity.y, plat_comp.decay.y, delta)
	
	# dive bounce off wall
	#if diving and plat_comp.is_colliding():
		#velocity *= -1.0
	
	move_and_slide()


func movement_z(delta: float) -> void:
	plat_comp.gravity = plat_comp.base_gravity * (1.0 if plat_comp.velocity_z < 0.0 and not jump_cut else plat_comp.base_fall_boost) 
	plat_comp.velocity_z += plat_comp.gravity * delta
	plat_comp.position_z = minf(plat_comp.position_z + plat_comp.velocity_z, -plat_comp.floor_height)
	if is_equal_approx(plat_comp.position_z, -plat_comp.floor_height):
		if not (diving and Input.is_action_pressed("space")):
			diving = false
			sprite.rotation = 0.0
		plat_comp.airborne = false
		coyote_timer = 0.0
		jump_cut = false
		plat_comp.velocity_z = 0.0
	else:
		plat_comp.airborne = true
	
	in_jump_buffer = plat_comp.position_z - -plat_comp.floor_height > -JUMP_BUFFER
	
	# Base tilemap always on, contains the impassable walls
	set_collision_mask_value(1, plat_comp.position_z > -Global.TILE_HEIGHT)
	set_collision_mask_value(2, plat_comp.position_z > -Global.TILE_HEIGHT * 2)
	set_collision_mask_value(3, plat_comp.position_z > -Global.TILE_HEIGHT * 3)
	
	var found := false
	for body in plat_comp.world_area.get_overlapping_bodies():
		if body is WorldLayer:
			if body.height * Global.TILE_HEIGHT >= plat_comp.floor_height:
				plat_comp.floor_height = body.height * Global.TILE_HEIGHT
				found = true
	if not found: plat_comp.floor_height = 0.0
	
	plat_comp.puppet.position.y = plat_comp.position_z


func jump() -> void:
	if in_jump_buffer or coyote_timer < COYOTE_TIME:
		plat_comp.velocity_z = plat_comp.jump_force
		velocity += plat_comp.dir * BASE_JUMP_BOOST
		coyote_timer = COYOTE_TIME
		jump_cut = false
	elif plat_comp.airborne and not diving:
		velocity = (plat_comp.dir if plat_comp.dir.length() > 0.0 else velocity.normalized()) * BASE_DIVE_BOOST
		plat_comp.velocity_z = BASE_DIVE_JUMP_BOOST
		diving = true
		sprite.rotation = PI/2.0
		#jump_boost = BASE_JUMP_BOOST


func kick() -> void:
	hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(weapon_holder.rotation)
	if hurtbox.check_collision():
		velocity += Vector2.RIGHT.rotated(weapon_holder.rotation) * KICK_SELF_KNOCKBACK * -1
	
	leg.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	leg.modulate = Color.TRANSPARENT
	#hurtbox.collider.disabled = false
	#await get_tree().create_timer(0.1).timeout
	#hurtbox.collider.disabled = true
