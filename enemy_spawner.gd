extends Node3D

var enemy_scene = preload("res://enemy.tscn")
var spawn_points = []
func _ready():
	for child in get_children():
		if child is Marker3D:
			spawn_points.append(child)

func _on_timer_timeout():
	if spawn_points.is_empty():
		return
		
	var random_index = randi() % spawn_points.size()
	var target_point = spawn_points[random_index]

	var enemy = enemy_scene.instantiate()
	get_tree().root.add_child(enemy)
	
	enemy.global_position = target_point.global_position
