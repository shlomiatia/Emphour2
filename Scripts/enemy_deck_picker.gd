class_name EnemyDeckPicker extends RefCounted

const LEVEL_ONE_WEIGHTS := {"Militia": 6, "Archer": 2, "Stakes": 1, "Mantlet": 1}

static func generate(count: int, value: int, pool: Array[String]) -> Array[String]:
	var memo := {}
	if count < 1 || pool.is_empty() || !can_fill(count, value, pool, memo):
		push_error("Enemy deck cannot satisfy count %d and value %d" % [count, value])
		return []
	return fill_deck(count, value, pool, memo)

static func fill_deck(count: int, budget: int, pool: Array[String], memo: Dictionary) -> Array[String]:
	var deck: Array[String]
	while deck.size() < count:
		var card := pick_card(count - deck.size(), budget, pool, memo)
		deck.append(card)
		budget -= card_value(card)
	return deck

static func pick_card(count: int, budget: int, pool: Array[String], memo: Dictionary) -> String:
	var choices := feasible_cards(count, budget, pool, memo)
	var tiers := get_tiers(choices)
	var roll := randi_range(1, tiers.size())
	var tier := tiers[roll - 1]
	print_tier_roll(roll, tiers, tier)
	var cards := choices.filter(func(card: String) -> bool: return card_value(card) == tier)
	return pick_tier_card(cards, tier, budget)

static func feasible_cards(count: int, budget: int, pool: Array[String], memo: Dictionary) -> Array[String]:
	var choices: Array[String]
	for card in pool:
		if can_fill(count - 1, budget - card_value(card), pool, memo):
			choices.append(card)
	return choices

static func get_tiers(cards: Array[String]) -> Array[int]:
	var tiers: Array[int]
	for card in cards:
		var tier := card_value(card)
		if !tiers.has(tier):
			tiers.append(tier)
	tiers.sort()
	return tiers

static func pick_tier_card(cards: Array[String], tier: int, budget: int) -> String:
	var total := cards.size() if tier > 1 else total_weight(cards)
	var roll := randi_range(1, total)
	var selected := select_card(cards, tier, roll)
	print_card_roll(roll, total, cards, tier, selected, budget - tier)
	return selected

static func total_weight(cards: Array[String]) -> int:
	var total := 0
	for card in cards:
		total += LEVEL_ONE_WEIGHTS.get(card, 1)
	return total

static func select_card(cards: Array[String], tier: int, roll: int) -> String:
	for card in cards:
		roll -= LEVEL_ONE_WEIGHTS.get(card, 1) if tier == 1 else 1
		if roll <= 0:
			return card
	return cards[0]

static func print_tier_roll(roll: int, tiers: Array[int], selected: int) -> void:
	var chances: Array[String]
	for tier in tiers:
		chances.append("%d=%.1f%%" % [tier, 100.0 / tiers.size()])
	print("Enemy tier roll: roll=%d/%d selected=%d chances=[%s]" % [roll, tiers.size(), selected, ", ".join(chances)])

static func print_card_roll(roll: int, total: int, cards: Array[String], tier: int, selected: String, remaining: int) -> void:
	var chances: Array[String]
	for card in cards:
		var weight: int = LEVEL_ONE_WEIGHTS.get(card, 1) if tier == 1 else 1
		chances.append("%s=%.1f%%" % [card, weight * 100.0 / total])
	print("Enemy card roll: tier=%d roll=%d/%d selected=%s remaining=%d chances=[%s]" % [tier, roll, total, selected, remaining, ", ".join(chances)])

static func can_fill(count: int, value: int, pool: Array[String], memo: Dictionary) -> bool:
	if count == 0:
		return value == 0
	if count < 0 || value < 0:
		return false
	var key := Vector2i(count, value)
	if !memo.has(key):
		memo[key] = pool.any(func(card: String) -> bool: return can_fill(count - 1, value - card_value(card), pool, memo))
	return memo[key]

static func card_value(card_name: String) -> int:
	return roundi(CardCatalog.get_value(card_name))
