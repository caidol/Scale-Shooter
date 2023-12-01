extends CanvasLayer

@onready var health_bar = $ProgressBars/HealthBar
@onready var energy_bar = $ProgressBars/EnergyBar

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.value = 100
	energy_bar.value = 100

func _process(delta):
	# Couldn't get signal working so am using the below to update the energy bar
	if (Input.is_action_just_released("Left Click")):
		energy_bar.value -= 10
