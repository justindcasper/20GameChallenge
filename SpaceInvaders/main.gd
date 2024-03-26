extends Node

const Startup_Screen = preload("res://startup_screen.tscn")
const Level = preload("res://level.tscn")

var startup_screen
var level

# Called when the node enters the scene tree for the first time.
func _ready():
    startup()



func startup():
    startup_screen = Startup_Screen.instantiate()
    level = Level.instantiate()
    add_child(startup_screen)
    startup_screen.started.connect(_on_startup_screen_started.bind())
    level.game_overed.connect(_on_level_game_overed.bind())
    
    
    
func _on_startup_screen_started():
    add_child(level)
    startup_screen.queue_free()
    
    
func _on_level_game_overed():
    level.queue_free()
    startup()
