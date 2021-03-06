extends Drone
class_name CombatDrone

signal weapon_fire
signal weapon_set_look

enum COMBAT_STATES {JOB, ATTACKING}

export var id: String

onready var _weapon_base_scene: PackedScene = preload("res://actors/Weapons/base.tscn")

var fire_interval: float
var fire_range: float
var projectile_id: String
var root
var target_range: float

var _combat_state: int
var _current_target: Node2D
var _time_to_fire: float

var _data := {}

func get_class():
  return "CombatDrone"

func _find_target():
  var _drones = tree.get_nodes_in_group("Drones")
  var _buildings = tree.get_nodes_in_group("Buildings")
  var _possible_targets := []

  for _drone in _drones:
    if _drone.team != team:
      _possible_targets.append(_drone)
  for _building in _buildings:
    if _building.team != team:
      _possible_targets.append(_building)

  if _possible_targets.size() > 0:
    _possible_targets.sort_custom(self, "_sort_targets")
    return _possible_targets[0]
  else:
    return null

func _fire():
  emit_signal("weapon_set_look", _current_target.position)
  emit_signal("weapon_fire")

func _process(delta):
  _time_to_fire -= delta

  match _combat_state:
    COMBAT_STATES.JOB:
      _current_target = _find_target()

      if _current_target != null:
        _combat_state = COMBAT_STATES.ATTACKING

    COMBAT_STATES.ATTACKING:
      if !is_instance_valid(_current_target):
        _combat_state = COMBAT_STATES.JOB
        return null

      if position.distance_to(_current_target.position) >= 250:
        move_towards(_current_target.position)

      if position.distance_to(_current_target.position):
        _fire()

func _ready():
  if tree:
    root = tree.get_root()
  
  _data = _load_combat_drone()
  _parse_data()

  _combat_state = COMBAT_STATES.JOB

func _sort_targets(a, b):
  return a.position.distance_squared_to(position) < b.position.distance_squared_to(position)

func _parse_data():
#  Eat the data into a first party data structure
  health = _data["health"]
  speed = _data["speed"]
  target_range = _data["target-range"]

  for _weapon in _data["weapons"]:
    var _new_weapon = _weapon_base_scene.instance()

    _new_weapon.id = _weapon["id"]

    add_child(_new_weapon)

    _new_weapon.position = Vector2(_weapon["position"][0], _weapon["position"][1])

func _load_combat_drone():
  var file = File.new()
  file.open("res://data/" + id + ".combat-drone.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result
