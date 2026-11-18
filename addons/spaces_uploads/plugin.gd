@tool
extends EditorPlugin

const SIGNAL_FILE := "/tmp/godot-rescan"
const TERMINAL := "/opt/godot/terminal"

var timer: Timer
var terminal_button: Button


func _enter_tree() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_check)
	add_child(timer)
	timer.start()
	if FileAccess.file_exists(TERMINAL):
		terminal_button = Button.new()
		terminal_button.text = "Terminal"
		terminal_button.tooltip_text = "Open a terminal in this project's folder"
		terminal_button.flat = true
		terminal_button.pressed.connect(_open_terminal)
		add_control_to_container(CONTAINER_TOOLBAR, terminal_button)


func _exit_tree() -> void:
	if is_instance_valid(timer):
		timer.queue_free()
	if is_instance_valid(terminal_button):
		remove_control_from_container(CONTAINER_TOOLBAR, terminal_button)
		terminal_button.queue_free()


func _open_terminal() -> void:
	OS.create_process(TERMINAL, [ProjectSettings.globalize_path("res://")])


func _check() -> void:
	if not FileAccess.file_exists(SIGNAL_FILE):
		return
	var filesystem := EditorInterface.get_resource_filesystem()
	if filesystem.is_scanning():
		return
	DirAccess.remove_absolute(SIGNAL_FILE)
	filesystem.scan()
