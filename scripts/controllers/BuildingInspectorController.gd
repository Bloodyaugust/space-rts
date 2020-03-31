extends Control

onready var _auto_build = $"./BuildingContent/BuildingOptions/auto-build"
onready var _buildingName: Label = $"./BuildingContent/BuildingStatus/BuildingName"
onready var _buildingProgress: ProgressBar = $"./BuildingContent/BuildingStatus/ProgressContainer/ProgressBar"
onready var _buildingHPBar: ProgressBar = $"./BuildingContent/BuildingStatus/HPContainer/HPBar"
onready var _buildingHPAmount: Label = $"./BuildingContent/BuildingStatus/HPContainer/HPBar/HPAmountContainer/HPAmount"
onready var _building_resource_items = $"./BuildingContent/ResourceItems"
onready var _building_buildable_items = $"./BuildingContent/BuildableItems"
onready var _building_options = $"./BuildingContent/BuildingOptions"

var _active = false
var _selection: Node

func _hide():
  _active = false
  visible = false

  for _control_node in _building_resource_items.get_children():
    _control_node.visible = false

  for _control_node in _building_buildable_items.get_children():
    _control_node.visible = false
    if _control_node.is_connected("pressed", self, "_on_production_selection"):
      _control_node.disconnect("pressed", self, "_on_production_selection")
  
  for _control_node in _building_options.get_children():
    _control_node.visible = false
    if _control_node.is_connected("pressed", self, "_on_auto_build_toggle"):
      _control_node.disconnect("pressed", self, "_on_auto_build_toggle")

func _on_production_selection(production_index):
  _selection.set_current_production(production_index)

func _on_auto_build_toggle():
  _selection.auto_build = _auto_build.pressed

func _on_store_changed(name, state):
  match name:
    "game":
      if state["selection"].get_class() == "Building":
        _selection = state["selection"]

        _update_screen()

        if _active == false:
          _show()
      else:
        if _active == true:
          _hide()

func _process(_delta):
  if _active:
    if _selection:
      _update_screen()
    else:
      hide()

func _ready():
  _hide()
  store.subscribe(self, "_on_store_changed")

func _show():
  var _input_storage_size = _selection.input_storage.keys().size()

  _active = true
  visible = true

  _selection.connect("tree_exited", self, "set", ["_selection", null])

  for i in range(_input_storage_size):
    var _current_resource_item = _building_resource_items.get_children()[i]
    var _current_storage_item_id = _selection.input_storage.keys()[i]
    
    _current_resource_item.visible = true
    _current_resource_item.get_node("./icon").texture = load("res://ui/icons/resources/{id}.png".format({"id": _selection.input_storage.keys()[i]}))
    _current_resource_item.get_node("./label").text = "{id}: {amount}".format({"id": _current_storage_item_id, "amount": _selection.input_storage[_current_storage_item_id]})

  for i in range(_selection.output_storage.keys().size()):
    var _element_index = i + _input_storage_size
    var _current_resource_item = _building_resource_items.get_children()[_element_index]
    var _current_storage_item_id = _selection.output_storage.keys()[i]
    
    _current_resource_item.visible = true
    _current_resource_item.get_node("./icon").texture = load("res://ui/icons/resources/{id}.png".format({"id": _selection.output_storage.keys()[i]}))
    _current_resource_item.get_node("./label").text = "{id}: {amount}".format({"id": _current_storage_item_id, "amount": _selection.output_storage[_current_storage_item_id]})
  
  if _selection.production.size() > 1:
    for i in range(_selection.production.size()):
      var _current_buildable_item = _building_buildable_items.get_children()[i]
      var _current_production = _selection.production[i]

      _current_buildable_item.text = _current_production.id
      _current_buildable_item.visible = true
      _current_buildable_item.connect("pressed", self, "_on_production_selection", [i])

    _auto_build.visible = true
    _auto_build.pressed = _selection.auto_build
    _auto_build.connect("pressed", self, "_on_auto_build_toggle")

func _update_screen():
  var _current_element_index = 0
  var _resource_elements = _building_resource_items.get_children()
  
  _buildingName.text = _selection.id
  _buildingProgress.value = _selection.production_time - _selection.time_to_production
  _buildingProgress.max_value = _selection.production_time
  _buildingHPBar.value = _selection.current_health
  _buildingHPBar.max_value = _selection.health
  _buildingHPAmount.text = "{current_health}/{health}".format({"current_health": _selection.current_health, "health": _selection.health})

  for _key in _selection.input_storage.keys():
    var _current_value = _selection.input_storage[_key]

    _resource_elements[_current_element_index].get_node("./label").text = "{id}: {amount}".format({"id": _key, "amount": _current_value})
    _current_element_index += 1

  for _key in _selection.output_storage.keys():
    var _current_value = _selection.output_storage[_key]

    _resource_elements[_current_element_index].get_node("./label").text = "{id}: {amount}".format({"id": _key, "amount": _current_value})
    _current_element_index += 1

  if _selection.production.size() > 1:
    for i in range(_selection.production.size()):
      var _current_buildable_item = _building_buildable_items.get_children()[i]
      var _current_production = _selection.production[i]
      
      if _selection.current_production == i && _selection.want_to_produce:
        _current_buildable_item.modulate = Color(0.784314, 1, 0.721569)
      else:
        _current_buildable_item.modulate = Color(1, 1, 1)
