extends Control

signal meta_changed

onready var label_value = $VBoxContainer/LabelValue
onready var text_meta = $VBoxContainer/TextMeta
onready var text_template = $VBoxContainer/TextTemplate

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_label_value(text):
	label_value.text = text
	
func get_label_value():
	return label_value.text

func set_meta_info(text):
	text_meta.text = text

func get_meta_info():
	return text_meta.text
	
func set_template(text):
	text_template.text = text
	
func get_template():
	return text_template.text
	
func lock():
	text_meta.readonly = true
	
	set_label_value("")
	set_meta_info("")
	
func unlock(label:String, info:String):
	text_meta.readonly = false

	set_label_value(label)
	set_meta_info(info)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextMeta_text_changed():
	emit_signal("meta_changed", get_meta_info())
