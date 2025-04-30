extends Node2D

@onready var slider         = $CanvasLayer/AngleSlider
@onready var spaceship      = $Spaceship
@onready var fuel_bar       = $CanvasLayer/FuelBar
@onready var launch_button  = $CanvasLayer/Button

func _ready() -> void:
	launch_button.pressed.connect(_on_LaunchButton_pressed)

func _on_LaunchButton_pressed() -> void:
	if not spaceship.is_launched:
		spaceship.launch(slider.value)

func _process(_delta: float) -> void:
	if not spaceship.is_launched:
		if Input.is_action_just_pressed("ui_accept"):
			spaceship.launch(slider.value)
			slider.hide()
			launch_button.hide()
	else:
		fuel_bar.value = spaceship.current_fuel
