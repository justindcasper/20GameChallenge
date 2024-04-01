extends Node2D
class_name Polyline2D

## The points to draw, as used by draw_polyline.
@export var points : PackedVector2Array:
    set(value):
        points = value
        queue_redraw()
## The color of the line, as used by draw_polyline.
@export var color : Color:
    set(value):
        color = value
        queue_redraw()
## The width of the line, as used by draw_polyline.
@export var width : float:
    set(value):
        width = value
        queue_redraw()
## Whether it is antialiased, as used by draw_polyline.
@export var antialiased : bool:
    set(value):
        antialiased = value
        queue_redraw()


func _draw():
    draw_polyline(points, color, width, antialiased)
    
    
func set_points(value):
    points = value
    

func set_color(value):
    color = value
    
    
func set_width(value):
    width = value
    

func set_antialiased(value):
    antialiased = value
