extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	# print("_draw")
	var edge_map = owner.edge_map
	var node_id_to_node = owner.node_id_to_node
	var color = owner.edge_color_picker.color
	var width = int(owner.edge_width_spin.value)
	
	for edge in edge_map.keys():
		var src = node_id_to_node[edge[0]].rect_position
		var dst = node_id_to_node[edge[1]].rect_position
		# print("draw_line", src, dst)
		draw_line(src, dst, color, width)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
