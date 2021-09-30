extends Control

const NetworkNode = preload("NetworkNode.tscn")

onready var scroll_container = $HBoxContainer/ScrollContainer
onready var map_rect = $HBoxContainer/ScrollContainer/MapRect
onready var select_box_node = $HBoxContainer/Tabs/Edit/SelectBoxNode
onready var select_box_edge = $HBoxContainer/Tabs/Edit/SelectBoxEdge
onready var node_color_picker = $HBoxContainer/Tabs/Config/NodeColorPicker
onready var edge_color_picker = $HBoxContainer/Tabs/Config/EdgeColorPicker
onready var edge_width_spin = $HBoxContainer/Tabs/Config/EdgeWidthSpin

var selected_node
var selected_edge

var edge_map = {}

var new_node_id = 0
var node_id_to_node = {}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_node():
	var pos = map_rect.get_local_mouse_position()
		
	var texture_rect = NetworkNode.instance()
	
	texture_rect.node_id = new_node_id
	node_id_to_node[texture_rect.node_id] = texture_rect
	new_node_id += 1
	
	texture_rect.meta_data = select_box_node.get_template()
	texture_rect.rect_position  = pos

	map_rect.add_child(texture_rect)
	texture_rect.set_color(node_color_picker.color)
	
	texture_rect.node_rect.connect("gui_input", self, "on_node_click", [texture_rect])


func _on_MapAnnotation_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			if selected_node != null:
				selected_node.rect_position = map_rect.get_local_mouse_position()
				map_rect.update()
			else:
				create_node()
		else:
			deselect_node()
			deselect_edge()
		
func select_node(node):
	selected_node = node
	
	select_box_node.unlock(str(node.node_id), node.meta_data)

func deselect_node():
	selected_node = null
	
	select_box_node.lock()
	
func encode_order(ij):
	return [min(ij[0], ij[1]), max(ij[0], ij[1])]
	
func select_edge(ij):
	ij = encode_order(ij)
	selected_edge = ij

	select_box_edge.unlock(str(ij), edge_map[ij])
	
func deselect_edge():
	selected_edge = null
	select_box_edge.lock()
		
func on_node_click(event, texture_rect):
	
	if event is InputEventMouseButton and event.pressed:
		var try_select_edge = false
		
		if event.button_index == BUTTON_LEFT:
			if selected_node == null:
				select_node(texture_rect)
			else:
				if selected_node == texture_rect:
					deselect_node()
				else:
					var edge = [selected_node.node_id, texture_rect.node_id]
					if not edge_exists(edge):
						create_edge(edge)
						map_rect.update()
					# print(edge_map)
					select_edge(edge)
					try_select_edge = true
			
		elif event.button_index == BUTTON_RIGHT:
			# print(selected_node == null, selected_node == texture_rect)
			
			if selected_node == null:
				delete_node(texture_rect)
				map_rect.update()
			elif selected_node == texture_rect:
				deselect_node()
			else:
				delete_edge([selected_node.node_id, texture_rect.node_id])
				map_rect.update()
				
		if not try_select_edge:
			deselect_edge()


func edge_exists(ij):
	return edge_map.has(encode_order(ij))
	
func get_meta_data(ij):
	return edge_map[encode_order(ij)]
	
func create_edge(ij):
	edge_map[encode_order(ij)] = select_box_edge.get_template()
	node_id_to_node[ij[0]].neighbor.append(ij[1])
	node_id_to_node[ij[1]].neighbor.append(ij[0])
	# map_rect.update()
	
func delete_edge(ij):
	# print("delete_edge", ij)
	edge_map.erase(encode_order(ij))
	# node_id_to_node[ij[0]].neighbor.remove(ij[1])
	# node_id_to_node[ij[1]].neighbor.remove(ij[0])
	node_id_to_node[ij[0]].neighbor.erase(ij[1])
	node_id_to_node[ij[1]].neighbor.erase(ij[0])
	# map_rect.update()
	
func delete_node(node):
	# print("node", node.node_id, "neighbors:", node.neighbor)
	var neighbor = node.neighbor
	# print(neighbor)
	for dst in neighbor.duplicate():
		# print("dst: ", dst)
		delete_edge(encode_order([node.node_id, dst]))
	node_id_to_node.erase(node.node_id)
	node.queue_free()
	# pass

"""
func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_idx == BUTTON_RIGHT:
		print(get_global_mouse_position(), get_local_mouse_position())
"""

func _on_SelectBoxNode_meta_changed(new_meta_data):
	print("_on_SelectBoxNode_meta_changed:", new_meta_data)
	selected_node.meta_data = new_meta_data


func _on_SelectBoxEdge_meta_changed(new_meta_data):
	print("_on_SelectBoxEdge_meta_changed:", new_meta_data)
	edge_map[selected_edge] = new_meta_data


func _on_ImportMap_pressed():
	$FileDialog.popup()

func _on_FileDialog_file_selected(path):
	print("Selected:", path)
	
	map_rect.texture = load_external_texture(path)
	
func load_external_texture(path):
	# https://www.reddit.com/r/godot/comments/ox381i/how_can_i_load_a_image_from_my_filesystem_into_my/
	var tex_file = File.new()
	tex_file.open(path, File.READ)
	var buffer = tex_file.get_buffer(tex_file.get_len())
	var img = Image.new()
	img.load_png_from_buffer(buffer)
	var imgtex = ImageTexture.new()
	imgtex.create_from_image(img)
	tex_file.close()
	return imgtex
	
func encode_state():
	var remap = {}
	var i = 0
	var node_data_list = []
	for node in map_rect.get_children():
		remap[node.node_id] = i
		i += 1
		
		var d = JSON.parse(node.meta_data).result
		
		node_data_list.append(d)
	
	var edge_data_list = []
	
	for ij in edge_map:
		var d = JSON.parse(edge_map[ij]).result
		edge_data_list.append([remap[ij[0]], remap[ij[1]], d])
	
	return {"node_list": node_data_list, "edge_list": edge_data_list}


func _on_FileDialogExport_file_selected(path):
	var d = encode_state()
	
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err == OK:
		file.store_line(JSON.print(d))
		file.close()
	else:
		print("Failed to export:", err)
	return err


func _on_ExportButton_pressed():
	$FileDialogExport.popup()
