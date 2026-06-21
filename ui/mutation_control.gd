extends PanelContainer
class_name Mutation_Control

const CARD = preload("uid://cacok14bcvc21")

const SELECTION_TIME := 30.0

@export var upgrades: Array[Mutation]
@export var random: Mutation
@export var heal: Mutation

var heals_left := 10

@onready var card_container: HBoxContainer = %CardContainer
@onready var selection_timer: Timer = %SelectionTimer
@onready var countdown_label: Label = %CountdownLabel


func _process(_delta: float) -> void:
	countdown_label.text = str(int(selection_timer.time_left))

func select_new_mutation() -> void:
	for child in card_container.get_children():
		child.queue_free()
	
	if not upgrades.is_empty():
		var upgrade_card: Card = CARD.instantiate()
		upgrade_card.card_selected.connect(_on_card_selected)
		upgrade_card.mutation = upgrades[randi_range(0, upgrades.size() - 1)]
		card_container.add_child(upgrade_card)
		
		var random_card: Card = CARD.instantiate()
		random_card.card_selected.connect(_on_card_selected)
		random_card.mutation = random
		card_container.add_child(random_card)
		show()
	
	if heals_left > 0:
		var health_card: Card = CARD.instantiate()
		health_card.card_selected.connect(_on_card_selected)
		heal.description = heal.description.replace("NUM", str(heals_left))
		health_card.mutation = heal
		card_container.add_child(health_card)
		show()
	
	if not visible:
		close_mutation_screen()
	else:
		get_tree().paused = true
		selection_timer.start(SELECTION_TIME)
	
	#if card_container.get_child_count() == 0:
		#await get_tree().create_timer(2.0).timeout
		#hide()
		#selection_timer.stop()
		#close_mutation_screen()


func _on_selection_timer_timeout() -> void:
	close_mutation_screen()


func _on_card_selected(card: Card) -> void:
	if card.mutation == heal:
		Global.player.health_comp.heal(heals_left)
		heal.description = heal.description.replace(str(heals_left), "NUM")
		heals_left -= 1
		close_mutation_screen()
	elif card.mutation == random:
		for child in card_container.get_children():
			child.queue_free()
		
		var upgrade_card: Card = CARD.instantiate()
		upgrade_card.card_selected.connect(_on_card_selected)
		upgrade_card.mutation = upgrades[randi_range(0, upgrades.size() - 1)]
		card_container.add_child(upgrade_card)
	elif upgrades.has(card.mutation):
		Global.player.weapon.upgrade(card.mutation.code)
		upgrades.erase(card.mutation)
		close_mutation_screen()


func close_mutation_screen() -> void:
	hide()
	get_tree().paused = false
