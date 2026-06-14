extends CharacterBody2D
class_name Player

const BASE_SPEED := 20000.0

@export var weapon: Weapon

var speed := BASE_SPEED
var dir := Vector2()


func _process(_delta: float) -> void:
	dir = Input.get_vector("left", "right", "up", "down").normalized()
	weapon.rotation = global_position.direction_to(get_global_mouse_position()).angle()
	if weapon.rotation > PI and weapon.rotation < (3.0*PI)/2.0:
		weapon.polygon.scale.y = -1.0
	else:
		weapon.polygon.scale.y = 1.0


func _physics_process(delta: float) -> void:
	velocity = dir * speed * delta
	move_and_slide()
