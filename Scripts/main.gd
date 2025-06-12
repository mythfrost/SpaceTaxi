# Main.gd
extends Node2D

@onready var spaceship           = $Spaceship
@onready var fuel_bar            = $CanvasLayer/FuelBar
@onready var secondary_fuel_bar  = $CanvasLayer/SecondaryFuelBar
@onready var launch_button       = $CanvasLayer/Button

func _ready() -> void:
	# start FSM
	_GameStateManager.change_state(_GameStateManager.PlayingState.new(self))
	# wire up launch button
	launch_button.pressed.connect(_on_LaunchButton_pressed)
	secondary_fuel_bar.max_value = spaceship.max_turn_fuel

func _on_LaunchButton_pressed() -> void:
	spaceship.launch()
	launch_button.hide()

func _input(event) -> void:
	_GameStateManager._input(event)

func _process(delta: float) -> void:
	if spaceship.is_launched:
		fuel_bar.value           = spaceship.current_fuel
		secondary_fuel_bar.value = spaceship.turn_fuel
	_GameStateManager._process(delta)
