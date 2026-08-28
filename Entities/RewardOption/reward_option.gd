class_name RewardOption extends Control

const SHIELD := preload("res://Textures/Shield.png")

@export var group_name := "Peasants"
@onready var panel: Panel = $Panel
@onready var title: PanelTitle = $Panel/TitleBackground
@onready var offer_root: Node2D = $Panel/Offer
@onready var arrow: Control = $Panel/Offer/Arrow
@onready var description: Label = $Panel/Description
@onready var loyalty: VBoxContainer = $Panel/Loyalty
@onready var group_icon: TextureRect = $Panel/GroupIcon
@onready var faction_shield: TextureRect = $Panel/FactionShield
@onready var current_labels := [$Panel/Loyalty/Peasants/Change/Current, $Panel/Loyalty/Nobility/Change/Current]
@onready var target_labels := [$Panel/Loyalty/Peasants/Change/Target, $Panel/Loyalty/Nobility/Change/Target]

var offer: Dictionary
var cards: Array[Card]
var choice_id := ""

signal chosen(group: String)

func setup(value: Dictionary) -> void:
	offer = value
	title.title = offer["title"] if offer.has("faction") else CampaignState.group_name(offer.get("title", group_name))
	group_icon.visible = !offer.has("faction")
	faction_shield.visible = offer.has("faction")
	if faction_shield.visible:
		faction_shield.modulate = CampaignState.faction_color(offer["faction"])
	if group_icon.visible:
		group_icon.texture = load("res://Textures/%s.png" % group_name)
	if !offer["old"].is_empty():
		add_card(offer["old"], Vector2(-128, 0), offer.get("old_faction", CampaignState.Faction.FRANKS))
		add_card(offer["new"], Vector2(128, 0), offer.get("faction", CampaignState.Faction.FRANKS))
		arrow.show()
	else:
		add_card(offer["new"], Vector2.ZERO, offer.get("faction", CampaignState.Faction.FRANKS))
		arrow.hide()
	description.text = offer_text()

func offer_text() -> String:
	var old_name := CardCatalog.display_name(offer["old"])
	var new_name := CardCatalog.display_name(offer["new"])
	return tr("reward.add") % new_name if offer["old"].is_empty() else tr("reward.upgrade") % [old_name, new_name]

func setup_loyalty(selected_group: String, visible: bool) -> void:
	loyalty.visible = visible
	if !visible:
		return
	set_change(0, "Peasants", 1 if selected_group == "Peasants" else -1)
	set_change(1, "Nobility", 1 if selected_group == "Nobility" else -1)

func setup_foreign_loyalty() -> void:
	loyalty.show()
	set_foreign_change(0, CampaignState.Faction.ENGLISH)
	set_foreign_change(1, CampaignState.Faction.HRE)

func set_change(index: int, group: String, amount: int) -> void:
	var row := loyalty.get_child(index)
	(row.get_node("Group/Icon") as TextureRect).texture = load("res://Textures/%s.png" % group)
	(row.get_node("Group/Name") as Label).text = CampaignState.group_name(group)
	(row.get_node("Change/Arrow") as Control).show()
	(row.get_node("Change/Target") as Control).show()
	set_label(current_labels[index], CampaignState.loyalty[group])
	set_label(target_labels[index], CampaignState.loyalty_after(group, amount))

func set_foreign_change(index: int, faction: CampaignState.Faction) -> void:
	var row := loyalty.get_child(index)
	(row.get_node("Group/Icon") as TextureRect).texture = SHIELD
	(row.get_node("Group/Icon") as TextureRect).modulate = CampaignState.faction_color(faction)
	(row.get_node("Group/Name") as Label).text = CampaignState.faction_name(faction)
	(row.get_node("Change/Arrow") as Control).hide()
	(row.get_node("Change/Target") as Control).hide()
	set_label(current_labels[index], CampaignState.foreign_loyalty[faction])

func set_label(label: Label, value: int) -> void:
	label.text = RelationData.loyalty_name(value)
	label.add_theme_color_override("font_color", RelationData.color(value))

func add_card(card_name: String, position_value: Vector2, faction: CampaignState.Faction) -> void:
	var card := CardFactory.create(card_name, GameRules.Side.PLAYER, faction)
	card.position = position_value
	card.scale = Vector2.ONE * 0.86
	offer_root.add_child(card)
	cards.append(card)

func _on_button_pressed() -> void:
	chosen.emit(choice_id if !choice_id.is_empty() else group_name)

func _on_button_mouse_entered() -> void:
	set_highlighted(true)

func _on_button_mouse_exited() -> void:
	set_highlighted(false)

func set_highlighted(value: bool) -> void:
	panel.modulate = Card.HIGHLIGHT_COLOR if value else Color.WHITE
