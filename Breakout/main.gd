extends Node

var ball : Node
var player_points : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    ball = $Paddle/Ball
    ball.fell.connect(_on_ball_fell.bind())
    ball.collided_with.connect(_on_ball_collided_with.bind())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
    #if singleplayer and is_instance_valid(ball):
        ## Basically, just follow the ball. This is hard to beat, but not
        ## impossible. Could add some random processing "failures"?
        #var paddle_pos = $PaddleLeft.position.y
        #var paddle_half_length = $PaddleLeft/CollisionShape2D.shape.size.y / 2
        #if (paddle_pos - paddle_half_length) > ball.position.y:
            #$PaddleLeft.move($PaddleLeft.Direction.UP, delta)
        #elif (paddle_pos + paddle_half_length) < ball.position.y:
            #$PaddleLeft.move($PaddleLeft.Direction.DOWN, delta)
            
    
#func _unhandled_key_input(_event):
    ## Pause menu
    #if Input.is_action_just_pressed("pause"):
        #get_tree().paused = true
        #$MainMenu.show()
        
## When a game is restarted in the menu
#func _on_main_menu_restarted(mode):
    ## If we're going to single player mode, turn off processing on the left
    ## paddle. Turn it on if we're multiplayer
    #singleplayer = ($MainMenu.Mode.SINGLE == mode)
    #$PaddleLeft.set_process(not singleplayer)
    ## Restart the game
    #reset(Direction.RIGHT, false)

func _on_paddle_launched(trajectory):
    ball.reparent(self)
    ball.launch(trajectory)


func _on_ball_fell():
    ball.launched = false
    ball.reparent($Paddle)
    $Paddle.set_ball()
    
func _on_ball_collided_with(object : Object):
    if is_instance_of(object, Node):
        var object_parent = object.get_parent()
        if object_parent == $Brickyard:
            $Brickyard.break_brick(object)


func _on_brickyard_brick_broke(points):
    player_points += points
    ball.speed *= 1.005
