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

static func roll(loyalty: int) -> Array[int]:
	var chances: Array = CHANCES.get(clampi(loyalty, -5, 0), [0, 0, 0])
	var roll := randi_range(1, 100)
	var event := event_for_roll(chances, roll)
	return [] if event == -1 else [event]

static func event_for_roll(chances: Array, roll: int) -> int:
	if roll <= chances[Event.BETRAY]:
		return Event.BETRAY
	if roll <= chances[Event.BETRAY] + chances[Event.DESERT]:
		return Event.DESERT
	if roll <= chances[Event.BETRAY] + chances[Event.DESERT] + chances[Event.REFUSE]:
		return Event.REFUSE
	return -1
