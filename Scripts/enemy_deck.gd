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
	if CITY_RULES.has(city_name):
		var rule: Array = CITY_RULES[city_name]
		return generate(rule[0], rule[1], get_pool(city_name))
	push_error("No enemy deck rule for %s" % city_name)
	return []

static func get_pool(city_name: String) -> Array[String]:
	var pool := CardCatalog.CARDS.duplicate()
	if !CampaignState.crossbowman_unlocked(city_name):
		pool.erase("Crossbowman")
	return pool

static func generate(count: int, value: int, pool: Array[String]) -> Array[String]:
	return EnemyDeckPicker.generate(count, value, pool)
