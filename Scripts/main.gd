extends Node2D

@onready var spaceship      = $Spaceship
@onready var fuel_bar       = $CanvasLayer/FuelBar
@onready var secondary_fuel_bar       = $CanvasLayer/SecondaryFuelBar
@onready var launch_button  = $CanvasLayer/Button

func _ready() -> void:
	launch_button.pressed.connect(_on_LaunchButton_pressed)
	# Initialize the secondary fuel bar’s maximum based on the ship’s turn fuel
	secondary_fuel_bar.max_value = spaceship.max_turn_fuel

func _on_LaunchButton_pressed() -> void:
	# Only launch once: trigger ship launch and hide the button
	if not spaceship.is_launched:
		spaceship.launch()
		launch_button.hide()

func _process(_delta: float) -> void:
	# Allow Space key to act as the launch trigger as well
	if Input.is_action_just_pressed("ui_accept") and not spaceship.is_launched:
		_on_LaunchButton_pressed()
	# While the ship is in flight, update both fuel bars each frame
	if spaceship.is_launched:
		fuel_bar.value = spaceship.current_fuel
		secondary_fuel_bar.value = spaceship.turn_fuel
