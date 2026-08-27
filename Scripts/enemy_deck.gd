class_name EnemyDeck extends Resource

const CITY_DECKS := {
	"City 1": ["Light Cavalry", "Militia", "Militia"],
	"City 2": ["Archer", "Axeman", "Mantlet", "Stakes", "Militia", "Militia"],
}
const CITY_RULES := {
	"City 3": [10, 12],
	"City 4": [12, 14],
	"City 5": [10, 17],
	"City 6": [13, 18],
	"City 7": [13, 20]
}
const DEFAULT_DECK: Array[String] = ["Archer", "Militia", "Militia"]

func build(city_name: String) -> Array[String]:
	if city_name.is_empty():
		return DEFAULT_DECK.duplicate()
	if CITY_DECKS.has(city_name):
		var deck: Array[String]
		deck.assign(CITY_DECKS[city_name])
		return deck
	var final_rule := get_final_rule(city_name)
	if !final_rule.is_empty():
		return generate(final_rule[0], final_rule[1], get_group_pool(final_rule[2]))
	if CITY_RULES.has(city_name):
		var rule: Array = CITY_RULES[city_name]
		return generate(rule[0], rule[1], get_pool(city_name))
	push_error("No enemy deck rule for %s" % city_name)
	return []

func get_final_rule(city_name: String) -> Array:
	if city_name != "City 7":
		return []
	if CampaignState.loyalty["Nobility"] < 0:
		return [9, 24, "Nobility"]
	if CampaignState.loyalty["Peasants"] < 0:
		return [13, 20, "Peasants"]
	return []

static func get_group_pool(group: String) -> Array[String]:
	return CardCatalog.CARDS.filter(func(card: String) -> bool: return RewardRules.belongs_to(card, group))

static func get_pool(city_name: String) -> Array[String]:
	var pool := CardCatalog.CARDS.duplicate()
	if !CampaignState.crossbowman_unlocked(city_name):
		pool.erase("Crossbowman")
	return pool

static func generate(count: int, value: int, pool: Array[String]) -> Array[String]:
	return EnemyDeckPicker.generate(count, value, pool)
