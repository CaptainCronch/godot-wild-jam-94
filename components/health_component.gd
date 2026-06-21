extends Node2D
class_name HealthComponent

signal damage_taken(attack: Attack)
signal healed(amount: int)
signal health_changed(health: int)
signal stunned(attack: Attack)
signal unstunned()
signal death(attack: Attack)

@export var max_health: int
@export var invincibility_time := 0.0
@export var max_damage := 9999
@export var is_player := false
@export var knockback_factor := 1.0
@export var knockup_factor := 1.0
@export var target: Node2D
@export var plat_comp: PlatformerComponent

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
		target.velocity += attack.attack_direction * attack.knockback_force * knockback_factor
		if is_instance_valid(plat_comp):
			plat_comp.velocity_z += attack.knockup_force * knockup_factor
	damage_taken.emit(attack)
	var current_damage := attack.attack_damage if not is_player else attack.player_damage
	if current_damage <= 0: return
	var total_attack := mini(current_damage, max_damage)

	health -= total_attack
	health_changed.emit(health)

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
	#target.queue_free()


func heal(amount: int) -> void:
	if dead: return
	if amount <= 0: return
	health = mini(health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(health)


func _on_stun_timeout() -> void:
	is_stunned = false
	unstunned.emit()
