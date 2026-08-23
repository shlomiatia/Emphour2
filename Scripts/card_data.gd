class_name CardData extends RefCounted

enum AttackType {
    NONE,
    MISSILE,
    CAVALRY
}

enum DefenceType {
    NONE,
    ARMOR,
    RETREAT
}

var name: String
var strength: int
var attack: int
var attack_type: AttackType
var defence: int
var defence_type: DefenceType
var anti_attack: AttackType
var anti_defences: Array[DefenceType]
