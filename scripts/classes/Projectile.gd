extends Node2D
class_name Projectile

export var id: String

onready var actions = $"/root/actions"
onready var store = $"/root/store"
onready var tree = get_tree()

var current_health: int
var damage: int
var health: int
var flags := []
var speed: int

var _data := {}

func get_class():
  return "Projectile"

func _ready():
  _data = _load_projectile()
  _parse_data()

func _parse_data():
#  Eat the data into a first party data structure
  damage = _data["damage"]
  health = _data["health"]
  flags = _data["flags"]
  speed = _data["speed"]

  current_health = health

func _load_projectile():
  var file = File.new()
  file.open("res://data/" + id + ".projectile.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result
