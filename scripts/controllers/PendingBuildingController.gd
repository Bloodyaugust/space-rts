extends Sprite

onready var _tree = get_tree()
onready var _root = _tree.get_root()

onready var _empty_node = Node2D.new()

var _new_building_id: String

func _hide():
  visible = false

func _on_store_changed(name, state):
  match name:
    "game":
      _set_building_id(state)

      if state["selection"].get_class() == "Node2D" && _new_building_id != "":
        if visible == false:
          _show()

      else:
        if visible == true:
          _hide()

func _process(_delta):
  global_position = get_global_mouse_position()

  if visible && Input.is_action_just_pressed("ui_select"):
    var _new_building_ghost: BuildingGhost = BuildingGhost.new()

    _new_building_ghost.id = _new_building_id
    _new_building_ghost.position = global_position

    _root.add_child(_new_building_ghost)

    if !Input.is_action_pressed("ui_continue"):
      store.dispatch(actions.game_selection(_empty_node))
      store.dispatch(actions.game_set_new_building_id(""))

func _ready():
  store.subscribe(self, "_on_store_changed")

func _set_building_id(state):
  _new_building_id = state["new_building_id"]

  if _new_building_id != "":
    texture = load("res://sprites/buildings/{id}.png".format({"id": _new_building_id}))

func _show():
  visible = true
