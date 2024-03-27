@tool
extends RigidBody2D

const PROPULSION_COORD := [0, 24]
const COORDS_OUTLINE : Array = [
    [0, -32], [18, 32], PROPULSION_COORD, [-18, 32], [0, -32]
]

@export var input_force := Vector2(0, -5000)
@export var input_torque := 15000.0
var outline : PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready():
    outline = float_array_to_Vector2Array(COORDS_OUTLINE)
    $CollisionPolygon2D.set_polygon(outline)
    $PropulsionParticles.position = Vector2(PROPULSION_COORD[0], PROPULSION_COORD[1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if Input.is_action_pressed("forward"):
        $PropulsionParticles.emitting = true
    else:
        $PropulsionParticles.emitting = false
    
    
func _input(event):
    if event is InputEventKey:
        if Input.is_action_pressed("forward"):
            apply_force(input_force.rotated(rotation))
        if Input.is_action_pressed("rotate_left"):
            apply_torque(-input_torque)
        if Input.is_action_pressed("rotate_right"):
            apply_torque(input_torque)
    
    
    
func _draw():
    draw_polyline(outline, Color.GREEN, 4.0)


func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
    # Convert the Array of floats into a PackedVector2Array
    var array : PackedVector2Array = []
    for coord in coords:
        array.append(Vector2(coord[0], coord[1]))
    return array
    
