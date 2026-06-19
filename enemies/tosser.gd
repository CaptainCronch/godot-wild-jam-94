extends Enemy
class_name Tosser

const TOSSER_BULLET := preload("uid://covbg35vkc3vd")

const HEIGHT_OFFSET := -40.0
const CLIMB_ACCELERATION := 15.0
const CLIMB_SPEED := -4.0
const CLIMB_BOOST := 1000.0

@export var wall_check: RayCast2D

var step_tween: Tween
var shoot_duration := 5.0
var walk_duration := 5.0


func _init() -> void:
	_player_follow_factor = -1.0
	_separation_factor = 3.0


func _ready() -> void:
	super()
	await get_tree().current_scene.step_tick.timeout
	if is_instance_valid(step_tween): step_tween.kill()
	step_tween = create_tween().set_loops(0)
	step_tween.tween_callback(func():
		current_speed = plat_comp.base_speed
		disable_player_dir = false
	)
	step_tween.tween_interval(walk_duration)
	step_tween.tween_callback(func():
		current_speed = SEPARATION_SPEED
		disable_player_dir = true
	)
	step_tween.tween_interval(shoot_duration / 2.0)
	step_tween.tween_callback(func():
		shoot()
	)
	step_tween.tween_interval(shoot_duration / 2.0)


func _process(delta: float) -> void: if not disable_player_dir: ai_timer += delta


func _physics_process(delta: float) -> void:
	super(delta)
	
	wall_check.set_collision_mask_value(1, plat_comp.position_z > Global.TILE_HEIGHT)
	wall_check.set_collision_mask_value(2, plat_comp.position_z > Global.TILE_HEIGHT * 2)
	wall_check.set_collision_mask_value(3, plat_comp.position_z > Global.TILE_HEIGHT * 3)
	
	wall_check.rotation = -player_dir.angle()
	
	if wall_check.is_colliding() and not disable_player_dir:
		plat_comp.velocity_z = CLIMB_SPEED
		velocity += player_dir * CLIMB_BOOST * delta
		plat_comp.air_acceleration = CLIMB_ACCELERATION
		plat_comp.speed = 0.0
	else:
		plat_comp.air_acceleration = plat_comp.base_air_acceleration
		plat_comp.speed = current_speed


func shoot() -> void:
	if Global.player.plat_comp.floor_height > plat_comp.floor_height: return
	
	var bullet: TosserBullet = TOSSER_BULLET.instantiate()
	bullet.height = plat_comp.position_z
	bullet.global_position = global_position
	bullet.angle = player_dir.angle()
	
	bullet.shadow.height = plat_comp.floor_height
	bullet.shadow.blob.position.y = plat_comp.floor_height
	
	bullet.sprite.rotation = bullet.angle
	bullet.sprite.position.y = plat_comp.position_z + HEIGHT_OFFSET
	
	bullet.hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(bullet.angle)
	bullet.hurtbox.attack.height = plat_comp.position_z
	get_tree().current_scene.add_child(bullet)
