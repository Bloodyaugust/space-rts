extends Node

var buildings := {}
var combat_drones := {}
var projectiles := {}
var weapons := {}

func _load_actor_data(id: String, type: String):
  var file = File.new()
  file.open("res://data/{id}.{type}.json".format({"id": id, "type": type}), File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result

func _ready():
  var _data_directory = Directory.new()

  if _data_directory.open("res://data") == OK:
    _data_directory.list_dir_begin(true)

    var _file_name: String = _data_directory.get_next()
    while _file_name != "":
      if ".building.json" in _file_name:
        var _building_id: String = _file_name.substr(0, _file_name.find(".building.json"))

        buildings[_building_id] = _load_actor_data(_building_id, "building")

      if ".combat-drone.json" in _file_name:
        var _combat_drone_id: String = _file_name.substr(0, _file_name.find(".combat-drone.json"))

        combat_drones[_combat_drone_id] = _load_actor_data(_combat_drone_id, "combat-drone")

      if ".projectile.json" in _file_name:
        var _projectile_id: String = _file_name.substr(0, _file_name.find(".projectile.json"))

        projectiles[_projectile_id] = _load_actor_data(_projectile_id, "projectile")

      if ".weapon.json" in _file_name:
        var _weapon_id: String = _file_name.substr(0, _file_name.find(".weapon.json"))

        weapons[_weapon_id] = _load_actor_data(_weapon_id, "weapon")

      _file_name = _data_directory.get_next()
