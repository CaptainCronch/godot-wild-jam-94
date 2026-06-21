extends Node2D
class_name World

signal collected_demon_heart

const DEMON_HEART := preload("uid://dxjje1kq03omw")

const SHAMBLER := preload("uid://ou0p1t3vjrgi")
const HOPPER := preload("uid://t4ks8c3wxa6u")
const TOSSER := preload("uid://dxof6t8a1d4bb")
const FLAPPER := preload("uid://djl73oxr2mfig")

const MAX_PLAYER_DISTANCE_SQUARED := 147456.0
const SPAWN_DELAY := 0.1
const STARTER_ENEMY_DELAY := 35.0
const DIFFICULT_ENEMY_DELAY := 30.0
#const STARTER_WAVES := [
	#20,  25,  30,  35,  40,  45,  50,  55,  60,  70,
	#100, 110, 120, 130, 140, 150, 160, 170, 180, 190,
	#200, 220, 240, 260, 280, 300, 320, 340, 360, 380,
	#400, 450, 500, 550, 600, 650, 700, 750, 800, 850,
	#900,1000,1100,1200,1300,1400,1500,1600,1700,1800,
#]

@export var ui: UI
@export var step_tick: Timer
@export var music: AudioStreamPlayer
@export var song: AudioStream
@export var spawner_nodes_starter: Array[CollisionShape2D]
@export var spawner_nodes_difficult: Array[CollisionShape2D]
@export var tilemaps_starter: Array[TileMapLayer]
@export var tilemaps_difficult: Array[TileMapLayer]

var demon_hearts_collected := 0
var game_timer := 0.0
var total_timer := 0.0
var spawn_timer := 0.0
var current_wave := 0
var enemies_to_spawn := 5
var enemy_addition := 5
var total_spawn_area: Rect2
var spawners: Array[Rect2]
var spawn_queue: Array[CharacterBody2D] = []
var game_over := false

@onready var enemy_delay := (STARTER_ENEMY_DELAY if Global.difficulty == Global.DIFFICULTIES.STARTER else DIFFICULT_ENEMY_DELAY)
@onready var tutorial_screen: ColorRect = %TutorialScreen


func _ready() -> void:
	var spawner_nodes := spawner_nodes_starter
	if Global.difficulty == Global.DIFFICULTIES.DIFFICULT:
		enemies_to_spawn = 50
		spawner_nodes = spawner_nodes_difficult
		for tilemap in tilemaps_starter:
			tilemap.enabled = false
	else:
		for tilemap in tilemaps_difficult:
			tilemap.enabled = false
	get_tree().paused = true
	
	Global.world = self
	Global.points_collected = 0
	Global.demons_killed = 0
	Global.rounds_survived = 0
	
	for i in spawner_nodes.size():
		spawners.append(Rect2(spawner_nodes[i].position - Vector2(spawner_nodes[i].shape.size.x/2, spawner_nodes[i].shape.size.y/2), spawner_nodes[i].shape.size))
	
	for spawner in spawners:
		total_spawn_area = total_spawn_area.expand(spawner.position)
		total_spawn_area = total_spawn_area.expand(spawner.position + Vector2(spawner.size.x, 0.0))
		total_spawn_area = total_spawn_area.expand(spawner.position + Vector2(0.0, spawner.size.y))
		total_spawn_area = total_spawn_area.expand(spawner.position + Vector2(spawner.size.x, spawner.size.y))
	
	await ui.start
	music.play()
	
	spawn_enemies()
	spawn_demon_heart()
	spawn_demon_heart()
	Global.player.health_comp.death.connect(func(_attack: Attack):
		game_over = true
		Global.rounds_survived = current_wave
		Global.most_demons_killed = max(Global.most_demons_killed, Global.demons_killed)
		Global.most_points_collected = max(Global.most_points_collected, Global.points_collected)
		Global.most_rounds_survived = max(Global.most_rounds_survived, Global.rounds_survived)
		
		await get_tree().create_timer(2.0).timeout
		get_tree().paused = true
		await get_tree().create_timer(1.0).timeout
		ui.show_end_screen()
	)


func _process(delta: float) -> void:
	if game_over: return
	game_timer += delta
	total_timer += delta
	if game_timer >= enemy_delay:
		game_timer = 0.0
		spawn_enemies()
	
	spawn_timer += delta
	if spawn_timer >= SPAWN_DELAY:
		pop_spawn_queue()
	
	#if Input.is_action_just_pressed("debug_key_2"):
		#select_mutation()
	#if Input.is_action_just_pressed("debug_key"):
		#Global.player.health_comp.damage(Attack.new(0, 10))
		#for _i in 100:
			#var current_enemy := SHAMBLER.instantiate()
			#current_enemy.hide()
			##current_enemy.global_position = point
			##current_enemy.plat_comp.floor_height = height
			##current_enemy.plat_comp.position_z = height
			#current_enemy.set_collision_mask_value(1, current_enemy.plat_comp.position_z > Global.TILE_HEIGHT)
			#current_enemy.set_collision_mask_value(2, current_enemy.plat_comp.position_z > Global.TILE_HEIGHT * 2)
			#current_enemy.set_collision_mask_value(3, current_enemy.plat_comp.position_z > Global.TILE_HEIGHT * 3)
			#current_enemy.plat_comp.puppet.position.y = current_enemy.plat_comp.position_z
			#current_enemy.shadow.blob.position.y = current_enemy.plat_comp.floor_height
			#get_tree().current_scene.add_child(current_enemy)
			#await get_tree().create_timer(0.05).timeout
	#if Input.is_action_just_pressed("debug_key_2"):
		#for _i in 10:
			#collected_heart()


func collected_heart() -> void:
	if game_over: return
	demon_hearts_collected += 1
	Global.points_collected += 1
	collected_demon_heart.emit()
	spawn_demon_heart()
	ui.animate_eye(demon_hearts_collected)
	if demon_hearts_collected % 10 == 0:
		await ui.eye_animation_player.animation_finished
		select_mutation()


func spawn_enemies() -> void:
	for _i in enemies_to_spawn:
		var current_enemy: Enemy
		match randi_range(0, 3):
			0: current_enemy = SHAMBLER.instantiate()
			1: current_enemy = HOPPER.instantiate()
			2: current_enemy = TOSSER.instantiate()
			3: current_enemy = FLAPPER.instantiate()
		
		spawn_queue.append(spawn_scene(current_enemy))
		#get_tree().current_scene.add_child(current_enemy)
	
	current_wave += 1
	if current_wave % 50 == 0: enemy_addition += 50
	elif current_wave % 40 == 0: enemy_addition += 20
	elif current_wave % 30 == 0: enemy_addition += 20
	elif current_wave % 20 == 0: enemy_addition += 10
	elif current_wave % 10 == 0: enemy_addition += 5
	enemies_to_spawn += enemy_addition
	if current_wave % 10 == 0: spawn_demon_heart()


func spawn_demon_heart() -> void:
	var heart: DemonHeart = spawn_scene(DEMON_HEART.instantiate())
	get_tree().current_scene.add_child(heart)


func pop_spawn_queue() -> void:
	if spawn_queue.is_empty(): return
	get_tree().current_scene.add_child(spawn_queue[spawn_queue.size() - 1])
	spawn_queue.remove_at(spawn_queue.size() - 1)


func spawn_scene(scene: CharacterBody2D, height_offset := 0.0) -> CharacterBody2D: # must have platformer component and shadow
	var point := get_spawn_point()
	
	while point.distance_squared_to(Global.player.global_position) < MAX_PLAYER_DISTANCE_SQUARED:
		point = get_spawn_point()
	
	var height: float
	for i in spawners.size():
		if spawners[i].has_point(point):
			height = i
			break
	
	scene.global_position = point
	scene.plat_comp.floor_height = height * Global.TILE_HEIGHT + height_offset
	scene.plat_comp.position_z = height * Global.TILE_HEIGHT + height_offset
	scene.set_collision_mask_value(1, scene.plat_comp.position_z > Global.TILE_HEIGHT)
	scene.set_collision_mask_value(2, scene.plat_comp.position_z > Global.TILE_HEIGHT * 2)
	scene.set_collision_mask_value(3, scene.plat_comp.position_z > Global.TILE_HEIGHT * 3)
	scene.plat_comp.puppet.position.y = scene.plat_comp.position_z
	scene.shadow.blob.position.y = scene.plat_comp.floor_height
	return scene


func get_spawn_point() -> Vector2: # random point in spawn area
	return Vector2(
			randf_range(
				total_spawn_area.position.x,
				total_spawn_area.position.x + total_spawn_area.size.x,
			),
			randf_range(
				total_spawn_area.position.y,
				total_spawn_area.position.y + total_spawn_area.size.y,
			),
	)


func select_mutation() -> void:
	if game_over: return
	ui.show_mutation_screen()


func _on_music_finished() -> void:
	music.stream = song
	music.play()
