extends Node

onready var actions = get_node('/root/actions')
onready var reducers = get_node('/root/reducers')
onready var store = get_node('/root/store')

onready var _empty_node = Node2D.new()

func _ready():
  store.create([
    {'name': 'game', 'instance': reducers},
    {'name': 'player', 'instance': reducers}
  ], [
    {'name': '_on_store_changed', 'instance': self}
  ])
  store.dispatch(actions.game_set_start_time(OS.get_unix_time()))

func _on_store_changed(name, state):
  print(name, ": ", state)

func _unhandled_input(event):
  if event is InputEventMouseButton and event.button_mask == BUTTON_MASK_LEFT:
    store.dispatch(actions.game_selection(_empty_node))

func _process(_delta):
  if Input.is_action_pressed("ui_cancel"):
    store.dispatch(actions.game_selection(_empty_node))
