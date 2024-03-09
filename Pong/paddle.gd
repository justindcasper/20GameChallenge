extends StaticBody2D

@export var speed = 500
@export var top_limit = 0
@export var bottom_limit = 0
@export var using_w_s : bool = false # Using W and S instead of Up and Down
var screen_size
var buffer # Boundary for the paddle

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    # Let's keep the paddle half its height away from the edge
    # (Remember we're calculating from the center of the paddle)
    buffer = $ColorRect.size.y
    screen_size.y -= buffer + bottom_limit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var velocity = Vector2.ZERO
    
    var up_input
    var down_input
    if using_w_s:
        up_input = "move_W"
        down_input = "move_S"
    else:
        up_input = "move_up"
        down_input = "move_down"
        
    if Input.is_action_pressed(up_input):
        velocity.y -= speed
    if Input.is_action_pressed(down_input):
        velocity.y += speed
        
    position += velocity * delta
    position = position.clamp(Vector2(0, buffer + top_limit), screen_size)
