class_name CampaignCard extends RefCounted

var card_name: String
var faction: int

func _init(value := "Militia", card_faction := CampaignState.Faction.FRANKS) -> void:
	card_name = value
	faction = card_faction

func copy() -> CampaignCard:
	return CampaignCard.new(card_name, faction)
