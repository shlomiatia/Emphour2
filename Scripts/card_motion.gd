class_name CardMotion extends RefCounted

static func flip_face_up(card: Card) -> Signal:
    card.moving = true
    var target_scale := card.scale
    var tween := create(card)
    tween.tween_property(card, "scale:x", 0.05, 0.14)
    tween.tween_callback(card.set_hidden.bind(false))
    tween.tween_property(card, "scale:x", target_scale.x, 0.14)
    tween.tween_callback(card.finish_move)
    return tween.finished

static func fade_out(card: Card) -> void:
    var tween := create(card, Tween.EASE_OUT)
    tween.tween_property(card, "modulate", Color(1, 1, 1, 0), 0.3)
    await tween.finished

static func move_to(card: Card, target: Vector2, fade: bool, target_scale: Vector2) -> void:
    var tween := transform(card, target, target_scale, card.rotation)
    if fade:
        tween.parallel().tween_property(card, "modulate:a", 0.0, 0.45)
    await tween.finished

static func move_to_line(card: Card, target: Vector2) -> void:
    card.moving = true
    var tween := transform(card, target, Vector2.ONE, 0.0)
    tween.tween_callback(card.finish_move)

static func retreat_out(card: Card, side: int) -> void:
    var target_y := 1280.0 if side == GameRules.Side.PLAYER else -200.0
    create(card, Tween.EASE_OUT).tween_property(card, "global_position:y", target_y, 0.3)

static func attack(card: Card, defender: Card) -> Signal:
    card.attacking = true
    card.z_index = 100
    var start := card.global_position
    var tween := card.create_tween()
    tween.tween_property(card, "global_position", defender.global_position, 0.18)
    tween.tween_property(card, "global_position", start, 0.18)
    tween.tween_callback(card.finish_attack)
    return tween.finished

static func transform(card: Card, target_position: Vector2, target_scale: Vector2, target_rotation: float, ease := Tween.EASE_IN_OUT) -> Tween:
    var tween := create(card, ease)
    tween.tween_property(card, "global_position", target_position, 0.45)
    tween.parallel().tween_property(card, "scale", target_scale, 0.45)
    tween.parallel().tween_property(card, "rotation", target_rotation, 0.45)
    return tween

static func approach(card: Card, target_position: Vector2, target_scale: Vector2, target_rotation: float, delta: float) -> void:
    var weight := minf(delta * 10.0, 1.0)
    card.position = card.position.lerp(target_position, weight)
    card.scale = card.scale.lerp(target_scale, weight)
    card.rotation = lerp_angle(card.rotation, target_rotation, weight)

static func create(node: Node, ease := Tween.EASE_IN_OUT) -> Tween:
    return node.create_tween().set_trans(Tween.TRANS_SINE).set_ease(ease)
