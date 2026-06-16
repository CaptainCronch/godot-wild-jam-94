extends Node2D
class_name HealthComponent

signal damage_taken(attack: Attack)
signal healed(amount: int)
signal health_changed(amount: int)
signal stunned(attack: Attack)
signal unstunned()
signal death(attack: Attack)

#const number_popup := preload("res://Scenes/number_popup.tscn")

@export var default_color := Color.RED
@export var max_health: int
@export var invincibility_time := 0.0
@export var height := 0.0
@export var target: Node2D
@export var plat_comp: PlatformerComponent
#@export var entity := true

var health := 0
var is_stunned := false
var dead := false

@onready var invincibility_timer: Timer = $Invincibility
@onready var stun_timer: Timer = $Stun


func _ready():
	health = max_health


func damage(attack: Attack):
	if dead: return
	if not invincibility_timer.is_stopped(): return
	if attack.stun_time > 0.0: stun(attack)
	if target is CharacterBody2D:
		#target.velocity += global_position.direction_to(attack.attack_position) * attack.knockback_force
		target.velocity += attack.attack_direction * attack.knockback_force
		if is_instance_valid(plat_comp):
			plat_comp.velocity_z += attack.knockup_force
	if attack.attack_damage <= 0: return
	var total_attack := attack.attack_damage
	if total_attack <= 0:
		#spawn_number_popup("BLOCKED!!", blocked_color)
		return

	health -= total_attack
	damage_taken.emit(attack)
	health_changed.emit(-attack.attack_damage)
	#spawn_number_popup(str(roundf(total_attack)), default_color)

	if health <= 0:
		die(attack)
		return
	if is_zero_approx(invincibility_time): return
	invincibility_timer.start(invincibility_time)


func stun(attack: Attack) -> void:
	stun_timer.start(attack.stun_time)
	is_stunned = true
	stunned.emit(attack)


func die(attack):
	if dead: return
	death.emit(attack)
	dead = true
	target.queue_free()


func heal(amount: int) -> void:
	if dead: return
	if amount <= 0: return
	health = mini(health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(amount)


#func spawn_number_popup(value : String, color := Color.RED):
	#if dead: return
	#var new_popup := number_popup.instantiate()
	#get_tree().current_scene.add_child(new_popup)
	#new_popup.global_position = global_position
	#new_popup.text = value
	#new_popup.modulate = color


func _on_stun_timeout() -> void:
	is_stunned = false
	unstunned.emit()
