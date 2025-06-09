extends Node2D

@onready var spaceship      = $Spaceship
@onready var fuel_bar       = $CanvasLayer/FuelBar
@onready var secondary_fuel_bar       = $CanvasLayer/SecondaryFuelBar
@onready var launch_button  = $CanvasLayer/Button

@onready var cam: Camera2D = $Spaceship/Camera2D
@onready var arrow = $CanvasLayer/Arrow
var arrow_target: Node2D = null

func _ready() -> void:
	launch_button.pressed.connect(_on_LaunchButton_pressed)
	# Initialize the secondary fuel bar’s maximum based on the ship’s turn fuel
	secondary_fuel_bar.max_value = spaceship.max_turn_fuel
	arrow.visible = false

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
		
	if arrow_target:
		# world‐space direction from ship to target planet
		var dir = arrow_target.global_position - $Spaceship.global_position
		# rotation such that arrow’s “up” (its local +Y) points along dir
		arrow.rotation = dir.angle() 
		arrow.visible  = true
	else:
		arrow.visible = false

func set_arrow_target(planet: Node2D) -> void:
	arrow_target = planet
	arrow.visible = true
	
func clear_arrow_target() -> void:
	arrow_target = null
	arrow.visible = false

func show_launch_button() -> void:
	launch_button.show()
