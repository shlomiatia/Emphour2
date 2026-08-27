class_name LoyaltyRules extends RefCounted

enum Event {
	REFUSE,
	DESERT,
	BETRAY
}

const CHANCES := {
	-1: [10, 0, 0],
	-2: [15, 5, 0],
	-3: [20, 10, 5],
	-4: [25, 15, 10],
	-5: [30, 20, 15]
}

static func roll(loyalty: int) -> Dictionary:
	var effective := clampi(loyalty, -5, 0)
	var chances: Array = CHANCES.get(effective, [0, 0, 0])
	var value := randi_range(1, 100)
	return {"roll": value, "effective_loyalty": effective, "chances": chances, "event": event_for_roll(chances, value)}

static func event_for_roll(chances: Array, roll: int) -> int:
	if roll <= chances[Event.BETRAY]:
		return Event.BETRAY
	if roll <= chances[Event.BETRAY] + chances[Event.DESERT]:
		return Event.DESERT
	if roll <= chances[Event.BETRAY] + chances[Event.DESERT] + chances[Event.REFUSE]:
		return Event.REFUSE
	return -1
