class_name RewardRules extends RefCounted

const TIERS := {
	1: ["Archer", "Mantlet", "Stakes"],
	2: ["Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman"],
	3: ["Foot Knight", "Lancer", "Heavy Cavalry"],
	4: ["Knight"]
}
const NOBILITY := ["Horse Archer", "Light Cavalry", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"]
const REWARDS := {
	"Peasants": [[0, 1], [1, 2], [0, 2], [1, 2], [0, 2], [2, 2]],
	"Nobility": [[1, 2], [1, 2], [1, 2], [2, 3], [1, 3], [1, 4]]
}

static func create_offer(group: String, loyalty: int, deck: Array[String]) -> Dictionary:
	var rule: Array = REWARDS[group][clampi(loyalty, 0, 5)]
	var old_name := pick_old_card(int(rule[0]), deck)
	var choices := get_group_cards(group, int(rule[1]))
	if choices.size() > 1:
		choices.erase(old_name)
	return {"old": old_name, "new": choices.pick_random()}

static func apply_offer(offer: Dictionary, deck: Array[String]) -> void:
	if !offer["old"].is_empty():
		deck.erase(offer["old"])
	deck.append(offer["new"])

static func pick_old_card(tier: int, deck: Array[String]) -> String:
	if tier == 0:
		return ""
	var choices: Array[String]
	choices.assign(deck.filter(func(card: String) -> bool: return TIERS[tier].has(card)))
	return "" if choices.is_empty() else choices.pick_random()

static func get_group_cards(group: String, tier: int) -> Array[String]:
	var choices: Array[String]
	choices.assign(TIERS[tier].filter(func(card: String) -> bool: return NOBILITY.has(card) == (group == "Nobility")))
	return choices
