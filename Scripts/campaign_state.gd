class_name CampaignState extends RefCounted

enum Faction {
	FRANKS,
	REBELS,
	ENGLISH,
	HRE
}

enum Arc {
	FRANCE,
	FOREIGN_RELATIONS
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
const ACT_2_STARTING_DECK: Array[String] = ["Archer", "Crossbowman", "Mantlet", "Stakes", "Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"]
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
const FOREIGN_CITIES := {
	"London": Faction.ENGLISH, "York": Faction.ENGLISH, "Edinburgh": Faction.ENGLISH,
	"Dublin": Faction.ENGLISH, "Winchester": Faction.ENGLISH, "Norwich": Faction.ENGLISH,
	"Aachen": Faction.HRE, "Cologne": Faction.HRE, "Frankfurt": Faction.HRE,
	"Munich": Faction.HRE, "Berlin": Faction.HRE, "Vienna": Faction.HRE
}
const DECLARATION_CITIES := {"London": Faction.ENGLISH, "Aachen": Faction.HRE}

static var selected_city := ""
static var start_in_act_2 := false
static var player_deck: Array[String] = STARTING_DECK.duplicate()
static var loyalty := {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
static var city_owner := STARTING_OWNERS.duplicate()
static var arc := Arc.FRANCE
static var foreign_loyalty := {Faction.ENGLISH: Relation.NEUTRAL, Faction.HRE: Relation.NEUTRAL}
static var war_faction := Faction.REBELS

static func change_loyalty(group: String, amount: int) -> void:
	loyalty[group] = clampi(loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func loyalty_after(group: String, amount: int) -> int:
	return clampi(loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func capture_selected_city() -> void:
	if !city_owner.has(selected_city):
		return
	var was_final := is_final_battle()
	city_owner[selected_city] = Faction.FRANKS
	if was_final:
		arc = Arc.FOREIGN_RELATIONS
		return
	if city_owner.values().all(func(owner: int) -> bool: return owner == Faction.FRANKS) && !was_final:
		city_owner["City 1"] = Faction.REBELS

static func is_final_battle() -> bool:
	return city_owner["City 1"] == Faction.REBELS && city_owner.values().count(Faction.FRANKS) == city_owner.size() - 1

static func enemy_city() -> String:
	return "City 7" if is_final_battle() else selected_city

static func battlefield_faction() -> Faction:
	return FOREIGN_CITIES.get(enemy_city(), Faction.REBELS)

static func battle_slot_count() -> int:
	return CITY_SLOTS.get(enemy_city(), 3)

static func crossbowman_unlocked(city_name := selected_city) -> bool:
	return city_number(city_name) >= 4

static func city_number(city_name: String) -> int:
	return int(city_name.trim_prefix("City "))

static func loyal_group() -> String:
	return "Peasants" if loyalty["Peasants"] >= loyalty["Nobility"] else "Nobility"

static func disloyal_group() -> String:
	return "Nobility" if loyal_group() == "Peasants" else "Peasants"

static func is_foreign_city(city_name: String) -> bool:
	return FOREIGN_CITIES.has(city_name)

static func foreign_relations_active() -> bool:
	return arc == Arc.FOREIGN_RELATIONS

static func declare_war(faction: Faction) -> void:
	if !foreign_relations_active() || !foreign_loyalty.has(faction):
		return
	war_faction = faction
	foreign_loyalty[faction] = Relation.WAR
	foreign_loyalty[other_foreign_faction(faction)] = Relation.MILITARY_ALLIANCE

static func other_foreign_faction(faction: Faction) -> Faction:
	return Faction.HRE if faction == Faction.ENGLISH else Faction.ENGLISH

static func faction_name(faction: Faction) -> String:
	return "English" if faction == Faction.ENGLISH else "Holy Roman Empire" if faction == Faction.HRE else "Franks" if faction == Faction.FRANKS else "Rebels"

static func faction_color(faction: Faction) -> Color:
	match faction:
		Faction.REBELS:
			return Color("#f5eee2")
		Faction.ENGLISH:
			return Color("#e43b44")
		Faction.HRE:
			return Color("#feae34")
	return Color("#0099db")

static func start_act_2() -> void:
	arc = Arc.FOREIGN_RELATIONS
	player_deck.assign(ACT_2_STARTING_DECK)
	foreign_loyalty = {Faction.ENGLISH: Relation.NEUTRAL, Faction.HRE: Relation.NEUTRAL}
	war_faction = Faction.REBELS
	for city in city_owner:
		city_owner[city] = Faction.FRANKS

static func reset() -> void:
	selected_city = ""
	player_deck.assign(STARTING_DECK)
	loyalty = {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
	city_owner = STARTING_OWNERS.duplicate()
	arc = Arc.FRANCE
	foreign_loyalty = {Faction.ENGLISH: Relation.NEUTRAL, Faction.HRE: Relation.NEUTRAL}
	war_faction = Faction.REBELS
	if start_in_act_2:
		start_act_2()
