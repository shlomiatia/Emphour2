class_name RewardScreen extends Node2D

@onready var peasants: RewardOption = $CanvasLayer/Peasants
@onready var nobility: RewardOption = $CanvasLayer/Nobility
@onready var tooltip: Panel = $CanvasLayer/LoyaltyTooltip
@onready var current_labels := [$CanvasLayer/LoyaltyTooltip/Grid/PeasantsCurrent, $CanvasLayer/LoyaltyTooltip/Grid/NobilityCurrent]
@onready var target_labels := [$CanvasLayer/LoyaltyTooltip/Grid/PeasantsTarget, $CanvasLayer/LoyaltyTooltip/Grid/NobilityTarget]
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var offers := {}
var input_disabled := false

func _ready() -> void:
	create_options()

func create_options() -> void:
	for group in ["Peasants", "Nobility"]:
		offers[group] = RewardRules.create_offer(group, CampaignState.loyalty[group], CampaignState.player_deck)
	peasants.setup(offers["Peasants"])
	nobility.setup(offers["Nobility"])

func _on_option_chosen(group: String) -> void:
	if input_disabled:
		return
	input_disabled = true
	RewardRules.apply_offer(offers[group], CampaignState.player_deck)
	apply_loyalty(group)
	CampaignState.capture_selected_city()
	confirm_sound.play()
	await fade.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Map/Map.tscn")

func apply_loyalty(group: String) -> void:
	var other := "Nobility" if group == "Peasants" else "Peasants"
	CampaignState.change_loyalty(group, 1)
	CampaignState.change_loyalty(other, -1)

func _on_option_hovered(group: String) -> void:
	set_change(0, "Peasants", 1 if group == "Peasants" else -1)
	set_change(1, "Nobility", 1 if group == "Nobility" else -1)
	tooltip.position.x = 110.0 if group == "Peasants" else 1090.0
	tooltip.show()

func set_change(index: int, group: String, amount: int) -> void:
	set_label(current_labels[index], CampaignState.loyalty[group])
	set_label(target_labels[index], CampaignState.loyalty_after(group, amount))

func set_label(label: Label, value: int) -> void:
	label.text = RelationData.loyalty_name(value)
	label.add_theme_color_override("font_color", RelationData.color(value, true))

func _on_option_unhovered() -> void:
	tooltip.hide()
