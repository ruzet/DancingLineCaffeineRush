extends Camera3D

@onready var Head: CharacterBody3D = $"../LineController/Head"

var Position = Vector3(0.5, 0.5, 0.5)
var Distance = 30
var Following = true

func _process(Delta: float) -> void:
	if Following:
		var Direction = global_position.direction_to(Head.global_position)
		var Target = Basis.looking_at(Direction)
		
		basis = basis.slerp(Target, 0.35)
		global_position = global_position.lerp(Head.global_position + (Position * Distance), Delta)
	else:
		pass
