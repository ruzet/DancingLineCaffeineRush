extends Node3D

@onready var Camera: Camera3D = $"../Camera"

func _ready() -> void:
	var ActionBlocks = get_tree().get_nodes_in_group("ActionBlock")

	for Block in ActionBlocks:
		if Block is Area3D:
			Block.body_entered.connect(_OnBlockTouched.bind(Block))

func _OnBlockTouched(Head: Node, Block: ActionBlock):
	if Head.is_in_group("LineHead"):
		print("Activated Block Type " + str(Block.BlockType))
		if Block.BlockType == 0: # Camera Tween
			Camera.TweenCamera(Block.Position, Block.Distance, Block.CameraDuration)
		elif Block.BlockType == 1: # Jump Pad
			Head.velocity.y = Block.JumpPower
		elif Block.BlockType == 4: # Open Pyramid:
			_OpenPyramid()
		elif Block.BlockType == 5: # End Game:
			_EndGame(Head)



func _LineColorChange(Head: CharacterBody3D, NewColor: Color, Duration: float):
	var LineController = Head.get_parent()
	var LineMaterial = LineController.LineMaterial
	var NewTween = create_tween()
	NewTween.set_trans(Tween.TRANS_QUAD)
	NewTween.set_ease(Tween.EASE_OUT)

	NewTween.tween_property(LineMaterial, "albedo_color", NewColor, Duration)
	NewTween.play()

func _OpenPyramid():
	var Pyramid1 = $"../Pyramid1"
	var Pyramid2 = $"../Pyramid2"
	var NewTween = create_tween()
	NewTween.set_trans(Tween.TRANS_QUAD)
	NewTween.set_ease(Tween.EASE_OUT)
	NewTween.set_parallel(true)

	NewTween.tween_property(Pyramid1, "position", Vector3(-1567.7, -2.0, -1743.0), 3)
	NewTween.tween_property(Pyramid2, "position", Vector3(-1573.7, -2.0, -1743.0), 3)
	NewTween.play()

	Camera.Following = false

func _EndGame(Head: CharacterBody3D):
	var LineController = Head.get_parent()
	LineController.CanTurn = false
