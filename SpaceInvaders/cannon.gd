extends Area2D

@export var speed = 400
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_pressed("move_left"):
        move(Vector2.LEFT, delta)
    if Input.is_action_pressed("move_right"):
        move(Vector2.RIGHT, delta)
        
        
func move(direction : Vector2, delta : float):
    var velocity = direction * speed
    position += velocity * delta
    # Clamp based on the collision polygon's bottom vertices
    position.x = clamp(position.x, -$CollisionShape.polygon[9].x,
        screen_size.x - $CollisionShape.polygon[8].x)
