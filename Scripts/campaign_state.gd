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

const STARTING_DECK: Array[String] = ["Archer", "Mantlet", "Stakes", "Militia", "Militia", "Militia"]
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
	city_owner[selected_city] = Faction.FRANKS

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
