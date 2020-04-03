extends Node2D
class_name BuildingGhost

export var id: String

onready var tree = get_tree()

onready var _area_rect_collider: PackedScene = preload("res://doodads/area_rect_collider.tscn")

var input_storage := {}
var required_inputs := {}

var _building_scene: PackedScene

var _data := {}

func get_class():
  return "BuildingGhost"

func handle_click(_viewport, event, _shape_index):
  match event.button_mask:
    BUTTON_MASK_LEFT:
      store.dispatch(actions.game_selection(self))

func _exit_tree():
  if store.state()["game"]["selection"] == self:
    store.dispatch(actions.game_selection(Node2D.new()))

  for _resource_id in input_storage.keys():
    if input_storage[_resource_id] > 0:
      store.dispatch(actions.player_add_resource_count(_resource_id, -input_storage[_resource_id]))

func _on_job_after_completed():
  var _completed = true

  for _resource_id in required_inputs.keys():
    if input_storage[_resource_id] < required_inputs[_resource_id]:
      _completed = false
      break
  
  if _completed:
    _spawn_building()
    queue_free()

func _ready():
  _building_scene = load("res://actors/Buildings/" + id + ".tscn")
  
  _data = _load_building()
  _parse_data()
  call_deferred("_spawn_children")
  call_deferred("_spawn_jobs")

func _parse_data():
#  Eat the data into a first party data structure
  for _resource_id in _data["cost"].keys():
    required_inputs[_resource_id] = _data["cost"][_resource_id]
    input_storage[_resource_id] = 0

func _spawn_building():
  var _new_building = _building_scene.instance()

  _new_building.position = position
  _new_building.team = 0

  tree.get_root().add_child(_new_building)

func _spawn_children():
  var _new_collider: Area2D = _area_rect_collider.instance()
  var _new_sprite: Sprite = Sprite.new()

  _new_sprite.texture = load("res://sprites/buildings/" + id + ".png")
  _new_sprite.modulate = Color(0.584314, 0.568627, 1, 0.392157)

  _new_collider.get_node("CollisionShape2D").shape.extents = Vector2(_new_sprite.texture.get_size().x / 2, _new_sprite.texture.get_size().y / 2)
  _new_collider.connect("input_event", self, "handle_click")

  self.add_child(_new_sprite)
  self.add_child(_new_collider)

func _spawn_jobs():
  for _resource_id in required_inputs.keys():
    for _i in required_inputs[_resource_id]:
      var _new_job = Job.new()

      _new_job.type = "unload"
      _new_job.data.id = _resource_id
      _new_job.connect("job_after_completed", self, "_on_job_after_completed")
      self.add_child(_new_job)

func _load_building():
  var file = File.new()
  file.open("res://data/" + id + ".building.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result

func get_building_progress()->float:
  var _current: float = 0
  var _required: float = 0

  for _required_value in required_inputs.values():
    _required += _required_value

  for _stored_value in input_storage.values():
    _current += _stored_value

  return _current / _required
