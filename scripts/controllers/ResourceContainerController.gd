extends Control

onready var _store = $"/root/store"

onready var _drones_label: Label = $"./PanelContainer/ResourceItems/resource-item-drones/Label"
onready var _metal_label: Label = $"./PanelContainer/ResourceItems/resource-item-metal/Label"
onready var _ore_label: Label = $"./PanelContainer/ResourceItems/resource-item-ore/Label"

var _player_resources_state := {
  "drones": 0,
  "metal": 0,
  "ore": 0
}

func _on_store_changed(name, state):
  match name:
    "player":
      _player_resources_state = state["resources"]
      _update_screen()

func _ready():
  store.subscribe(self, "_on_store_changed")

func _update_screen():
  _drones_label.text = str(_player_resources_state["drones"])
  _metal_label.text = str(_player_resources_state["metal"])
  _ore_label.text = str(_player_resources_state["ore"])
