extends Control

var node_id: int
var meta_data: String
var neighbor = []

onready var node_rect = $NodeRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_color(color):
	node_rect.color = color


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
