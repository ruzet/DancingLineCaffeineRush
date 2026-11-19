extends Camera3D

@onready var Head: Area3D = $"../LineController/Head"

var Position = Vector3(1, 1, 1)
var Distance = 10
var Following = true

func _process(Delta: float) -> void:
	if Following:
		print((global_position - Head.global_position))
		global_rotation_degrees = (global_position - Head.global_position).normalized().abs()
		global_position = global_position.lerp(Head.global_position + (position * Distance), 5 * Delta)
	else:
		pass
