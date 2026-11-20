@tool
extends Path3D

@export var TrackWidth = 4.0
@export var TrackHeight = 2.0
@export var TrackMaterial: StandardMaterial3D
@export var DeleteAll = false
@export var Rebuild = false: 
	set(value): 
		if value:
			BuildTrack()
			Rebuild = false

@onready var MeshHolder = $"MeshHolder"

func BuildTrack():
	if !curve: return
	if DeleteAll: for Part in MeshHolder.get_children(): Part.free()
	
	for i in range(curve.point_count - 1):
		var StartPosition = curve.get_point_position(i)
		var EndPosition = curve.get_point_position(i + 1)
		var Distance = StartPosition.distance_to(EndPosition)
		
		if Distance < 0.01: continue
		
		var NewStaticBody = StaticBody3D.new()
		NewStaticBody.name = "TrackPart" + str(i)
		MeshHolder.add_child(NewStaticBody)
		
		var NewMeshInstance = MeshInstance3D.new()
		var NewBoxMesh = BoxMesh.new()
		NewBoxMesh.size = Vector3(TrackWidth, TrackHeight, Distance + TrackWidth)
		NewMeshInstance.mesh = NewBoxMesh
		NewStaticBody.add_child(NewMeshInstance)
		
		if Engine.is_editor_hint() && get_tree(): 
			NewStaticBody.owner = get_tree().edited_scene_root
			NewMeshInstance.owner = get_tree().edited_scene_root
		
		var NewCollision = CollisionShape3D.new()
		var NewBoxShape = BoxShape3D.new()
		NewBoxShape.size = NewBoxMesh.size
		NewCollision.shape = NewBoxShape
		
		NewStaticBody.add_child(NewCollision)
		if Engine.is_editor_hint() and get_tree():
			NewCollision.owner = get_tree().edited_scene_root
		
		if TrackMaterial: NewBoxMesh.material = TrackMaterial
		NewStaticBody.position = (StartPosition + EndPosition) / 2
		NewStaticBody.position.y = -TrackHeight / 2.0
		NewStaticBody.look_at(to_global(EndPosition) + Vector3(0, -TrackHeight / 2.0, 0), Vector3.UP)
		
		
