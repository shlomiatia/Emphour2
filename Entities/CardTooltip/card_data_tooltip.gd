class_name CardDataTooltip extends Panel

@onready var description: Label = $Description

func show_data(data: CardData) -> void:
    description.text = get_description(data)
    description.size = description.get_combined_minimum_size()
    size = description.size + Vector2(28, 24)
    show()

func get_description(data: CardData) -> String:
    var lines: Array[String]
    if data.strength:
        lines.append(tr("tooltip.strength") % data.strength)
    if data.attack:
        lines.append(tr("tooltip.attack") % get_attack_name(data.attack_type))
    if data.anti_attack != CardData.AttackType.NONE:
        lines.append(tr("tooltip.block") % get_attack_name(data.anti_attack))
    if data.armored:
        lines.append(tr("tooltip.block_non_armor_piercing"))
    return "\n".join(lines)

func get_attack_name(type: CardData.AttackType) -> String:
    if type == CardData.AttackType.CAVALRY:
        return tr("attack.charge")
    return CardData.AttackType.keys()[type].capitalize()
