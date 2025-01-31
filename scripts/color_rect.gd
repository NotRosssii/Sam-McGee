extends CanvasLayer


@onready var shader_material: ShaderMaterial = $ColorRect.material as ShaderMaterial

func _ready():
	var screen_size = get_viewport().size
	shader_material.set_shader_parameter("screen_size", screen_size)
