class_name RelationData extends RefCounted

const LOYALTY_NAMES := [
	"Treacherous", "Disloyal", "Defiant", "Discontent", "Uneasy", "Neutral",
	"At Ease", "Content", "Obedient", "Loyal", "Devoted"
]
const COLORS := [
	Color("#a92335"), Color("#c83b3b"), Color("#dc5838"), Color("#e68135"), Color("#e7b84b"),
	Color("#ddd3bd"), Color("#a4cc73"), Color("#76c66a"), Color("#4ebd68"), Color("#2eaa60"), Color("#168f50")
]

static func loyalty_name(value: int) -> String:
	return LOYALTY_NAMES[value + 5]

static func color(value: int) -> Color:
	return COLORS[value + 5]
