extends Node

const HIGH_SCORE_FMT = "HighScore\n%d"

var ball : Node
var score : int = 0
var high_score : int

# Called when the node enters the scene tree for the first time.
func _ready():
    high_score = load_high_score()
    $LivesLabel.text = "III"
    $ScoreLabel.text = str(score)
    $HighScoreLabel.text = HIGH_SCORE_FMT % high_score
    ball = $Paddle/Ball
    # Listen for the ball falling and colliding
    ball.fell.connect(_on_ball_fell.bind())
    ball.collided_with.connect(_on_ball_collided_with.bind())
    
    
func load_high_score():
    var saved_score = 0
    var config = ConfigFile.new()
    var err = config.load("user://score.cfg")
    if err != OK:
        return saved_score
        
    for section in config.get_sections():
        saved_score = config.get_value(section, "score")
        
    return saved_score
    
func save():
    var saved_score = load_high_score()
    if saved_score < score:
        var config = ConfigFile.new()
        high_score = score
        config.set_value("high_score", "score", high_score)
        config.save("user://score.cfg")

func end_game(win : bool):
    if win:
        # Shrink the paddle by a quarter BEFORE reparenting the ball
        $Paddle.scale.x *= 0.75
        ball.reparent($Paddle)
        $Paddle.set_ball()
    else:
        save()
        $HighScoreLabel.text = HIGH_SCORE_FMT % high_score
        $Brickyard.clear_bricks()
        score = 0
        ball.reparent($Paddle)
        $Paddle.set_ball()
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
        # Give the ball back to $Paddle and tell it to get the ball ready
        ball.reparent($Paddle)
        $Paddle.set_ball()
    else:
        $LivesLabel.text = ""
        end_game(false)
    
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
