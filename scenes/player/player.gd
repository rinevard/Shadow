extends CharacterBody2D

@onready var player_action_component: PlayerActionComponent = $PlayerActionComponent

# 墨
const INK_SHADOW = preload("res://scenes/shadows/ink_shadow.tscn")
var ink_shadow: Node2D = null

# 循迹相关

# 仿行相关
const IMITATION_SHADOW = preload("res://scenes/shadows/imitation_shadow.tscn")
var is_recording_action: bool = false
var imitation_shadow_born_global_pos: Vector2
var imitation_shadow: ImitationShadow = null

var ink_pressed_time: int = 0:
	set(value):
		ink_pressed_time = value
		if ink_pressed_time == 0:
			if ink_shadow and is_instance_valid(ink_shadow):
				ink_shadow.call_deferred("queue_free")
		elif ink_pressed_time == 1:
			ink_shadow = INK_SHADOW.instantiate()
			get_tree().root.add_child(ink_shadow)
			ink_shadow.global_position = global_position
		else:
			# 互换位置
			var tmp = global_position
			global_position = ink_shadow.global_position
			ink_shadow.global_position = tmp

var imitation_pressed_time: int = 0:
	set(value):
		imitation_pressed_time = value
		if imitation_pressed_time == 0:
			ActionRecorder.reset_action_record()
			ActionRecorder.end_record_action()
			is_recording_action = false
			if imitation_shadow and is_instance_valid(imitation_shadow):
				imitation_shadow.call_deferred("queue_free")
		elif imitation_pressed_time == 1:
			ActionRecorder.start_record_action()
			is_recording_action = true
			imitation_shadow_born_global_pos = global_position
			print("开始记录!")
		elif imitation_pressed_time == 2:
			imitation_shadow = IMITATION_SHADOW.instantiate()
			get_tree().root.add_child(imitation_shadow)
			imitation_shadow.global_position = imitation_shadow_born_global_pos
			imitation_shadow.all_action_completed.connect(_on_all_actions_completed)
			_on_all_actions_completed()
		else:
			# 互换位置
			var tmp = global_position
			global_position = imitation_shadow.global_position
			imitation_shadow.global_position = tmp

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var action: int = -1
	if Input.is_action_just_pressed("jump"):
		action = Enum.Actions.JUMP
	elif Input.is_action_pressed("left"):
		action = Enum.Actions.LEFT
	elif Input.is_action_pressed("right"):
		action = Enum.Actions.RIGHT
	
	player_action_component.handle_action(action)
	
	if is_recording_action:
		ActionRecorder.call_deferred("record_action", action)
	
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("remove-imitation"):
		imitation_pressed_time = 0
	elif event.is_action_pressed("simulate-imitation"):
		imitation_pressed_time += 1
	if event.is_action_pressed("remove-ink"):
		ink_pressed_time = 0
	elif event.is_action_pressed("ink"):
		ink_pressed_time += 1

func _on_all_actions_completed():
	assert(is_instance_valid(imitation_shadow) and imitation_shadow != null, "在 imitation_shadow 不合法时调用了 _on_actions_completed!")
	var actions = ActionRecorder.get_record_actions()
	imitation_shadow.repeat_actions(actions)
	ActionRecorder.reset_action_record()
