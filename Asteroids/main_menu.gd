extends Control

signal start_button_pressed


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_start_button_pressed():
    start_button_pressed.emit()


func _on_quit_button_pressed():
    get_tree().quit()
