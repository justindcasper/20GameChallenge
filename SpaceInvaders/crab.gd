extends Node2D

const POINTS = 20


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func play():
    $AnimatedSprite2D.play()
    
func speed_up(percentage : float):
    $AnimatedSprite2D.speed_scale *= 1.0 + percentage
    
func get_value():
    return POINTS
