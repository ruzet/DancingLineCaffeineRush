extends Node3D

@export var LineSpeed = 20
@export var Gravity = 10
@export var RecordPath = false
@export var LineMaterial: StandardMaterial3D

@onready var Head: CharacterBody3D = $"Head"
@onready var TrailContainer: Node = $"TrailContainer"
@onready var LevelTrack: Path3D = $"../LevelTrack"
@onready var Camera: Camera3D = $"../Camera"
@onready var AudioPlayer: AudioStreamPlayer = $"../AudioStreamPlayer"
@onready var UI: Control = $"../UI/LevelData"

var MainDirection = Vector3.FORWARD
var CurrentDirection = Vector3.FORWARD
var TurnStartPosition
var CurrentSegment: MeshInstance3D
var RecordedCurve: Curve3D
var SpawnPoint = 80
var LeftTurn = true
var Turned = false
var CanTurn = true
var Moving = false
var Grounded = false
var DebugMode = false

func _physics_process(Delta: float) -> void:
	Head.find_child("Mesh").material_override = LineMaterial
	self.get_parent().find_child("ActionBlocks").find_child("Death").global_position = Vector3(Head.global_position.x, -5, Head.global_position.z)
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
		if !RecordPath && !DebugMode: Head.velocity.y -= Gravity * Delta
	Head.move_and_slide()
	
func _input(Event: InputEvent) -> void: 
	if Event.is_action_pressed("Turn"):
		if UI.Ready:
			if !Moving: Ready() 
			else: Turn()
		else:
			UI.Ready = true
			UI.HideUI()
	elif Event.is_action_pressed("Reset"): Reset()
	elif Event.is_action_pressed("ui_text_newline") && RecordPath: _SaveRecordedPath()
			
func _ready() -> void:
	if SpawnPoint > 0: 
		self.position = LevelTrack.curve.get_point_position(SpawnPoint)
		self.position.y -= 0.5
		Turned = false if SpawnPoint % 2 == 0 else true
		if Turned: CurrentDirection = CurrentDirection.rotated(Vector3.UP, deg_to_rad(-90 if LeftTurn else 90))
			
	AudioPlayer.stream = preload("res://Assets/caffeinerush.wav")

func Ready():
	AudioPlayer.play()
	if Head.is_on_floor(): _SpawnNewSegment()
	AudioPlayer.play()
	if RecordPath:
		RecordedCurve = Curve3D.new()
		RecordedCurve.add_point(_GetHeadPointPosition())
	Moving = true
	
func Landed(): 
	TurnStartPosition = Head.global_position
	_SpawnNewSegment()

func Reset():
	MainDirection = Vector3.FORWARD
	CurrentDirection = Vector3.FORWARD
	TurnStartPosition = null
	LeftTurn = true
	Turned = false
	CanTurn = true
	Moving = false
	Grounded = false

	Head.global_position = Vector3.ZERO
	AudioPlayer.stop()

	for Segment in TrailContainer.get_children(): Segment.queue_free()
	for RunningTween in get_tree().get_processed_tweens():
		if RunningTween.is_valid() && RunningTween.is_running():
			RunningTween.kill()

	Camera.Position = Vector3(0.5, 0.75, 0.5)
	Camera.Distance = 20
	Camera.Following = true

func Turn():
	if !RecordPath && !DebugMode: if !CanTurn || !Moving || !Head.is_on_floor(): return
	_UpdateCurrentSegment()
	TurnStartPosition = Head.global_position
	if !Turned:
		CurrentDirection = CurrentDirection.rotated(Vector3.UP, deg_to_rad(90 if LeftTurn else -90))
	else:
		CurrentDirection = CurrentDirection.rotated(Vector3.UP, deg_to_rad(-90 if LeftTurn else 90))
	Turned = !Turned
	if RecordPath && RecordedCurve: RecordedCurve.add_point(_GetHeadPointPosition())
	_SpawnNewSegment()

func _SpawnNewSegment():
	if !TurnStartPosition: return
	var Box = BoxMesh.new()
	CurrentSegment = MeshInstance3D.new()
	CurrentSegment.mesh = Box
	
	if LineMaterial: CurrentSegment.material_override = LineMaterial
	TrailContainer.add_child(CurrentSegment)
	CurrentSegment.global_position = TurnStartPosition
	
func _SaveRecordedPath():
	if !RecordedCurve: return
	RecordedCurve.add_point(_GetHeadPointPosition())
	var SaveError = ResourceSaver.save(RecordedCurve, "res://Assets/RecordedCurve.tres")
	if SaveError == OK:
		print("saved correctly")
	else:
		print("error: " + SaveError)
		
func _GetHeadPointPosition(): return Vector3(snapped(Head.global_position.x, 0.01), 0, snapped(Head.global_position.z, 0.01))
func _UpdateCurrentSegment():
	if not CurrentSegment: return
	
	var CurrentPosition = Head.global_position
	var Distance = TurnStartPosition.distance_to(CurrentPosition)
	
	if CurrentSegment.global_position != CurrentPosition: CurrentSegment.look_at(CurrentPosition)
	CurrentSegment.scale = Vector3(1, 1, (Distance + 1))
	CurrentSegment.global_position = (TurnStartPosition + CurrentPosition) / 2
