extends CharacterBody2D

signal fell
signal collided_with(object : Object)

@export var speed = 400
var launched : bool = false

func _ready():
    velocity = Vector2.ZERO

func _physics_process(delta):
    if launched:
        # Bounce the ball around, speeding it up as it goes
        var motion = velocity * delta * speed
        var collision_info = move_and_collide(motion)
        if collision_info:
            $SoundEffect.play()
            var reflect = collision_info.get_remainder().bounce(
                collision_info.get_normal())
            velocity = velocity.bounce(collision_info.get_normal())
            move_and_collide(reflect)
            
            var object_hit = collision_info.get_collider()
            collided_with.emit(object_hit)

func _on_visible_on_screen_notifier_2d_screen_exited():
    velocity = Vector2.ZERO
    fell.emit()
    
func launch(direction : Vector2):
    launched = true
    velocity = direction
