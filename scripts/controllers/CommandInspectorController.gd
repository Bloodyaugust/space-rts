extends Control

export var _buildable_item_control: PackedScene

onready var _buildable_items = $"./VBoxContainer/BuildableItems"

var _active = false
var _new_building_id: String
var _pending_building_ghost: Sprite

func _create_building_tooltip(building_data)->String:
  var _tooltip: String = building_data.name + "\r\n\r\n" + building_data.description + "\r\n\r\n--Cost--\r\n"

  for _key in building_data.cost.keys():
    _tooltip += "{cost_id}: {cost_value}\r\n".format({"cost_id": _key, "cost_value": building_data.cost[_key]})

  return _tooltip

func _hide():
  _active = false
  visible = false

  for _control_node in _buildable_items.get_children():
    _control_node.disabled = false
    _control_node.modulate = Color(1, 1, 1)
    _control_node.visible = false
    if _control_node.is_connected("pressed", self, "_on_new_building_selection"):
      _control_node.disconnect("pressed", self, "_on_new_building_selection")

  store.dispatch(actions.game_set_new_building_id(""))

func _on_new_building_selection(building_id):
  store.dispatch(actions.game_set_new_building_id(building_id))

func _on_store_changed(name, state):
  match name:
    "game":
      _new_building_id = state["new_building_id"]
      if state["selection"].get_class() == "Node2D":
        if _active == false:
          _show()

        _update_screen()

      else:
        if _active == true:
          _hide()

func _populate():
  GDUtil.free_children(_buildable_items)

  _pending_building_ghost = load("res://actors/PendingBuildingSprite.tscn").instance()
  get_tree().get_root().add_child(_pending_building_ghost)

  for i in range(DataController.buildings.keys().size()):
    var _current_building_data = DataController.buildings[DataController.buildings.keys()[i]]
    var _new_buildable_item_control: Button = _buildable_item_control.instance()

    _new_buildable_item_control.text = ""
    _new_buildable_item_control.icon = load("res://ui/icons/buildings/{id}.png".format({"id": _current_building_data.id}))

    _buildable_items.add_child(_new_buildable_item_control)

  store.subscribe(self, "_on_store_changed")

func _process(_delta):
  if _active:
    _update_screen()

func _ready():
  call_deferred("_populate")
  call_deferred("_show")

func _show():
  _active = true
  visible = true

  for i in range(DataController.buildings.keys().size()):
    var _current_buildable_item = _buildable_items.get_children()[i]
    var _current_buildable_item_id = DataController.buildings.keys()[i]
    
    _current_buildable_item.visible = true
    _current_buildable_item.hint_tooltip = _create_building_tooltip(DataController.buildings[_current_buildable_item_id])
    _current_buildable_item.connect("pressed", self, "_on_new_building_selection", [_current_buildable_item_id])

func _update_screen():
    for i in range(DataController.buildings.keys().size()):
      var _current_building_data = DataController.buildings[DataController.buildings.keys()[i]]
      var _current_buildable_item = _buildable_items.get_children()[i]

      if _current_building_data.id == _new_building_id:
        _current_buildable_item.disabled = false
        _current_buildable_item.modulate = Color(0.784314, 1, 0.721569)
      else:
        if _current_building_data.cost.metal > store.state()["player"]["resources"]["metal"]:
          _current_buildable_item.disabled = true
        else:
          _current_buildable_item.disabled = false
        _current_buildable_item.modulate = Color(1, 1, 1)
