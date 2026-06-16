extends Node2D

const SHAMBLER = preload("uid://ou0p1t3vjrgi")

@export var step_tick: Timer


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_key"):
		for _i in 5:
			var shambler := SHAMBLER.instantiate()
			add_child(shambler)
