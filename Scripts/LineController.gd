extends Node3D

@export var LineSpeed = 50
@export var LineMaterial: StandardMaterial3D

@onready var Head = $Head
@onready var TrailContainer = $TrailContainer

var MainDirection = Vector3.FORWARD
var CurrentDirection = Vector3.FORWARD
var CurrentSegment: MeshInstance3D
var TurnStartPosition: Vector3
var LeftTurn = false
var Turned = false

func _physics_process(Delta: float) -> void:
	Head.global_position += CurrentDirection * LineSpeed * Delta
	_UpdateCurrentSegment()

func _SpawnNewSegment():
	var Box = BoxMesh.new()
	CurrentSegment = MeshInstance3D.new()
	CurrentSegment.mesh = Box
	
	if LineMaterial: CurrentSegment.material_override = LineMaterial
	TrailContainer.add_child(CurrentSegment)
	CurrentSegment.global_position = TurnStartPosition

func _UpdateCurrentSegment():
	if not CurrentSegment: return
	
	var CurrentPosition = Head.global_position
	#var Distance = TurnStartPosition.distance_to(CurrentPosition) soon
	
	CurrentSegment.global_position = (TurnStartPosition + CurrentPosition) / 2
