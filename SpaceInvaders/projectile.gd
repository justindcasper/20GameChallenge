extends Area2D

signal out_of_bounds

@export var speed = 800


func _on_visible_on_screen_notifier_2d_screen_exited():
    out_of_bounds.emit()
