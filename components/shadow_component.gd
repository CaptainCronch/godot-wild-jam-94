extends Node2D
class_name ShadowComponent

@export var radius := 10.0
@export var shadow_scale := Vector2(1.0, 0.5)
@export var resolution := 12
@export var color := Color(0.0, 0.0, 0.0, 0.5)
@export var blob: RemoteTransform2D

var height := 0.0
var overlapping_bodies: Array[TileMapLayer] = []
var shadow: Polygon2D

@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	#shadow.position.y = -height
	#for body in area_2d.get_overlapping_bodies():
		#if body is TileMapLayer: overlapping_bodies.append(body)
	#check_height()
	#print(height)
	shadow = Polygon2D.new()
	shadow.position = blob.global_position
	blob.position.y = height
	reload()
	Global.shadow_group.add_child(shadow)
	blob.remote_path = blob.get_path_to(shadow)


func _process(_delta: float) -> void:
	blob.position.y = height


func _notification(which):
	if which == NOTIFICATION_PREDELETE:
		shadow.queue_free()


#func _physics_process(_delta: float) -> void:
	#if overlapping_bodies.size() == 0: height = 0.0
	#overlapping_bodies = []
	#for body in area_2d.get_overlapping_bodies():
		#if body is TileMapLayer: overlapping_bodies.append(body)
	#check_height()


func reload() -> void:
	shadow.polygon = Global.generate_circle_polygon(radius, resolution)
	blob.scale = shadow_scale
	(collision_shape_2d.shape as CircleShape2D).radius = radius * 0.2
	shadow.modulate = color


func check_height() -> void:
	height = 0.0
	for body in overlapping_bodies:
		if body.height * Global.TILE_HEIGHT <= height:
			height = body.height * Global.TILE_HEIGHT


func _on_area_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		overlapping_bodies.append(body)
		check_height()


func _on_area_body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		overlapping_bodies.erase(body)
		check_height()
