class_name TutorialSpotlight extends Control

const COLOR := Color(0, 0, 0, 0.72)
const BORDER := Color("#fee761")

var rect := Rect2()

func set_rect(value: Rect2) -> void:
    if value.size == Vector2.ZERO:
        clear()
        return
    rect = value.grow(8.0)
    queue_redraw()

func clear() -> void:
    rect = Rect2()
    queue_redraw()

func _draw() -> void:
    if rect.size == Vector2.ZERO:
        return
    var size := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, rect.position.y)), COLOR)
    draw_rect(Rect2(Vector2(0, rect.end.y), Vector2(size.x, size.y - rect.end.y)), COLOR)
    draw_rect(Rect2(Vector2(0, rect.position.y), Vector2(rect.position.x, rect.size.y)), COLOR)
    draw_rect(Rect2(Vector2(rect.end.x, rect.position.y), Vector2(size.x - rect.end.x, rect.size.y)), COLOR)
    draw_rect(rect, BORDER, false, 3.0)
