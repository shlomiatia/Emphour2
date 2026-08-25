class_name EnemyDeck extends Resource

enum Mode {
	STATIC,
	GENERATED
}

@export var mode: Mode = Mode.STATIC
@export var static_cards: Array[String]
@export_range(1, 30) var card_count := 6
@export_range(1, 120) var total_value := 6
@export var card_pool: Array[String]

func build() -> Array[String]:
	if mode == Mode.STATIC:
		return static_cards.duplicate()
	var pool: Array[String] = card_pool if !card_pool.is_empty() else CardCatalog.CARDS
	return generate(card_count, total_value, pool)

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
	return choices.pick_random()

static func can_fill(count: int, value: int, pool: Array[String], memo: Dictionary) -> bool:
	if count == 0:
		return value == 0
	if count < 0 || value < 0:
		return false
	var key := Vector2i(count, value)
	if !memo.has(key):
		memo[key] = pool.any(func(card: String) -> bool: return can_fill(count - 1, value - CardCatalog.get_value(card), pool, memo))
	return memo[key]
