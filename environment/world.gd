extends Node2D
class_name World

signal collected_demon_heart

const DEMON_HEART := preload("uid://dxjje1kq03omw")

const SHAMBLER := preload("uid://ou0p1t3vjrgi")
const HOPPER := preload("uid://t4ks8c3wxa6u")
const TOSSER := preload("uid://dxof6t8a1d4bb")
const FLAPPER := preload("uid://djl73oxr2mfig")

const ENEMY_SPAWN_HEIGHT := -256.0
const STARTER_ENEMY_DELAY := 30.0
const DIFFICULT_ENEMY_DELAY := 25.0
const STARTER_WAVES := [
	20,  25,  30,  35,  40,  45,  50,  55,  60,  70,
	100, 110, 120, 130, 140, 150, 160, 170, 180, 190,
	200, 220, 240, 260, 280, 300, 320, 340, 360, 380,
	400, 450, 500, 550, 600, 650, 700, 750, 800, 850,
	900,1000,1100,1200,1300,1400,1500,1600,1700,1800,
]

@export var ui: UI
@export var step_tick: Timer
@export var spawners: Node2D

var demon_hearts_collected := 0
var game_timer := 0.0
var total_timer := 0.0
var current_wave := 0

@onready var positions := spawners.get_children()
@onready var enemy_delay := (STARTER_ENEMY_DELAY if Global.difficulty == Global.DIFFICULTIES.STARTER else DIFFICULT_ENEMY_DELAY)


func _ready() -> void:
	Global.world = self
	Global.navigation_layers.append($Base)
	Global.navigation_layers.append($Height1)
	Global.navigation_layers.append($Height2)
	Global.navigation_layers.append($Height3)
	
	spawn_enemies()
	spawn_demon_heart()


func _process(delta: float) -> void:
	game_timer += delta
	total_timer += delta
	if game_timer >= enemy_delay:
		game_timer = 0.0
		spawn_enemies()
	
	if Input.is_action_just_pressed("debug_key"):
		for _i in 100:
			var enemy := FLAPPER.instantiate()
			add_child(enemy)
	if Input.is_action_just_pressed("debug_key_2"):
		collected_heart()

func collected_heart() -> void:
	demon_hearts_collected += 1
	collected_demon_heart.emit()
	spawn_demon_heart()
	ui.animate_eye(demon_hearts_collected)
	if demon_hearts_collected % 10 == 0:
		select_mutation()


func spawn_enemies() -> void:
	for _i in STARTER_WAVES[current_wave]:
		var point: Marker2D = positions[randi_range(0, positions.size() - 1)]
		var current_enemy: Enemy
		
		match randi_range(0, 3):
			0: current_enemy = SHAMBLER.instantiate()
			1: current_enemy = HOPPER.instantiate()
			2: current_enemy = TOSSER.instantiate()
			3: current_enemy = FLAPPER.instantiate()
		
		current_enemy.global_position = point.global_position
		current_enemy.plat_comp.floor_height = ENEMY_SPAWN_HEIGHT
		current_enemy.plat_comp.position_z = ENEMY_SPAWN_HEIGHT
		get_tree().current_scene.add_child(current_enemy)
	
	current_wave += 1


func spawn_demon_heart() -> void:
	var point: Marker2D = positions[randi_range(0, positions.size() - 1)]
	var heart: DemonHeart = DEMON_HEART.instantiate()
	heart.global_position = point.global_position
	heart.plat_comp.floor_height = ENEMY_SPAWN_HEIGHT
	heart.plat_comp.position_z = ENEMY_SPAWN_HEIGHT
	get_tree().current_scene.add_child(heart)

func select_mutation() -> void:
	ui.show_mutation_screen()
