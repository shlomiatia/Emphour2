class_name PanelTitle extends PanelContainer

@export var title := "TITLE":
    set(value):
        title = value
        if is_node_ready():
            $MarginContainer/Title.text = title

func _ready() -> void:
    $MarginContainer/Title.text = title
