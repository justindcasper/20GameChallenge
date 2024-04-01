extends ScreenwrappedRigidBody2D

signal fired(bullet_prefab : PackedScene, location : Vector2, velocity : Vector2)
signal exploded(location : Vector2)

const PROPULSION_COORD := [0, 24]
const FRONT_COORD := [0, -32]
const COORDS_OUTLINE : Array = [
    FRONT_COORD, [18, 32], PROPULSION_COORD, [-18, 32], FRONT_COORD
]
const BULLET_SPEED := 2000

const Bullet = preload("res://bullet.tscn")

var outline : PackedVector2Array
## Input force when moving forward.
@export var input_force := Vector2(0, -2500)
## Input torque when rotating.
@export var input_torque := 3500.0
## Maximum speed.
@export var max_speed := 800

# Called when the node enters the scene tree for the first time.
func _ready():
    outline = float_array_to_Vector2Array(COORDS_OUTLINE)
    $Polyline2D.set_points(outline)
    $CollisionPolygon2D.set_polygon(outline)
    $PropulsionParticles.position = Vector2(PROPULSION_COORD[0], PROPULSION_COORD[1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if get_node_or_null("PropulsionParticles") == null:
        return
    if Input.is_action_pressed("forward"):
        $PropulsionParticles.emitting = true
    else:
        $PropulsionParticles.emitting = false
        
        
func _physics_process(delta):
    super(delta)
    
    if Input.is_action_pressed("forward"):
        apply_force(input_force.rotated(rotation))
    if Input.is_action_pressed("rotate_left"):
        apply_torque(-input_torque)
    if Input.is_action_pressed("rotate_right"):
        apply_torque(input_torque)
        
        
func _integrate_forces(state):
    if state.linear_velocity.length() > max_speed:
        state.linear_velocity = state.linear_velocity.normalized() * max_speed
    

func _input(event):
    if event is InputEventKey:
        if Input.is_action_just_pressed("fire"):
            fire_bullet()


func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
    # Convert the Array of floats into a PackedVector2Array
    var array : PackedVector2Array = []
    for coord in coords:
        array.append(Vector2(coord[0], coord[1]))
    return array
    

func fire_bullet():
    var front = Vector2(FRONT_COORD[0], FRONT_COORD[1]).rotated(rotation)
    fired.emit(Bullet, position + front, BULLET_SPEED * Vector2.UP.rotated(rotation))
    
    
func destroy():
    $Polyline2D.queue_free()
    $CollisionPolygon2D.queue_free()
    $PropulsionParticles.queue_free()
    if $ExplosionParticles.emitting:
        await $ExplosionParticles.finished
    queue_free()
    

func _on_body_entered(body):
    if not (body is ScreenwrappedRigidBody2D):
        $ExplosionParticles.emitting = true
        exploded.emit(position)
