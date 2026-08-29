class_name TutorialSpotlight extends Control

const COLOR := Color(0, 0, 0, 0.72)
const BORDER := Color("#fee761")

var rects: Array[Rect2]

func set_rects(value: Array) -> void:
    rects = []
    for rect: Rect2 in value:
        if rect.size != Vector2.ZERO:
            rects.append(rect.grow(8.0))
    queue_redraw()

func set_rect(value: Rect2) -> void:
    set_rects([] if value.size == Vector2.ZERO else [value])

func clear() -> void:
    rects = []
    queue_redraw()

func edges(size: Vector2, horizontal: bool) -> Array[float]:
    var result: Array[float] = [0.0, size.x if horizontal else size.y]
    for rect in rects:
        result.append(clampf(rect.position.x if horizontal else rect.position.y, 0.0, size.x if horizontal else size.y))
        result.append(clampf(rect.end.x if horizontal else rect.end.y, 0.0, size.x if horizontal else size.y))
    result.sort()
    return result

func is_highlighted(point: Vector2) -> bool:
    return rects.any(func(rect: Rect2) -> bool: return rect.has_point(point))

func draw_dimmed_cells(size: Vector2) -> void:
    var xs := edges(size, true)
    var ys := edges(size, false)
    for x in xs.size() - 1:
        for y in ys.size() - 1:
            var cell := Rect2(Vector2(xs[x], ys[y]), Vector2(xs[x + 1] - xs[x], ys[y + 1] - ys[y]))
            if !is_highlighted(cell.get_center()):
                draw_rect(cell, COLOR)

func _draw() -> void:
    if rects.is_empty():
        return
    draw_dimmed_cells(get_viewport_rect().size)
    for rect in rects:
        draw_rect(rect, BORDER, false, 3.0)
