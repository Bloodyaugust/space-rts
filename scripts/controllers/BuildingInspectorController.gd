extends Control

onready var _store = $"/root/store"

onready var _buildingName: Label = $"./BuildingContent/BuildingStatus/BuildingName"

var _active = false

func _hide():
  _active = false
  visible = false

func _on_store_changed(name, state):
  match name:
    "game":
      print("Got game state change: ", state)
      if state["selection"].get_class() == "Building":
        if _active == false:
          _show()
        
        var _building = state["selection"]

        _buildingName.text = _building.id
      else:
        if _active == true:
          _hide()

func _ready():
  store.subscribe(self, "_on_store_changed")

func _show():
  _active = true
  visible = true
