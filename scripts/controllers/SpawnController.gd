extends Node

signal wave_spawned

enum SPAWN_DIFFICULTIES {EASY, MEDIUM, HARD}

export var _enabled: bool
export(Array, int) var spawn_difficulty_thresholds: Array
export var spawn_interval: float
export var spawn_radius: float

onready var tree = get_tree()
onready var root = tree.get_root()

var waves := {}
var spawn_points: Array

var _current_difficulty: int = SPAWN_DIFFICULTIES.EASY
var _drone_scene := preload("res://actors/Drones/combat-drone-base.tscn")
var _game_time_elapsed: float = 0
var _time_to_wave: float

var _data := {}

func _process(delta):
  if _enabled:
    _game_time_elapsed += delta
    _time_to_wave -= delta

    _current_difficulty = SPAWN_DIFFICULTIES.EASY
    if _game_time_elapsed >= spawn_difficulty_thresholds[SPAWN_DIFFICULTIES.MEDIUM]:
      _current_difficulty = SPAWN_DIFFICULTIES.MEDIUM
    if _game_time_elapsed >= spawn_difficulty_thresholds[SPAWN_DIFFICULTIES.HARD]:
      _current_difficulty = SPAWN_DIFFICULTIES.HARD

    if _time_to_wave <= 0:
      var _current_wave_set = waves[str(_current_difficulty)]
      var _selected_wave = _current_wave_set[randi() % _current_wave_set.size()]
      var _selected_spawn_point = spawn_points[randi() % spawn_points.size()]
      
      for _enemy_id in _selected_wave:
        var _new_drone = _drone_scene.instance()

        _new_drone.position = _selected_spawn_point.position + Vector2(rand_range(-spawn_radius, spawn_radius), rand_range(-spawn_radius, spawn_radius))
        _new_drone.id = _enemy_id
        _new_drone.team = 1

        root.add_child(_new_drone)
      
      _time_to_wave = spawn_interval
      emit_signal("wave_spawned")

func _ready():
  _data = _load_waves()

  _parse_data()

  spawn_points = tree.get_nodes_in_group("SpawnPoints")
  _time_to_wave = spawn_interval

func _parse_data():
#  Eat the data into a first party data structure
  waves = _data

func _load_waves():
  var file = File.new()
  file.open("res://data/waves.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result
