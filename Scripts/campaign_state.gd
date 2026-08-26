class_name CampaignState extends RefCounted

enum Faction {
	FRANKS,
	REBELS
}

enum Relation {
	WAR = -5,
	HOSTILE,
	CLOSE_BORDERS,
	DIPLOMATIC_PROTEST,
	TRADE_EMBARGO,
	NEUTRAL,
	TRADE_PACT,
	NON_AGGRESSION_PACT,
	OPEN_BORDERS,
	DEFENSIVE_ALLIANCE,
	MILITARY_ALLIANCE
}

const STARTING_DECK: Array[String] = ["Archer", "Mantlet", "Stakes", "Light Cavalry", "Militia", "Militia", "Militia", "Militia", "Militia", "Militia"]
const STARTING_OWNERS := {
	"City 1": Faction.REBELS,
	"City 2": Faction.REBELS,
	"City 3": Faction.REBELS,
	"City 4": Faction.REBELS,
	"City 5": Faction.REBELS,
	"City 6": Faction.REBELS
}
const CITY_SLOTS := {
	"City 1": 3, "City 2": 3, "City 3": 4, "City 4": 4,
	"City 5": 5, "City 6": 5, "City 7": 5
}

static var selected_city := ""
static var player_deck: Array[String] = STARTING_DECK.duplicate()
static var public_loyalty := {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
static var internal_loyalty := {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
static var city_owner := STARTING_OWNERS.duplicate()

static func change_loyalty(group: String, amount: int) -> void:
	public_loyalty[group] = clampi(public_loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)
	internal_loyalty[group] = clampi(internal_loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func public_loyalty_after(group: String, amount: int) -> int:
	return clampi(public_loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func lose_loyalty(group: String) -> void:
	internal_loyalty[group] = clampi(internal_loyalty[group] - 1, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func capture_selected_city() -> void:
	if !city_owner.has(selected_city):
		return
	var was_final := is_final_battle()
	city_owner[selected_city] = Faction.FRANKS
	if city_owner.values().all(func(owner: int) -> bool: return owner == Faction.FRANKS) && !was_final:
		city_owner["City 1"] = Faction.REBELS

static func is_final_battle() -> bool:
	return city_owner["City 1"] == Faction.REBELS && city_owner.values().count(Faction.FRANKS) == city_owner.size() - 1

static func enemy_city() -> String:
	return "City 7" if is_final_battle() else selected_city

static func battle_slot_count() -> int:
	return CITY_SLOTS.get(enemy_city(), 3)

static func loyal_group() -> String:
	return "Peasants" if public_loyalty["Peasants"] >= public_loyalty["Nobility"] else "Nobility"

static func disloyal_group() -> String:
	return "Nobility" if loyal_group() == "Peasants" else "Peasants"

static func faction_color(faction: Faction) -> Color:
	match faction:
		Faction.REBELS:
			return Color("#f5eee2")
	return Color("#0099db")

static func reset() -> void:
	selected_city = ""
	player_deck.assign(STARTING_DECK)
	public_loyalty = {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
	internal_loyalty = {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
	city_owner = STARTING_OWNERS.duplicate()
