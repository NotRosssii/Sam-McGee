extends CanvasLayer

const MAX_HEALTH = 100
const MAX_TEMP = 100
var health = MAX_HEALTH
var temp = MAX_TEMP
var player_node

func _ready() -> void:
	player_node = find_parent_by_name("Player")

	if player_node and player_node.has_signal("cold_updated"):
		player_node.connect("cold_updated", Callable(self, "_on_cold_updated"))

	$Health.max_value = MAX_HEALTH
	$Temperature.max_value = MAX_TEMP
	set_health_bar(health)
	set_temp_bar(temp)

func find_parent_by_name(target_name: String) -> Node:
	var parent = get_parent()
	while parent:
		if parent.name == target_name:
			return parent
		parent = parent.get_parent()
	return null

func set_health_bar(health_value: float) -> void:
	$Health.value = health_value

func set_temp_bar(temp_value: float) -> void:
	$Temperature.value = temp_value

func _on_cold_updated(new_temp: float) -> void:
	temp = new_temp
	set_temp_bar(temp)

	if player_node:
		health = player_node.health
		set_health_bar(health)
