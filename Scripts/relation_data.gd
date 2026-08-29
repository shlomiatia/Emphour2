class_name RelationData extends RefCounted

const LOYALTY_NAMES := [
	"relation.treacherous", "relation.disloyal", "relation.defiant", "relation.discontent", "relation.uneasy", "relation.neutral",
	"relation.at_ease", "relation.content", "relation.obedient", "relation.loyal", "relation.devoted"
]
static func loyalty_name(value: int) -> String:
	return TranslationServer.translate(LOYALTY_NAMES[value + 5])

static func loyalty_label(value: int) -> String:
	return "%s (%d)" % [loyalty_name(value), value]

static func color(value: int) -> Color:
	return Color("#731927") if value < 0 else Color("#1f6339") if value > 0 else Color("#765400")

static func change_color(value: int) -> Color:
	return Color("#1f6339") if value > 0 else Color("#731927")
