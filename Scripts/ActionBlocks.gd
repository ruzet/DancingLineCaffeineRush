extends Node3D

@onready var Camera: Camera3D = $"../Camera"

func _ready() -> void:
	var ActionBlocks = get_tree().get_nodes_in_group("ActionBlock")

	for Block in ActionBlocks:
		if Block is Area3D:
			Block.body_entered.connect(_OnBlockTouched.bind(Block))

func _OnBlockTouched(Head: CharacterBody3D, Block: ActionBlock):
	if Head.is_in_group("LineHead"):
		print("Activated Block Type " + str(Block.BlockType))
		if Block.BlockType == 0: # Camera Tween
			print(Block.Position, Block.Distance, Block.CameraDuration)
			Camera.TweenCamera(Block.Position, Block.Distance, Block.CameraDuration)
		elif Block.BlockType == 1: # Jump Pad
			Head.velocity.y = Block.JumpPower


func _LineColorChange(Head: CharacterBody3D, NewColor: Color, Duration: float):
	var LineController = Head.get_parent()
	var LineMaterial = LineController.LineMaterial
	var NewTween = create_tween()
	NewTween.set_trans(Tween.TRANS_QUAD)
	NewTween.set_ease(Tween.EASE_OUT)

	NewTween.tween_property(LineMaterial, "albedo_color", NewColor, Duration)
	NewTween.play()
