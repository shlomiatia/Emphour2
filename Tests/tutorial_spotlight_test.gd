extends SceneTree

func _initialize() -> void:
    var spotlight := TutorialSpotlight.new()
    spotlight.set_rects([Rect2(10, 20, 30, 40), Rect2(50, 60, 70, 80), Rect2(90, 100, 110, 120)])
    assert(spotlight.rects.size() == 3)
    assert(spotlight.rects.map(func(rect: Rect2) -> Vector2: return rect.size) == [Vector2(46, 56), Vector2(86, 96), Vector2(126, 136)])
    spotlight.clear()
    assert(spotlight.rects.is_empty())
    spotlight.free()
    quit()
