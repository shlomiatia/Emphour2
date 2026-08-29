extends SceneTree

func _initialize() -> void:
    run_test()

func run_test() -> void:
    var hud := load("res://Entities/BattleHud/BattleHud.tscn").instantiate() as BattleHud
    root.add_child(hud)
    await process_frame
    hud.set_balance(0, false)
    await verify_return(hud, 2)
    await verify_return(hud, -2)
    quit()

func verify_return(hud: BattleHud, value: int) -> void:
    hud.set_preview(value)
    await hud.preview_tween.finished
    var width := hud.preview.size.x
    var color := hud.preview.color
    hud.set_preview(0)
    assert(hud.preview.visible)
    assert(hud.preview.color == color)
    assert(width > 0.0 && hud.preview_tween.is_running())
    await create_timer(0.1).timeout
    assert(hud.preview.size.x > 0.0 && hud.preview.size.x < width)
    await hud.preview_tween.finished
    assert(!hud.preview.visible)
    assert(is_zero_approx(hud.preview.size.x))
