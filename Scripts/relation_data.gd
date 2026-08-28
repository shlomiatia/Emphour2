class_name RelationData extends RefCounted

const LOYALTY_NAMES := [
	"relation.treacherous", "relation.disloyal", "relation.defiant", "relation.discontent", "relation.uneasy", "relation.neutral",
	"relation.at_ease", "relation.content", "relation.obedient", "relation.loyal", "relation.devoted"
]
const COLORS := [
	Color("#a92335"), Color("#c83b3b"), Color("#dc5838"), Color("#e68135"), Color("#e7b84b"),
	Color("#ddd3bd"), Color("#a4cc73"), Color("#76c66a"), Color("#4ebd68"), Color("#2eaa60"), Color("#168f50")
]

static func loyalty_name(value: int) -> String:
	return TranslationServer.translate(LOYALTY_NAMES[value + 5])

static func color(value: int) -> Color:
	return COLORS[value + 5]
