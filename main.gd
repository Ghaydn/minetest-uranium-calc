extends Control

const STAGES: int = 36
var last_step = []
var current_step: int = 1
var calculating: bool = false
var total_product: int = 0
var total0: int = 0
var unprocessed: int = 0
var peak: int = 0
var approx_time = 0
onready var calc = $Calc
onready var stop = $stop
onready var count_display = $counter
onready var base_number = $base
onready var dust = $dust
onready var stacks = $stacks
onready var centrifuges = $centrifuges
onready var onestep = $onestep
onready var pop = $pop


func _process(delta):
	if not calculating: return
	one_step()

func one_step():
	var new_step = calc_one_step(last_step)
	monitor(new_step)
	current_step += 1
	last_step = new_step
	draw_step(new_step)
	count_display.text = "Step №" + String(current_step) + ", approx. " + String(approx_time / 3600) + " centrifuge hours" + \
	".\n\rProduced " + String(total_product) + "(" + String(total_product / 5) + \
	" rods) and " + String(total0) + " waste.\n\rUnprocessed: " + \
	String(unprocessed) + ", peak: " + String(peak) + "."
	
	if check_step(new_step):
		calculating = false
		count_display.text = count_display.text + " Finished!"
		stop.visible = false
		onestep.visible = false

func check_step(step: Array) -> bool:
	for i in step:
		if i > 1:
			return false
	return true

func gn(num: int) -> int:
	if num == null:
		num = 0
	if num % 2 == 0:
		return num
	else:
		return num - 1

func calc_one_step(step: Array) -> Array:
	var new_step = []
	new_step.resize(STAGES)
	var s1 = STAGES - 1
	var s2 = STAGES - 2
	for i in range(STAGES):
		match i:
			0:
				new_step[i] = gn(step[i+1]) / 2
			1:
				new_step[i] = gn(step[i+1]) / 2
				if step[i] % 2 != 0:
					new_step[i] = new_step[i] + 1
			s2:
				new_step[i] = gn(step[i-1]) / 2
				if step[i] % 2 != 0:
					new_step[i] = new_step[i] + 1
			s1:
				new_step[i] = gn(step[i-1]) / 2
			_:
				new_step[i] = (gn(step[i-1]) + gn(step[i+1])) / 2
				if step[i] % 2 != 0:
					new_step[i] = new_step[i] + 1
	return new_step

func monitor(step: Array):
	total_product += step[STAGES-1]
	total0 += step[0]
	unprocessed = 0
	peak = 0
	for s in step:
		unprocessed += s
		if s > peak: peak = s
		if s > 0 and s < STAGES-1:
			approx_time = approx_time + gn(step[s] * 5)
	unprocessed -= step[0]
	unprocessed -= step[STAGES-1]

func draw_step(step: Array):
	centrifuges.text = "Centrifuges: "
	for part in step:
		centrifuges.text = centrifuges.text + " " + String(part)

func start_new_calc(value: int):
	get_tree().paused = false
	stop.text = "Pause"
	stop.visible = true
	onestep.visible = false
	calc.text = "Restart"
	last_step.clear()
	for s in range(STAGES):
		last_step.append(0)
	last_step[7] = value
	current_step = 0
	total_product = 0
	total0 = 0
	approx_time = 0
	calculating = true
	draw_step(last_step)


func _on_Calc_pressed():
	start_new_calc(base_number.value * 2)


func _on_stop_pressed():
	if not calculating: return
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		stop.text = "Proceed"
	else:
		stop.text = "Pause"
	onestep.visible = get_tree().paused


func _on_exti_pressed():
	get_tree().quit()


func _on_base_value_changed(value):
	dust.text = "(" + String(value * 2) + " dust)"
	stacks.text = "(" + String(int(value) / 99) + " stacks)"


func _on_onestep_pressed():
	one_step()


func _on_help_pressed():
	pop.show()


func _on_ok_pressed():
	pop.hide()


func _on_pop_gui_input(event):
	if event is InputEventMouseButton:
		pop.hide()
