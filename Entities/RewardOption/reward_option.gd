class_name RewardOption extends Control

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

@export var group_name := "Peasants"
@onready var title: Label = $Panel/Title
@onready var offer_root: Node2D = $Panel/Offer
@onready var arrow: Label = $Panel/Offer/Arrow

var offer: Dictionary
var cards: Array[Card]

signal chosen(group: String)
signal hovered(group: String)
signal unhovered

func setup(value: Dictionary) -> void:
	offer = value
	title.text = group_name
	if !offer["old"].is_empty():
		add_card(offer["old"], Vector2(-150, 0))
		add_card(offer["new"], Vector2(150, 0))
		arrow.show()
	else:
		add_card(offer["new"], Vector2.ZERO)
		arrow.hide()

func add_card(card_name: String, position_value: Vector2) -> void:
	var card := CARD_SCENE.instantiate() as Card
	card.card_name = card_name
	card.position = position_value
	card.scale = Vector2.ONE * 0.86
	offer_root.add_child(card)
	cards.append(card)

func _on_button_pressed() -> void:
	chosen.emit(group_name)

func _on_button_mouse_entered() -> void:
	set_highlighted(true)
	hovered.emit(group_name)

func _on_button_mouse_exited() -> void:
	set_highlighted(false)
	unhovered.emit()

func set_highlighted(value: bool) -> void:
	for card in cards:
		card.set_highlighted(value)
