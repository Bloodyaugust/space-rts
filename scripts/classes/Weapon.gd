extends Node2D
class_name Weapon

enum WEAPON_STATES {IDLE, COOLDOWN, RELOAD}

export var id: String

onready var tree := get_tree()
onready var root := tree.get_root()

onready var _base_projectile: PackedScene = preload("res://actors/Projectiles/base.tscn")
onready var _parent: Drone = get_parent()
onready var _sprite: Sprite = $Sprite

var clip_size: int
var cooldown: float
var projectile_id: String
var reload: float

var _clip_remaining: int
var _flags: Array
var _time_to_cooldown: float
var _time_to_reload: float
var _weapon_state: int

func get_class():
  return "Weapon"

func fire():
  if _weapon_state == WEAPON_STATES.IDLE:
    var _new_projectile = _base_projectile.instance()

    _new_projectile.id = projectile_id
    _new_projectile.global_position = global_position
    _new_projectile.rotation = global_rotation
    # TODO: Grab this once velocity for Drones is implemented
    # _new_projectile.starting_velocity = _parent.get_velocity()
    _new_projectile.set_team(_parent.team)
    root.add_child(_new_projectile)
    
    _clip_remaining -= 1
    _time_to_cooldown = cooldown

    if _clip_remaining <= 0:
      _time_to_reload = reload

func _on_weapon_set_look(at: Vector2):
  look_at(at)

func _process(delta):
  _time_to_cooldown -= delta
  _time_to_reload -= delta

  if _time_to_cooldown > 0:
    _weapon_state = WEAPON_STATES.COOLDOWN

  if _time_to_reload > 0:
    _weapon_state = WEAPON_STATES.RELOAD

  if _time_to_reload <= 0 && _time_to_cooldown <= 0 && _weapon_state == WEAPON_STATES.RELOAD:
    _clip_remaining = clip_size
    _weapon_state = WEAPON_STATES.IDLE
  if _time_to_reload <= 0 && _time_to_cooldown <= 0 && _weapon_state == WEAPON_STATES.COOLDOWN:
    _weapon_state = WEAPON_STATES.IDLE

func _ready():
  _parse_data()

  _clip_remaining = clip_size
  _weapon_state = WEAPON_STATES.IDLE

  _parent.connect("weapon_fire", self, "fire")

  if _flags.find("turret") != -1:
    _parent.connect("weapon_set_look", self, "_on_weapon_set_look")

func _parse_data():
  var _data: Dictionary = DataController.weapons[id]
#  Eat the data into a first party data structure
  clip_size = _data["clip-size"]
  cooldown = _data["cooldown"]
  _flags = _data["flags"]
  projectile_id = _data["projectile"]
  reload = _data["reload"]

  _sprite.texture = load("res://sprites/weapons/{id}.png".format({"id": id}))
