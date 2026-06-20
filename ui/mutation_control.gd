extends PanelContainer
class_name Mutation_Control
const CARD = preload("uid://cacok14bcvc21")

@onready var card_container: HBoxContainer = %CardContainer
@onready var selection_timer: Timer = %SelectionTimer
@onready var countdown_label: Label = %CountdownLabel

@export var card_amount : int = 3

func _process(delta: float) -> void:
	countdown_label.text = str(int(selection_timer.time_left))

func select_new_mutation() -> void:
	show()
	selection_timer.start()
	for child in card_container.get_children():
		child.queue_free()
	for i in card_amount:
		var card : Card = CARD.instantiate()
		card.card_selected.connect(card_selected)
		card_container.add_child(card)


func _on_selection_timer_timeout() -> void:
	close_mutation_screen()

func card_selected(card : Card) -> void:
	close_mutation_screen()

func close_mutation_screen() -> void:
	hide()
