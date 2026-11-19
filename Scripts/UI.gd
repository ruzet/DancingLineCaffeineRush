extends Control

@onready var StatsContainer = $MarginContainer/StatsContainer
@export var Ready = false

func HideUI():
	for Child in self.find_children("*", ""):
		if Child is Label:
			print(Child.name)
			create_tween().tween_property(Child, "modulate:a", 0, 1)
