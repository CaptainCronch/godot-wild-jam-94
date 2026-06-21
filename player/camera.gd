extends Node2D
class_name CameraHolder

const BASE_PAN_FACTOR := 0.3
const BASE_DECAY := 10.0
const MAX_OFFSET := Vector2(125, 100)
const TRAUMA_POWER := 2.0
const BASE_KICKBACK_DECAY := 50.0
const MAX_KICKBACK := Vector2(500, 500)

var trauma := 0.0
var noise_position := 0.0

@export var player: Player
@export var camera: Camera2D
@export var noise: FastNoiseLite


func _ready() -> void:
	noise.seed = randi()


func _process(delta: float) -> void:
	if player.health_comp.dead: return
	position = get_local_mouse_position() * BASE_PAN_FACTOR
	position.y += player.plat_comp.position_z #Global.decay_towards(position.y, -player.plat_comp.floor_height, SPEED_Z, delta)
	
	if trauma > 0.0:
		trauma = Global.decay_towards(trauma, 0.0, BASE_DECAY, delta)
		
		noise_position += 1.0 #Vector2(randf(), randf()) * NOISE_SPEED * delta
		
		var amount := pow(trauma, TRAUMA_POWER)
		camera.offset = (MAX_OFFSET * amount *
				Vector2(noise.get_noise_2d(amount, noise_position),
				noise.get_noise_2d(noise_position, amount)))
	
	if camera.position.length_squared() > 0.0:
		camera.position = Global.decay_towards_vec2(camera.position, Vector2.ZERO, BASE_KICKBACK_DECAY, delta)


func shake(power: float) -> void: trauma = minf(trauma + power, 1.0)


func kick(pos: Vector2) -> void: camera.position = (camera.position + pos).clamp(-MAX_KICKBACK, MAX_KICKBACK)
