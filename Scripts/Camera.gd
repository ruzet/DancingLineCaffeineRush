extends Camera3D

@onready var Head: CharacterBody3D = $"../LineController/Head"

var Position = Vector3(0.5, 0.75, 0.5)
var Distance = 20.0
var Following = true

func _process(Delta: float) -> void:
	if Following:
		var Direction = global_position.direction_to(Head.global_position)
		var Target = Basis.looking_at(Direction)
		
		basis = basis.slerp(Target, 0.025)
		global_position = global_position.lerp(Head.global_position + (Position * Distance), 5 * Delta)

func TweenCamera(NewPosition: Vector3, NewDistance: float, Duration: float):
	var NewTween = create_tween()
	NewTween.set_trans(Tween.TRANS_QUAD)
	NewTween.set_ease(Tween.EASE_OUT)
	NewTween.set_parallel(true)
	if NewPosition: NewTween.tween_property(self, "Position", NewPosition, Duration)
	if NewDistance: NewTween.tween_property(self, "Distance", NewDistance, Duration)
	NewTween.play()
