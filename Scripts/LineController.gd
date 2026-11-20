extends Node3D

@export var LineSpeed = 7
@export var Gravity = 10
@export var RecordPath = true
@export var LineMaterial: StandardMaterial3D

@onready var Head: CharacterBody3D = $"Head"
@onready var TrailContainer: Node = $"TrailContainer"
@onready var AudioPlayer: AudioStreamPlayer = $"../AudioStreamPlayer"
@onready var UI: Control = $"../UI/Root"

var MainDirection = Vector3.FORWARD
var CurrentDirection = Vector3.FORWARD
var TurnStartPosition: Vector3
var CurrentSegment: MeshInstance3D
var RecordedCurve: Curve3D
var LeftTurn = true
var Turned = false
var CanTurn = true
var Moving = false
var Grounded = false

func _physics_process(Delta: float) -> void:
	Head.find_child("Mesh").material_override = LineMaterial
	if !Moving: return
	Head.global_position += CurrentDirection * LineSpeed * Delta
	
	if !Grounded && Head.is_on_floor(): Landed()
	Grounded = Head.is_on_floor()
	
	if Head.is_on_floor():
		Head.velocity.y = 0
		if !CurrentSegment:
			_SpawnNewSegment()
		else:
			_UpdateCurrentSegment()
	else:
		Head.velocity.y -= Gravity * Delta
	Head.move_and_slide()
	
func _input(Event: InputEvent) -> void: 
	if Event.is_action_pressed("Turn"):
		if UI.Ready:
			if !Moving: Ready() 
			else: Turn()
		else:
			UI.Ready = true
			UI.HideUI()
	elif Event.is_action_pressed("ui_text_newline") && RecordPath:
		_SaveRecordedPath()
			
func _ready() -> void: AudioPlayer.stream = preload("res://Assets/caffeinerush.wav")

func Ready():
	AudioPlayer.play()
	if Head.is_on_floor(): _SpawnNewSegment()
	AudioPlayer.play()
	if RecordPath:
		RecordedCurve = Curve3D.new()
		RecordedCurve.add_point(Head.global_position)
	Moving = true
	
func Landed(): 
	TurnStartPosition = Head.global_position
	_SpawnNewSegment()

func Turn():
	if !CanTurn || !Moving || !Head.is_on_floor(): return
	_UpdateCurrentSegment()
	TurnStartPosition = Head.global_position
	if !Turned:
		CurrentDirection = CurrentDirection.rotated(Vector3.UP, deg_to_rad(90 if LeftTurn else -90))
	else:
		CurrentDirection = CurrentDirection.rotated(Vector3.UP, deg_to_rad(-90 if LeftTurn else 90))
	Turned = !Turned
	if RecordPath && RecordedCurve: RecordedCurve.add_point(TurnStartPosition)
	_SpawnNewSegment()

func _SpawnNewSegment():
	var Box = BoxMesh.new()
	CurrentSegment = MeshInstance3D.new()
	CurrentSegment.mesh = Box
	
	if LineMaterial: CurrentSegment.material_override = LineMaterial
	TrailContainer.add_child(CurrentSegment)
	CurrentSegment.global_position = TurnStartPosition
	
func _SaveRecordedPath():
	if !RecordedCurve: return
	RecordedCurve.add_point(Head.global_position)
	var SaveError = ResourceSaver.save(RecordedCurve, "res://Assets/RecordedCurve.tres")
	if SaveError == OK:
		print("saved correctly")
	else:
		print("error: " + SaveError)

func _UpdateCurrentSegment():
	if not CurrentSegment: return
	
	var CurrentPosition = Head.global_position
	var Distance = TurnStartPosition.distance_to(CurrentPosition)
	
	if CurrentSegment.global_position != CurrentPosition: CurrentSegment.look_at(CurrentPosition)
	CurrentSegment.scale = Vector3(1, 1, (Distance + 1))
	CurrentSegment.global_position = (TurnStartPosition + CurrentPosition) / 2
