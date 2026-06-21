extends Resource
class_name Attack

@export var attack_damage := 0
@export var player_damage := 1
@export var knockback_force := 0.0
@export var knockup_force := 0.0
@export var stun_time := 0.0
@export var height := 0.0
@export var size := 0.0
#@export var origin_name : String
#@export var attack_type : ATTACK_TYPE

#var attack_position := Vector2.ZERO
var attack_direction := Vector2.ZERO

#enum ATTACK_TYPE {
#
#}


func _init(
		_dam := attack_damage,
		_pdam := player_damage,
		_knock := knockback_force,
		_up := knockup_force,
		_dir := attack_direction,
		_stun := stun_time,
		_height := height,
		_size := size,
		):
	attack_damage = _dam
	player_damage = _pdam
	knockback_force = _knock
	knockup_force = _up
	attack_direction = _dir
	stun_time = _stun
	height = _height
	size = _size
	
	resource_local_to_scene = true
