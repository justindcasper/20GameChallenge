extends VBoxContainer

enum Mode {
    SINGLE,
    MULTI,
}

# We should only allow $BackButton to do anything if a game is in progress
var started : bool = false

signal restarted(mode : Mode)


func _on_single_player_button_pressed():
    hide()
    restarted.emit(Mode.SINGLE)
    started = true
    get_tree().paused = false


func _on_multi_player_button_pressed():
    hide()
    restarted.emit(Mode.MULTI)
    started = true
    get_tree().paused = false


func _on_back_button_pressed():
    if started:
        hide()
        get_tree().paused = false
