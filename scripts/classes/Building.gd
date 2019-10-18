extends Node2D
class_name Building

signal children_spawned

export var id: String

onready var root = get_tree().get_root()

var inputs := []
var output := {}
var production_time: int
var spawns := []

# {
#   "id": "refinery",
#   "spawns": [
#     {
#       "id": "mining-drone",
#       "count": 5
#     }
#   ],
#   "production": {
#     "inputs": [
#       {
#         "id": "ore",
#         "amount": 2
#       }
#     ],
#     "output": {
#       "id": "metal",
#       "amount": 1
#     },
#     "time": 5
#   }
# }
var _data := {}

func _ready():
  _data = _load_building()
  _parse_data()
  call_deferred("_spawn_children")

func _parse_data():
#  Eat the data into a first party data structure
  inputs = _data["production"]["inputs"]
  output = _data["production"]["output"]
  production_time = _data["production"]["time"]
  spawns = _data["spawns"]

func _spawn_children():
  for spawn_definition in spawns:
    var actor_packed_scene := load("res://actors/" + spawn_definition["id"] + ".tscn")
    var new_actor

    for i in range(spawn_definition["count"]):
      new_actor = actor_packed_scene.instance()
      new_actor.position = position

      root.add_child(new_actor)

  emit_signal("children_spawned")

func _load_building():
  var file = File.new()
  file.open("res://data/" + id + ".building.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result
