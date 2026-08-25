class_name CampaignState extends RefCounted

enum Faction {
	FRANKS,
	ENGLAND,
	HOLY_ROMAN_EMPIRE,
	REBELS
}

enum Relation {
	TRADE_EMBARGO,
	NEUTRAL,
	TRADE_PACT
}

static var selected_city := ""
static var relations := {
	Faction.ENGLAND: Relation.NEUTRAL,
	Faction.HOLY_ROMAN_EMPIRE: Relation.NEUTRAL
}
static var loyalty := {
	"Peasants": Relation.NEUTRAL,
	"Nobility": Relation.NEUTRAL
}
static var city_owner := {
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

static func relation_name(relation: Relation) -> String:
	match relation:
		Relation.TRADE_EMBARGO:
			return "Trade Embargo"
		Relation.TRADE_PACT:
			return "Trade Pact"
	return "Neutral"

static func faction_color(faction: Faction) -> Color:
	match faction:
		Faction.ENGLAND:
			return Color("#e43b44")
		Faction.HOLY_ROMAN_EMPIRE:
			return Color("#fee761")
		Faction.REBELS:
			return Color("#f5eee2")
	return Color("#0099db")

static func relation_color(relation: Relation, dark_neutral := false) -> Color:
	match relation:
		Relation.TRADE_EMBARGO:
			return Color("#e7b84b")
		Relation.TRADE_PACT:
			return Color("#62c878")
	return Color("#51483b") if dark_neutral else Color("#ddd3bd")
