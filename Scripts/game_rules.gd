class_name GameRules extends RefCounted

enum Side {
    PLAYER,
    ENEMY
}

static func other(side: int) -> int:
    return Side.ENEMY if side == Side.PLAYER else Side.PLAYER
