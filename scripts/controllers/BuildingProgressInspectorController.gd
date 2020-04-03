extends Control

export var _required_resource_item_element: PackedScene

onready var _building_icon = $"./HBoxContainer/VBoxContainer/BuildingIcon/"
onready var _building_name = $"./HBoxContainer/VBoxContainer/BuildingName/"
onready var _building_progress = $"./HBoxContainer/VBoxContainer/ProgressBar/"
onready var _required_resources = $"./HBoxContainer/VBoxContainer/RequiredResources/"

var _active = false
var _selection: Node2D

func _create_required_resource_items(building_data: BuildingGhost)->void:
  for _resource_key in building_data.required_inputs.keys():
    var _new_required_resource_item: Control = _required_resource_item_element.instance()

    _new_required_resource_item.name = _resource_key

    _required_resources.add_child(_new_required_resource_item)

func _update_required_resource_items(building_data: BuildingGhost)->void:
  for _resource_key in building_data.required_inputs.keys():
    var _current_control: Label = _required_resources.get_node(_resource_key).get_node("item-amount")

    _current_control.text = "{current_resource}/{required_resource}".format({
      "current_resource": building_data.input_storage.get(_resource_key, 0), 
      "required_resource": building_data.required_inputs[_resource_key]
    })

func _hide():
  _active = false
  visible = false

  GDUtil.free_children(_required_resources)

func _on_store_changed(name, state):
  match name:
    "game":
      if state["selection"].get_class() == "BuildingGhost":
        _selection = state["selection"]
        if _active == false:
          _show()

        _update_screen()

      else:
        if _active == true:
          _hide()

func _process(_delta):
  if _active:
    _update_screen()

func _ready():
  call_deferred("hide")
  store.subscribe(self, "_on_store_changed")

func _show():
  _active = true
  visible = true

  _create_required_resource_items(_selection)
  _building_icon.texture = load("res://sprites/buildings/{building_id}.png".format({"building_id": _selection.id}))
  _building_name.text = _selection._data["name"]
  _building_progress.value = _selection.get_building_progress()

func _update_screen():
  _building_progress.value = _selection.get_building_progress()
  _update_required_resource_items(_selection)
