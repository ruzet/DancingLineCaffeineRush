@tool
extends EditorScript

func _run():
	var RecordedCurve: Curve3D = EditorInterface.get_edited_scene_root().find_child("LevelTrack").Curve
	for Point in RecordedCurve.get_baked_points():
		Point.y = 0
