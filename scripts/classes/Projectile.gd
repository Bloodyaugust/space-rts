extends Node2D
class_name Projectile

export var id: String

onready var tree = get_tree()

onready var _area2d: Area2D = $Area2D
onready var _capsule: CapsuleShape2D = $"Area2D/CollisionShape2D".shape
onready var _sprite: Sprite = $Sprite

var current_health: int
var damage: int
var health: int
var flags := []
var speed: int
var team: int

func get_class():
  return "Projectile"

func set_direction(new_direction: Vector2):
  match flags:
    ["ballistic", ..]:
      look_at(position + new_direction)

func set_team(new_team: int)->void:
  call_deferred("_set_team")

func _on_area_entered(entering_area):
  var entering_parent = entering_area.get_parent()

  if entering_parent.team != team:
    entering_parent.emit_signal("damage", damage)
    queue_free()

func _ready():
  _parse_data()

  _sprite.texture = load("res://sprites/projectiles/{id}.png".format({"id": id}))

  var _sprite_size: Vector2 = _sprite.texture.get_size()

  _capsule.height = _sprite_size.x / 3
  _capsule.radius = _sprite_size.y / 2

  _area2d.connect("area_entered", self, "_on_area_entered")

func _physics_process(delta):
  var movement_vector = Vector2(1, 0).rotated(rotation) * speed * delta

  match flags:
    ["ballistic", ..]:
      position += movement_vector

func _parse_data():
  var _data: Dictionary = DataController.projectiles[id]
#  Eat the data into a first party data structure
  damage = _data["damage"]
  health = _data["health"]
  flags = _data["flags"]
  speed = _data["speed"]

  current_health = health

func _set_team(new_team: int)->void:
  _area2d.set_collision_layer_bit(team, false)
  _area2d.set_collision_mask_bit(team, true)

  team = new_team

  _area2d.set_collision_layer_bit(team, true)
  _area2d.set_collision_mask_bit(team, false)
