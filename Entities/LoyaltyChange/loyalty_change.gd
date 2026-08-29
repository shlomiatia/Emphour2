class_name LoyaltyChange extends HBoxContainer

@onready var icon: TextureRect = $Group/Icon
@onready var name_label: Label = $Group/Name
@onready var single: HBoxContainer = $Single
@onready var reward: HBoxContainer = $Reward
@onready var comparison: HBoxContainer = $Comparison
@onready var single_tag: LoyaltyTag = $Single/Tag
@onready var reward_tag: LoyaltyTag = $Reward/Tag
@onready var reward_arrow: TextureRect = $Reward/Arrow
@onready var current_tag: LoyaltyTag = $Comparison/Current
@onready var target_tag: LoyaltyTag = $Comparison/Target

func set_group(texture_value: Texture2D, name_value: String, color := Color.WHITE) -> void:
	icon.texture = texture_value
	icon.modulate = color
	name_label.text = name_value

func show_level(value: int) -> void:
	single.show()
	reward.hide()
	comparison.hide()
	single_tag.set_value(value)

func show_reward(value: int, direction: int) -> void:
	single.hide()
	reward.show()
	comparison.hide()
	reward_tag.set_value(value)
	reward_arrow.visible = direction != 0
	reward_arrow.flip_v = direction > 0
	reward_arrow.modulate = RelationData.change_color(direction)

func show_comparison(current: int, target: int) -> void:
	single.hide()
	reward.hide()
	comparison.show()
	current_tag.set_value(current)
	target_tag.set_value(target)
