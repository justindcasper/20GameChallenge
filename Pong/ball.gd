extends CharacterBody2D

signal left_goal
signal right_goal

@export var speed = 500

func _physics_process(delta):
    # Bounce the ball around, speeding it up as it goes
    var motion = velocity * delta * speed
    var collision_info = move_and_collide(motion)
    if collision_info:
        var reflect = collision_info.get_remainder().bounce(
            collision_info.get_normal())
        velocity = velocity.bounce(collision_info.get_normal()) * 1.1
        move_and_collide(reflect)


func _on_visible_on_screen_notifier_2d_screen_exited():
    if position.x < 0:
        left_goal.emit()
    else:
        right_goal.emit()
