extends Label

@export var countdown_time := 180.0 
var time_left := countdown_time

@export var progress_bar: ProgressBar

func _ready() -> void:
	text = format_time(time_left)
	if progress_bar:
		progress_bar.max_value = countdown_time
		progress_bar.value = countdown_time

func _process(delta: float) -> void:
	if time_left > 0:
		time_left -= delta
		if time_left < 0:
			time_left = 0
		
		text = format_time(time_left)
		
		if progress_bar:
			progress_bar.value = time_left
	else:
		print("Countdown finished!")

func format_time(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	return str(minutes) + ":" + str(seconds).pad_zeros(2)
