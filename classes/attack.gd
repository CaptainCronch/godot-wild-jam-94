extends Resource
class_name Attack

@export var attack_damage := 0
@export var knockback_force := 0.0
@export var stun_time := 0.0
@export var height := 0.0
@export var offset := 0.0
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
		_knock := knockback_force,
		_dir := attack_direction,
		_stun := stun_time,
		_height := height,
		_offset := offset,
		_size := size,
		):
	attack_damage = _dam
	knockback_force = _knock
	attack_direction = _dir
	stun_time = _stun
	height = _height
	offset = _offset
	size = _size
