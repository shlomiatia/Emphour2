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
	var result: Array[int]
	var chances: Array = CHANCES.get(clampi(loyalty, -5, 0), [0, 0, 0])
	for event in Event.size():
		if randi_range(1, 100) <= chances[event]:
			result.append(event)
	return result
