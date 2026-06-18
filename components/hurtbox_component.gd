extends Area2D
class_name HurtBoxComponent

signal hit(hitbox: HitboxComponent)

@export var attack: Attack
@export var updates := true
@export var update_time := 0.0
@export var multihit := false
#@export var detection_groups: PackedStringArray
#@export var flash_speed := 0.1

var update_timer := 0.0

@onready var collider : CollisionShape2D = $CollisionShape2D


#func _ready():
	#if detection_groups[0].is_empty():
		#push_error("HitboxComponent of ", str(self), " has no detection groups!")


func _physics_process(delta) -> void:
	#if flash_speed > 0.0: # if has flash speed and time out then check collisions and restart timer
		#flash_timer += delta
		#if flash_timer >= flash_speed:
			#flash_timer = 0.0
		#else: return
	if not monitoring or not updates: return
	if update_time <= 0.0:
		check_collision()
	else:
		update_timer += delta
		if update_timer >= update_time:
			check_collision()
			update_timer = 0.0


func check_collision() -> bool:
	var hit_anything := false
	for area in get_overlapping_areas():
		if area is HitboxComponent:
			#for group in detection_groups:
				#if area.is_in_group(group):
					#attack.attack_position = global_position
					
					# if area is within vertical bullet range
					if area.health_comp.height >= (attack.height + attack.offset) - (attack.size/2):
						if area.health_comp.height <= (attack.height + attack.offset) + (attack.size/2):
							#print(attack.height + attack.offset, " | ", area.health_comp.height)
							if attack.attack_direction == Vector2.ZERO:
								attack.attack_direction = global_position.direction_to(area.global_position)
								hit.emit(area)
								area.damage(attack)
								attack.attack_direction = Vector2.ZERO
							else:
								hit.emit(area)
								area.damage(attack)
							
							hit_anything = true
							if not multihit: break
	return hit_anything
