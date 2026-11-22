@tool
extends Node3D

@export var TrackParts: Array[StaticBody3D] = []
@export var OldPositions: Array[Vector3] = []
@export_tool_button("Get All Track Parts", "ResourcePreloader") var GetAllParts = _GatherAllParts
@export_tool_button("Update Positions", "ResourcePreloader") var UpdatePositionButton = _UpdatePositions

func _UpdatePositions():
	if not Engine.is_editor_hint(): return
	if TrackParts.size() != OldPositions.size(): 
		_GatherAllParts() 
		return

	for i in range(TrackParts.size()):
		var Part = TrackParts[i]
		var CurrentPosition = Part.global_position
		var OldPosition = OldPositions[i]
		if not Part: continue

		if CurrentPosition != OldPosition:
			var MovementDelta = CurrentPosition - OldPosition
			for j in range(i + 1, TrackParts.size()): if TrackParts[j]: TrackParts[j].global_position += MovementDelta
			for k in range(TrackParts.size()): if TrackParts[k]: OldPositions[k] = TrackParts[k].global_position
			break

func _GatherAllParts():
	TrackParts.clear()
	OldPositions.clear()
	for Track in get_children(): if Track.name.begins_with("TrackPart"): TrackParts.append(Track)
	TrackParts.sort_custom(func(A, B): return A.name < B.name)
	for Track in TrackParts: OldPositions.append(Track.global_position)