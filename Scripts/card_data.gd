class_name CardData extends RefCounted

enum AttackType {
    NONE,
    MISSILE,
    CAVALRY,
    ARMOR_PIERCING
}

var name: String
var strength: int
var attack: int
var attack_type: AttackType
var defence: int
var anti_attack: AttackType
var armored: bool
