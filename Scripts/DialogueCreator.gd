extends Node
class_name DialogBuilder

# preload your dialog scene so it's never null
@export var DialogScene: PackedScene = preload("res://Scenes/Dialog.tscn")

var _dialog: AcceptDialog

func _init() -> void:
	# now DialogScene is always valid
	_dialog = DialogScene.instantiate() as AcceptDialog

func set_title(title: String) -> DialogBuilder:
	_dialog.window_title = title
	return self

func set_text(body: String) -> DialogBuilder:
	_dialog.get_node("VBoxContainer/BodyLabel").text = body
	return self

func add_button(text: String, callback: Callable = Callable()) -> DialogBuilder:
	var btn = Button.new()
	btn.text = text
	if callback:
		btn.pressed.connect(callback)
	_dialog.get_ok().get_parent().add_child(btn)
	return self

func show() -> void:
	get_tree().current_scene.add_child(_dialog)
	_dialog.popup_centered()
