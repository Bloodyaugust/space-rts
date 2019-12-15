extends Node2D
class_name Building

signal children_spawned

export var id: String
export var spawn_range: float

onready var actions = $"/root/actions"
onready var store = $"/root/store"
onready var tree = get_tree()

var auto_build: bool = true
var current_health: int
var current_production: int = 0
var health: int
var input_storage := {}
var output_drones := {}
var output_storage := {}
var producing: bool = false
var production := []
var production_time: int
var root
var spawns := []
var time_to_production: int
var want_to_produce: bool = true

var _data := {}

func get_class():
  return "Building"

func handle_click(viewport, event, shape_index):
  match event.button_mask:
    BUTTON_MASK_LEFT:
      store.dispatch(actions.game_selection(self))

func _process(delta):
  _produce(delta)

func _produce(delta):
  var _producing_entity = production[current_production]

  if !producing && want_to_produce:
    var _all_satisfied: bool = true

    for input in _producing_entity["inputs"]:
      if input_storage[input.id] < input.amount:
        _all_satisfied = false
        break
    
    if _all_satisfied:
      producing = true

      for input in _producing_entity["inputs"]:
        input_storage[input.id] -= input.amount

        _spawn_jobs()

  if producing:
    time_to_production -= delta

    if time_to_production <= 0:
      if !auto_build:
        want_to_produce = false
      producing = false

      time_to_production = production_time
      match _producing_entity.type:
        "resource":
          output_storage[_producing_entity.id] += _producing_entity.amount

          _spawn_jobs()
        "drone":
          _spawn_child(output_drones[production[current_production].id])

func _ready():
  if tree:
    root = tree.get_root()
  
  _data = _load_building()
  _parse_data()
  
  if root:
    call_deferred("_spawn_children")

func _parse_data():
#  Eat the data into a first party data structure
  health = _data["health"]
  current_health = health
  current_production = 0
  production = _data["production"]
  production_time = _data["production"][current_production]["time"]
  spawns = _data["spawns"]

  time_to_production = production_time
  for product in production:
    for input in product["inputs"]:
      input_storage[input.id] = 0
    
    match product.type:
      "resource":
        output_storage[product.id] = 0
      "drone":
        output_drones[product.id] = load("res://actors/Drones/{drone_id}.tscn".format({"drone_id": product.id}))
  
  # if production.size() > 1:
  #   auto_build = false
  #   want_to_produce = false

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
  
  _spawn_jobs()

  emit_signal("children_spawned")

func _spawn_jobs():
  for input in production[current_production]["inputs"]:
    if input.id != "ore":
      for i in range(input.amount):
        var _new_job = Job.new()
        _new_job.type = "unload"
        _new_job.data.id = input.id
        add_child(_new_job)

  for key in output_storage.keys():
    for i in range(output_storage[key]):
      var _new_job = Job.new()
      _new_job.type = "load"
      _new_job.data.id = production[current_production].id
      add_child(_new_job)

func _load_building():
  var file = File.new()
  file.open("res://data/" + id + ".building.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result
