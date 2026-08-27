class_name CardDeck extends Node2D

@onready var count_label: Label = $Count

func set_card_count(value: int) -> void:
	count_label.text = str(value)
