class_name CardDataTooltip extends Panel

@onready var description: Label = $Description

func show_data(card: Card) -> void:
    description.text = get_description(card.data, card.card_name, card.faction, card.group_identity_visible)
    description.size = description.get_combined_minimum_size()
    size = description.size + Vector2(28, 24)
    show()

func get_description(data: CardData, card_name := "", faction := CampaignState.Faction.FRANKS, show_unit_type := true) -> String:
    var lines: Array[String]
    if data.strength:
        lines.append(tr("tooltip.strength") % data.strength)
    if data.attack:
        lines.append(tr("tooltip.attack") % get_attack_name(data.attack_type))
    if data.anti_attack != CardData.AttackType.NONE:
        lines.append(tr("tooltip.block") % get_attack_name(data.anti_attack))
    if data.armored:
        lines.append(tr("tooltip.block_non_armor_piercing"))
    if show_unit_type:
        lines.append(get_unit_type(card_name, faction))
    return "\n".join(lines)

func get_unit_type(card_name: String, faction: CampaignState.Faction) -> String:
    if faction == CampaignState.Faction.ENGLISH || faction == CampaignState.Faction.HRE:
        return CampaignState.faction_name(faction)
    return CampaignState.group_name("Nobility" if RewardRules.belongs_to(card_name, "Nobility") else "Peasants")

func get_attack_name(type: CardData.AttackType) -> String:
    if type == CardData.AttackType.CAVALRY:
        return tr("attack.charge")
    return CardData.AttackType.keys()[type].capitalize()
