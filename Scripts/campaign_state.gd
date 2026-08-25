class_name CampaignState extends RefCounted

enum Faction {
	FRANKS,
	ENGLAND,
	HOLY_ROMAN_EMPIRE,
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
	"Paris": Faction.FRANKS,
	"Rouen": Faction.REBELS,
	"Amiens": Faction.REBELS,
	"Abbeville": Faction.REBELS,
	"Boulogne": Faction.REBELS,
	"Calais": Faction.REBELS,
	"Reims": Faction.REBELS,
	"Verdun": Faction.REBELS,
	"Metz": Faction.REBELS,
	"Strasbourg": Faction.REBELS,
	"Colmar": Faction.REBELS,
	"Besancon": Faction.REBELS
}

static var selected_city := ""
static var player_deck: Array[String] = STARTING_DECK.duplicate()
static var relations := {
	Faction.ENGLAND: Relation.NEUTRAL,
	Faction.HOLY_ROMAN_EMPIRE: Relation.NEUTRAL
}
static var loyalty := {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
static var city_owner := STARTING_OWNERS.duplicate()

static func change_loyalty(group: String, amount: int) -> void:
	loyalty[group] = clampi(loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func loyalty_after(group: String, amount: int) -> int:
	return clampi(loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func capture_selected_city() -> void:
	if city_owner.has(selected_city):
		city_owner[selected_city] = Faction.FRANKS

static func faction_color(faction: Faction) -> Color:
	match faction:
		Faction.ENGLAND:
			return Color("#e43b44")
		Faction.HOLY_ROMAN_EMPIRE:
			return Color("#fee761")
		Faction.REBELS:
			return Color("#f5eee2")
	return Color("#0099db")

static func reset() -> void:
	selected_city = ""
	player_deck.assign(STARTING_DECK)
	relations = {Faction.ENGLAND: Relation.NEUTRAL, Faction.HOLY_ROMAN_EMPIRE: Relation.NEUTRAL}
	loyalty = {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
	city_owner = STARTING_OWNERS.duplicate()
