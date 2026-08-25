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
	"Paris": Faction.REBELS,
	"Rouen": Faction.REBELS,
	"Amiens": Faction.REBELS,
	"Abbeville": Faction.REBELS,
	"Boulogne": Faction.REBELS,
	"Calais": Faction.REBELS
}

static var selected_city := ""
static var player_deck: Array[String] = STARTING_DECK.duplicate()
static var loyalty := {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
static var city_owner := STARTING_OWNERS.duplicate()

static func change_loyalty(group: String, amount: int) -> void:
	loyalty[group] = clampi(loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func loyalty_after(group: String, amount: int) -> int:
	return clampi(loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func capture_selected_city() -> void:
	if !city_owner.has(selected_city):
		return
	var was_final := is_final_battle()
	city_owner[selected_city] = Faction.FRANKS
	if city_owner.values().all(func(owner: int) -> bool: return owner == Faction.FRANKS) && !was_final:
		city_owner["Paris"] = Faction.REBELS

static func is_final_battle() -> bool:
	return city_owner["Paris"] == Faction.REBELS && city_owner.values().count(Faction.FRANKS) == city_owner.size() - 1

static func enemy_city() -> String:
	return "City 7" if is_final_battle() else selected_city

static func loyal_group() -> String:
	return "Peasants" if loyalty["Peasants"] >= loyalty["Nobility"] else "Nobility"

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
	loyalty = {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
	city_owner = STARTING_OWNERS.duplicate()
