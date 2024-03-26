extends Node2D

const POINTS = 10
    
    
func play():
    $AnimatedSprite2D.play()
    
func speed_up(percentage : float):
    $AnimatedSprite2D.speed_scale *= 1.0 + percentage
    
func get_value():
    return POINTS
