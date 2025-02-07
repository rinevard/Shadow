class_name ImitationShadow
extends CharacterBody2D

signal all_action_completed()
@onready var player_action_component: PlayerActionComponent = $PlayerActionComponent

## 记录尚未完成的 actions 数量, 在所有 action 完成后发出信号来获取新的 actions
var action_num_to_complete: int = 0:
	set(num):
		action_num_to_complete = num
		if action_num_to_complete == 0:
			all_action_completed.emit()
var cur_pressed_action: int = -1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if cur_pressed_action == Enum.Actions.JUMP:
		print("repeat jump!")

	player_action_component.handle_action(cur_pressed_action)

	move_and_slide()

## 输入的 actions 是形如[[action, time1], [action, time2], ...] 的列表, time 的单位为秒
## time_1 从 0 开始, time_k 对应的 action 表示在 time_k 时按下的动作. 如果那一刻没有按下动作, action 为 -1
func repeat_actions(actions: Array[Array]):
	# TODO
	# 现在的 bug 是有些 action 会被吞掉, 诱因是两个 action 有相同的 time.
	# 我们要修改 ActionComponent, 让它能在同一时刻处理多个动作.
	# 做个类似输入缓存的东西?
	for tuple in actions:
		var action = tuple[0]
		var time = tuple[1]
		act_after_time(action, time)

## 在 time 时间后把 action 设为 cur_pressed_action
func act_after_time(action: int, time: float):
	action_num_to_complete += 1
	await get_tree().create_timer(time).timeout
	cur_pressed_action = action
	action_num_to_complete -= 1 
