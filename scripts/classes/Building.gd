extends Node2D
class_name Building

signal children_spawned

export var id: String

onready var tree = get_tree()

var inputs := []
var input_storage := {}
var output := {}
var output_storage := {}
var producing: bool = false
var production_time: int
var root
var spawns := []
var time_to_production: int

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

func _process(delta):
  _produce(delta)

func _produce(delta):
  if !producing:
    var _all_satisfied: bool = true

    for input in inputs:
      if input_storage[input.id] < input.amount:
        _all_satisfied = false
        break
    
    if _all_satisfied:
      producing = true
      time_to_production = production_time

      for input in inputs:
        input_storage[input.id] -= input.amount

  if producing:
    time_to_production -= delta

    if time_to_production <= 0:
      producing = false
      output_storage[output.id] += output.amount
      
func _ready():
  if tree:
    root = tree.get_root()
  
  _data = _load_building()
  _parse_data()
  
  if root:
    call_deferred("_spawn_children")

func _parse_data():
#  Eat the data into a first party data structure
  inputs = _data["production"]["inputs"]
  output = _data["production"]["output"]
  production_time = _data["production"]["time"]
  spawns = _data["spawns"]

  time_to_production = production_time
  for input in inputs:
    input_storage[input.id] = 0
  output_storage = {output.id: 0}

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
