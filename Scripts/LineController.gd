extends Node3D

@export var LineSpeed = 7
@export var Gravity = 10
@export var LineMaterial: StandardMaterial3D

@onready var Head = $Head
@onready var TrailContainer = $TrailContainer

var MainDirection = Vector3.FORWARD
var CurrentDirection = Vector3.FORWARD
var CurrentSegment: MeshInstance3D
var TurnStartPosition: Vector3
var LeftTurn = true
var Turned = false
var CanTurn = true
var Moving = true
var Grounded = false

func _physics_process(Delta: float) -> void:
	Head.find_child("Mesh").material_override = LineMaterial
	if !Moving: return
	Head.global_position += CurrentDirection * LineSpeed * Delta
	if Head.is_on_floor():
		Head.velocity.y = 0
		if not CurrentSegment:
			_SpawnNewSegment()
		else:
			_UpdateCurrentSegment()
	else:
		Head.velocity.y -= Gravity * Delta
	Head.move_and_slide()
	
func _input(Event: InputEvent) -> void: if Event.is_action_pressed("Turn"): Turn()

func _ready() -> void:
	if Head.is_on_floor(): _SpawnNewSegment()
	Moving = true

func Turn():
	if !CanTurn || !Moving || !Head.is_on_floor(): return
	_UpdateCurrentSegment()
	TurnStartPosition = Head.global_position
	if !Turned:
		CurrentDirection = CurrentDirection.rotated(Vector3.UP, deg_to_rad(90 if LeftTurn else -90))
	else:
		CurrentDirection = CurrentDirection.rotated(Vector3.UP, deg_to_rad(-90 if LeftTurn else 90))
	Turned = !Turned
	_SpawnNewSegment()

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
	var Distance = TurnStartPosition.distance_to(CurrentPosition)
	
	if CurrentSegment.global_position != CurrentPosition: CurrentSegment.look_at(CurrentPosition)
	CurrentSegment.scale = Vector3(1, 1, (Distance + 1))
	CurrentSegment.global_position = (TurnStartPosition + CurrentPosition) / 2
