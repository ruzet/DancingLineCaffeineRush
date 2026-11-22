extends Control

@onready var SpeedContainer: VBoxContainer = $"MarginContainer/Panel/VBoxContainer/ButtonContainer/SpeedContainer"
@onready var LineController: Node3D = $"../../LineController"

func _ready() -> void:
	SpeedContainer.find_child("UltraSlow").pressed.connect(_SetSpeed.bind(0.5))
	SpeedContainer.find_child("Slow").pressed.connect(_SetSpeed.bind(0.75))
	SpeedContainer.find_child("Normal").pressed.connect(_SetSpeed.bind(1))
	SpeedContainer.find_child("Fast").pressed.connect(_SetSpeed.bind(1.25))
	SpeedContainer.find_child("Reset").pressed.connect(LineController.Reset)

func _SetSpeed(Speed: float = 1):
	LineController.Speed = Speed
	SpeedContainer.find_child("Speed").text = "Speed: " + str(Speed) + "x"