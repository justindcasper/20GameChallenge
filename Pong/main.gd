extends Node

const Ball = preload("res://ball.tscn")
const SERVE_X = 960
const SERVE_TOP_LIMIT = 180
const SERVE_BOT_LIMIT = 996

var ball
var left_score : int = 0
var right_score : int = 0

enum Direction {
    LEFT,
    RIGHT,
}

# Called when the node enters the scene tree for the first time.
func _ready():
    serve_ball(Direction.RIGHT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
    #pass

# Helper for setting up what the serve should look like
func set_serve_parameters(direction: Direction):
    var paddle_pos
    var serve_y = randf_range(SERVE_TOP_LIMIT, SERVE_BOT_LIMIT)
    # We want to serve the ball at a random position along the center
    # divider, at a velocity based on where the scoring paddle is as if
    # they were serving the ball to the player who was scored on
    match direction:
        Direction.LEFT:
            paddle_pos = $PaddleRight.position
        Direction.RIGHT:
            paddle_pos = $PaddleLeft.position
        
    var serve_pos = Vector2(SERVE_X, serve_y)
    ball.position = serve_pos
    var serve_paddle_difference: Vector2 = serve_pos - paddle_pos
    ball.velocity = serve_paddle_difference.normalized()

# Actually instantiate the ball and set it loose
func serve_ball(direction : Direction):
    ball = Ball.instantiate()
    set_serve_parameters(direction)
    add_child(ball)
    ball.left_goal.connect(_on_ball_left_goal.bind())
    ball.right_goal.connect(_on_ball_right_goal.bind())
    
# Free the ball, wait a second, and serve
func reset(direction : Direction):
    ball.queue_free()
    await get_tree().create_timer(1.0).timeout
    serve_ball(direction)
    
# Right paddle scored
func _on_ball_left_goal():
    right_score += 1
    $ScoreRight.text = str(right_score)
    reset(Direction.LEFT)
    
# Left paddle scored
func _on_ball_right_goal():
    left_score += 1
    $ScoreLeft.text = str(left_score)
    reset(Direction.RIGHT)
    
