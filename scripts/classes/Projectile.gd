extends Node2D
class_name Projectile

export var id: String

onready var tree = get_tree()

var current_health: int
var damage: int
var direction_vector: Vector2
var health: int
var flags := []
var speed: int
var team: int

var _data := {}

func get_class():
  return "Projectile"

func set_direction(new_direction: Vector2):
  direction_vector = new_direction

  match flags:
    ["ballistic", ..]:
      look_at(position + direction_vector)

func _on_area_entered(entering_area):
  var entering_parent = entering_area.get_parent()

  if entering_parent.team != team:
    entering_parent.emit_signal("damage", damage)
    queue_free()

func _ready():
  _data = _load_projectile()
  _parse_data()

  $Area2D.connect("area_entered", self, "_on_area_entered")

func _physics_process(delta):
  var movement_vector = direction_vector * speed * delta

  match flags:
    ["ballistic", ..]:
      position += movement_vector

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
