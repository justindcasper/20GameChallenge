extends StaticBody2D

signal launched(trajectory : Vector2)

const BALL_RADIUS = 10

@export var speed = 1600
var screen_size
var on_paddle_location : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
    on_paddle_location = Vector2($CollisionShape2D.position.x, -(BALL_RADIUS))
    screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_pressed("move_left"):
        move(Vector2.LEFT, delta)
    if Input.is_action_pressed("move_right"):
        move(Vector2.RIGHT, delta)
    if Input.is_action_pressed("launch"):
        var trajectory = Vector2.UP
        if (position.x + $CollisionShape2D.position.x) > (screen_size.x / 2):
            trajectory += Vector2.LEFT
        else:
            trajectory += Vector2.RIGHT
        launch(trajectory)
        
    

func move(direction : Vector2, delta : float):
    var y_limit = screen_size.y - $ColorRect.size.y
    var velocity = direction * speed
    
    position += velocity * delta
    position = position.clamp(Vector2(16, y_limit),
        Vector2(screen_size.x - $ColorRect.size.x - 16, y_limit))
        
    
func launch(trajectory : Vector2):
    launched.emit(trajectory)
    
func set_ball():
    $Ball.velocity = Vector2.ZERO
    $Ball.position = on_paddle_location
