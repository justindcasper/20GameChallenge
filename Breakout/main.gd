extends Node

var ball : Node
var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    $LivesLabel.text = "III"
    $ScoreLabel.text = str(score)
    ball = $Paddle/Ball
    # Listen for the ball falling and colliding
    ball.fell.connect(_on_ball_fell.bind())
    ball.collided_with.connect(_on_ball_collided_with.bind())
            
func end_game(win : bool):
    if not win:
        $Brickyard.clear_bricks()
        score = 0
    $ScoreLabel.text = str(score)
    $LivesLabel.text = "III"
    $Brickyard.lay_bricks()

func _on_paddle_launched(trajectory):
    # Take ownership of the ball and launch it
    ball.reparent(self)
    ball.launch(trajectory)


func _on_ball_fell():
    ball.launched = false
    if $LivesLabel.text.length() > 1:
        $LivesLabel.text = $LivesLabel.text.substr(1)
    else:
        $LivesLabel.text = ""
        end_game(false)
    # Give the ball back to $Paddle and tell it to get the ball ready
    ball.reparent($Paddle)
    $Paddle.set_ball()
    
func _on_ball_collided_with(object : Object):
    # There's no way the ball will collide with something that's not a Node,
    # but this is a good programming practice anyway
    if is_instance_of(object, Node):
        var object_parent = object.get_parent()
        # If $Brickyard is the parent, we know the ball collided with a brick
        if object_parent == $Brickyard:
            $Brickyard.break_brick(object)


func _on_brickyard_brick_broke(points):
    # Update the score and speed up the ball a bit
    score += points
    $ScoreLabel.text = str(score)
    ball.speed *= 1.005


func _on_brickyard_emptied():
    end_game(true)
