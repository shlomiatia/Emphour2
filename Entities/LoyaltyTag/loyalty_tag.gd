class_name LoyaltyTag extends Label

func set_value(value: int) -> void:
	text = RelationData.loyalty_label(value)
	add_theme_color_override("font_color", RelationData.color(value))
