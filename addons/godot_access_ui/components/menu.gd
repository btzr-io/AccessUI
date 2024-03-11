extends Control
class_name AccessUIMenu

const ACCESS_UI_BUTTON = preload("res://addons/godot_access_ui/components/button/access_ui_button.tscn")
enum FOCUS_DIRECTIONS  { HORIZONTAL, VERTICAL }

var items : Array[Control]
var items_container : Control
var first_item : Control
var last_item : Control
var last_focus_item : Control

@export var menu_name : String = "" 
@export_node_path var menu_items_container : NodePath
@export_node_path var orgin_menu : NodePath

@export_category("Focus behavior")

@export var auto_focus: bool = true
@export var loop_focus : bool = true : 
	set(value):
		loop_focus = toggle_loop_navigation(value)
@export var remember_focus : bool = true
@export var focus_loop_direction : FOCUS_DIRECTIONS = FOCUS_DIRECTIONS.VERTICAL

@export_category("Close Button")

@export var show_close_button: bool  = false
@export var close_button_label : String = "Close"

func close():
	hide()
	if orgin_menu and !orgin_menu.is_empty():
		var target = get_node_or_null(orgin_menu)
		if target != null and target is AccessUIMenu:
			target.open()

func open(): show()

func create_close_button():
	var button : Button = ACCESS_UI_BUTTON.instantiate()
	button.text = close_button_label
	var close_action = InputEventAction.new()
	close_action.action = "ui_cancel"
	close_action.pressed = true
	button.shortcut = Shortcut.new()
	button.shortcut.events.append(close_action)
	button.pressed.connect(close)
	items_container.add_child(button)

func _ready() -> void:
	find_items_container()
	if show_close_button:
		create_close_button()
	find_items()
	focus_items()
	toggle_loop_navigation(loop_focus)
	visibility_changed.connect(on_visibility_changed)
	
func find_items_container():
	if menu_items_container:
		items_container = get_node_or_null(menu_items_container)
	if items_container == null:
		items_container = self

func find_items():
	items.clear()
	for item : Control in items_container.get_children():
		if item.focus_mode != FOCUS_NONE:
			item.focus_entered.connect(on_item_focus.bind(item))
			items.append(item)

func focus_items():
	if !items.is_empty() and auto_focus:
		if remember_focus and is_instance_valid(last_focus_item):
			last_focus_item.grab_focus()
		else:
			items[0].grab_focus()

func on_item_focus(item):
	last_focus_item = item

func on_visibility_changed():
	if is_visible_in_tree():
		focus_items()
	
func toggle_loop_navigation(enable_loop : bool = true) -> bool:
	if !items.is_empty():
		if items.size() > 1:
			first_item = items[0]
			last_item = items[items.size()-1]
			if enable_loop:
				first_item.focus_previous = last_item.get_path()
				last_item.focus_next = first_item.get_path()
				if focus_loop_direction == FOCUS_DIRECTIONS.VERTICAL:
					first_item.focus_neighbor_top = last_item.get_path()
					last_item.focus_neighbor_bottom = first_item.get_path()
				if focus_loop_direction == FOCUS_DIRECTIONS.HORIZONTAL:
					first_item.focus_neighbor_left = last_item.get_path()
					last_item.focus_neighbor_right = first_item.get_path()
	return enable_loop
