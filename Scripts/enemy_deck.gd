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
const LEVEL_ONE_WEIGHTS := {"Militia": 6, "Archer": 2, "Stakes": 1, "Mantlet": 1}
const VALUE_SCALE := 2

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

static func generate(count: int, value: float, pool: Array[String]) -> Array[String]:
	var memo := {}
	var budget := roundi(value * VALUE_SCALE)
	if count < 1 || pool.is_empty() || !can_fill(count, budget, pool, memo):
		push_error("Enemy deck cannot satisfy count %d and value %.1f" % [count, value])
		return []
	return fill_deck(count, budget, pool, memo)

static func fill_deck(count: int, budget: int, pool: Array[String], memo: Dictionary) -> Array[String]:
	var deck: Array[String]
	while deck.size() < count:
		var card := pick_card(count - deck.size(), budget, pool, memo)
		deck.append(card)
		budget -= value_units(card)
	return deck

static func pick_card(count: int, budget: int, pool: Array[String], memo: Dictionary) -> String:
	var choices: Array[String]
	for card in pool:
		if can_fill(count - 1, budget - value_units(card), pool, memo):
			choices.append(card)
	return pick_weighted(choices, budget)

static func pick_weighted(choices: Array[String], budget: int) -> String:
	var total := 0
	for card in choices:
		total += LEVEL_ONE_WEIGHTS.get(card, 1)
	var roll := randi_range(1, total)
	var remaining_roll := roll
	for card in choices:
		remaining_roll -= LEVEL_ONE_WEIGHTS.get(card, 1)
		if remaining_roll <= 0:
			print_roll(roll, total, choices, card, budget - value_units(card))
			return card
	return choices[0]

static func print_roll(roll: int, total: int, choices: Array[String], selected: String, remaining: int) -> void:
	var chances: Array[String]
	for card in choices:
		chances.append("%s=%.1f%%" % [card, LEVEL_ONE_WEIGHTS.get(card, 1) * 100.0 / total])
	print("Enemy deck roll: roll=%d/%d selected=%s remaining=%.1f chances=[%s]" % [roll, total, selected, remaining / float(VALUE_SCALE), ", ".join(chances)])

static func can_fill(count: int, value: int, pool: Array[String], memo: Dictionary) -> bool:
	if count == 0:
		return value == 0 || value == 1
	if count < 0 || value < 0:
		return false
	var key := Vector2i(count, value)
	if !memo.has(key):
		memo[key] = pool.any(func(card: String) -> bool: return can_fill(count - 1, value - value_units(card), pool, memo))
	return memo[key]

static func value_units(card_name: String) -> int:
	return roundi(CardCatalog.get_value(card_name) * VALUE_SCALE)
