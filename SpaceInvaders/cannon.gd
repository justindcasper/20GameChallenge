extends Area2D

signal fired(laser : PackedScene, location : Vector2)

const Laser = preload("res://laser.tscn")

@export var speed = 400
var screen_size
var left_cannon_edge
var right_cannon_edge
var bottom_right_vertex_x
var bottom_left_vertex_x

var can_fire = false

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    left_cannon_edge = $CollisionShape.polygon[0]
    right_cannon_edge = $CollisionShape.polygon[1]
    bottom_right_vertex_x = $CollisionShape.polygon[8].x
    bottom_left_vertex_x = $CollisionShape.polygon[9].x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_pressed("move_left"):
        move(Vector2.LEFT, delta)
    if Input.is_action_pressed("move_right"):
        move(Vector2.RIGHT, delta)
        
        
func _input(event):
    if event is InputEventKey:
        if Input.is_action_just_pressed("fire"):
            var cannon_center = (left_cannon_edge + right_cannon_edge) / 2
            var laser_location = position + cannon_center
            # Fire the laser from the center of the cannon
            fired.emit(Laser, laser_location)
        
        
func move(direction : Vector2, delta : float):
    var velocity = direction * speed
    position += velocity * delta
    # Clamp based on the collision polygon's bottom vertices
    position.x = clamp(position.x, -bottom_left_vertex_x, screen_size.x - bottom_right_vertex_x)
    
    
func destroy():
    queue_free()
    
    
func set_can_fire(can : bool):
    can_fire = can
