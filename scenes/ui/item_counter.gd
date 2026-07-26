extends CanvasLayer


@export var label: Label


func _ready() -> void:
	set_counter_label()


func set_counter_label():
	label.text = "x" + str(GameData.branches_collected)
