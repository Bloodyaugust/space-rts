extends Node2D
class_name Building

signal children_spawned

export var id: String
export var spawn_range: float

onready var tree = get_tree()

var inputs := []
var input_storage := {}
var output := {}
var output_drone
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

        if input.id != "ore":
          for i in range(input.amount):
            var _new_job = Job.new()
            _new_job.type = "unload"
            _new_job.data.id = input.id
            add_child(_new_job)

  if producing:
    time_to_production -= delta

    if time_to_production <= 0:
      producing = false
      match output.type:
        "resource":
          output_storage[output.id] += output.amount

          if output.type == "resource" && output.id != "ore":
            for i in range(output.amount):
              var _new_job = Job.new()
              _new_job.type = "load"
              _new_job.data.id = output.id
              add_child(_new_job)
        "drone":
          _spawn_child(output_drone)

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
  match output.type:
    "resource":
      output_storage = {output.id: 0}
    "drone":
      print("res://actors/Drones/{drone_id}.tscn".format({"drone_id": output.id}))
      output_drone = load("res://actors/Drones/{drone_id}.tscn".format({"drone_id": output.id}))

func _spawn_child(scene):
  var new_actor = scene.instance()
  new_actor.position = position + Vector2(rand_range(-spawn_range / 2, spawn_range / 2), rand_range(-spawn_range / 2, spawn_range / 2))

  if "parent_building" in new_actor:
    new_actor.parent_building = self

  root.add_child(new_actor)

func _spawn_children():
  for spawn_definition in spawns:
    var actor_packed_scene := load("res://actors/Drones/" + spawn_definition["id"] + ".tscn")

    for i in range(spawn_definition["count"]):
      _spawn_child(actor_packed_scene)

  for input in inputs:
    if input.id != "ore":
      for i in range(input.amount):
        var _new_job = Job.new()
        _new_job.type = "unload"
        _new_job.data.id = input.id
        add_child(_new_job)
  
  emit_signal("children_spawned")

func _load_building():
  var file = File.new()
  file.open("res://data/" + id + ".building.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result
