extends Node2D
class_name World

const SHAMBLER = preload("uid://ou0p1t3vjrgi")
const HOPPER = preload("uid://t4ks8c3wxa6u")
const TOSSER = preload("uid://dxof6t8a1d4bb")
const FLAPPER = preload("uid://djl73oxr2mfig")

@export var ui: UI
@export var step_tick: Timer

var demon_hearts_collected := 0


func _ready() -> void:
	Global.world = self
	Global.navigation_layers.append($Base)
	Global.navigation_layers.append($Height1)
	Global.navigation_layers.append($Height2)
	Global.navigation_layers.append($Height3)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_key"):
		for _i in 100:
			var enemy := FLAPPER.instantiate()
			add_child(enemy)
