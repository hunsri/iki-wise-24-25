class_name CardDialog
extends ConfirmationDialog

signal confirmation_result(result : bool)

# Wheter a selection has been made or not
var finished = false

var result = null

var scene_root
var ok_button : Button
var cancel_button  : Button


func wait_for_user_decision() -> bool:
	finished = false
	result = null
	scene_root = get_tree()
	
	return await confirmation_result
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ok_button = get_ok_button()
	cancel_button = get_cancel_button()
	ok_button.pressed.connect(_on_ok_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


func _on_ok_pressed():
	result = true
	finished = true
	confirmation_result.emit(result)
	
func _on_cancel_pressed():
	result = false
	finished = true
	confirmation_result.emit(result)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
