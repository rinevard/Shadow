class_name PlayerActionComponent
extends Node2D

@export var character_body: CharacterBody2D
@export var speed: float = 900.0
@export var jump_velocity: float = -1550.0

## 接受一个动作(输入为 -1 或 autoload 里的 enum 值), 让 character_body 做出相应行为
## 如果输入为 -1, 表示没有输入的动作, character_body 将减速
func handle_action(action: int):
	match action:
		Enum.Actions.LEFT:
			character_body.velocity.x = -1 * speed
		Enum.Actions.RIGHT:
			character_body.velocity.x = 1 * speed
		Enum.Actions.JUMP:
			if character_body.is_on_floor():
				character_body.velocity.y = jump_velocity
		_:
			character_body.velocity.x = move_toward(character_body.velocity.x, 0, speed)
