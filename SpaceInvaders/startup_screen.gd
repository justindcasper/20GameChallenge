extends Node2D

signal started


func _input(event):
    if event is InputEventKey:
        started.emit()
