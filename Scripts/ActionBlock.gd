class_name ActionBlock
extends Area3D

@export_enum("CameraTween", "JumpPad", "LineColor") var BlockType: int = 0

@export var Position: Vector3 = Vector3.ZERO
@export var Distance: float = 0
@export var CameraDuration: float = 0

@export var JumpPower: float = 0

@export var LineColor: Color = Color.ORANGE
@export var ColorDuration: float = 0