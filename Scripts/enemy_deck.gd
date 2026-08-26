class_name EnemyDeck extends Resource

const CITY_DECKS := {
	"City 1": ["Light Cavalry", "Militia", "Militia"],
    "City 2": ["Archer", "Axeman", "Mantlet", "Stakes", "Militia", "Militia"],
}

const CITY_RULES := {
	"City 3": [9, 10], "City 4": [10, 11],
	"City 5": [10, 12], "City 6": [11, 13], "City 7": [12, 14]
}
const DEFAULT_DECK: Array[String] = ["Archer", "Militia", "Militia"]
const LEVEL_ONE_WEIGHTS := {"Militia": 6, "Archer": 2, "Stakes": 1, "Mantlet": 1}

func build(city_name: String) -> Array[String]:
	if city_name.is_empty():
		return DEFAULT_DECK.duplicate()
	if CITY_DECKS.has(city_name):
		var deck: Array[String]
		deck.assign(CITY_DECKS[city_name])
		return deck
	if CITY_RULES.has(city_name):
		var rule: Array = CITY_RULES[city_name]
		return generate(rule[0], rule[1], CardCatalog.CARDS)
	push_error("No enemy deck rule for %s" % city_name)
	return []

static func generate(count: int, value: int, pool: Array[String]) -> Array[String]:
	var memo := {}
	if count < 1 || pool.is_empty() || !can_fill(count, value, pool, memo):
		push_error("Enemy deck cannot satisfy count %d and value %d" % [count, value])
		return []
	return fill_deck(count, value, pool, memo)

static func fill_deck(count: int, value: int, pool: Array[String], memo: Dictionary) -> Array[String]:
	var deck: Array[String]
	while deck.size() < count:
		var card := pick_card(count - deck.size(), value, pool, memo)
		deck.append(card)
		value -= CardCatalog.get_value(card)
	return deck

static func pick_card(count: int, value: int, pool: Array[String], memo: Dictionary) -> String:
	var choices: Array[String]
	for card in pool:
		if can_fill(count - 1, value - CardCatalog.get_value(card), pool, memo):
			choices.append(card)
	return pick_weighted(choices)

static func pick_weighted(choices: Array[String]) -> String:
	var total := 0
	for card in choices:
		total += LEVEL_ONE_WEIGHTS.get(card, 1)
	var roll := randi_range(1, total)
	for card in choices:
		roll -= LEVEL_ONE_WEIGHTS.get(card, 1)
		if roll <= 0:
			return card
	return choices[0]

static func can_fill(count: int, value: int, pool: Array[String], memo: Dictionary) -> bool:
	if count == 0:
		return value == 0
	if count < 0 || value < 0:
		return false
	var key := Vector2i(count, value)
	if !memo.has(key):
		memo[key] = pool.any(func(card: String) -> bool: return can_fill(count - 1, value - CardCatalog.get_value(card), pool, memo))
	return memo[key]
