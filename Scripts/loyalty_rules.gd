class_name LoyaltyRules extends RefCounted

enum Event {
	REFUSE,
	DESERT,
	BETRAY
}

static func roll(loyalty: int) -> Dictionary:
	var chances := CampaignBalance.loyalty_chances(loyalty)
	if chances.is_empty():
		chances = [0, 0, 0]
	var value := randi_range(1, 100)
	return {"roll": value, "loyalty": loyalty, "chances": chances, "event": event_for_roll(chances, value)}

static func event_for_roll(chances: Array, roll: int) -> int:
	if roll <= chances[Event.BETRAY]:
		return Event.BETRAY
	if roll <= chances[Event.BETRAY] + chances[Event.DESERT]:
		return Event.DESERT
	if roll <= chances[Event.BETRAY] + chances[Event.DESERT] + chances[Event.REFUSE]:
		return Event.REFUSE
	return -1
