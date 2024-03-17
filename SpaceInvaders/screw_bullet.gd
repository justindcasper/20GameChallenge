extends Node2D

var fully_fired = false

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_spin_timer_timeout():
    $Sprite2D.flip_h = not $Sprite2D.flip_h
