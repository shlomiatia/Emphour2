class_name RewardOption extends Control

@export var group_name := "Peasants"
@onready var title: PanelTitle = $Panel/TitleBackground
@onready var offer_root: Node2D = $Panel/Offer
@onready var arrow: Control = $Panel/Offer/Arrow
@onready var description: Label = $Panel/Description
@onready var loyalty: VBoxContainer = $Panel/Loyalty
@onready var group_icon: TextureRect = $Panel/GroupIcon
@onready var current_labels := [$Panel/Loyalty/Peasants/Change/Current, $Panel/Loyalty/Nobility/Change/Current]
@onready var target_labels := [$Panel/Loyalty/Peasants/Change/Target, $Panel/Loyalty/Nobility/Change/Target]

var offer: Dictionary
var cards: Array[Card]

signal chosen(group: String)

func setup(value: Dictionary) -> void:
	offer = value
	title.title = offer.get("title", group_name)
	group_icon.texture = load("res://Textures/%s.png" % group_name)
	if !offer["old"].is_empty():
		add_card(offer["old"], Vector2(-128, 0))
		add_card(offer["new"], Vector2(128, 0))
		arrow.show()
	else:
		add_card(offer["new"], Vector2.ZERO)
		arrow.hide()
	description.text = "Add %s to deck." % offer["new"] if offer["old"].is_empty() else "Upgrade 1 %s from deck to %s." % [offer["old"], offer["new"]]

func setup_loyalty(selected_group: String, visible: bool) -> void:
	loyalty.visible = visible
	if !visible:
		return
	set_change(0, "Peasants", 1 if selected_group == "Peasants" else -1)
	set_change(1, "Nobility", 1 if selected_group == "Nobility" else -1)

func set_change(index: int, group: String, amount: int) -> void:
	var row := loyalty.get_child(index)
	(row.get_node("Group/Icon") as TextureRect).texture = load("res://Textures/%s.png" % group)
	(row.get_node("Group/Name") as Label).text = group
	set_label(current_labels[index], CampaignState.loyalty[group])
	set_label(target_labels[index], CampaignState.loyalty_after(group, amount))

func set_label(label: Label, value: int) -> void:
	label.text = RelationData.loyalty_name(value)
	label.add_theme_color_override("font_color", RelationData.color(value))

func add_card(card_name: String, position_value: Vector2) -> void:
	var card := CardFactory.create(card_name, GameRules.Side.PLAYER)
	card.position = position_value
	card.scale = Vector2.ONE * 0.86
	offer_root.add_child(card)
	cards.append(card)

func _on_button_pressed() -> void:
	chosen.emit(group_name)

func _on_button_mouse_entered() -> void:
	set_highlighted(true)

func _on_button_mouse_exited() -> void:
	set_highlighted(false)

func set_highlighted(value: bool) -> void:
	for card in cards:
		card.set_highlighted(value)
