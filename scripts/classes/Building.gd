extends Node2D
class_name Building

export var id: String

var inputs := []
var output := {}
var production_time: int

#{
#  "id": "refinery",
#  "production": {
#    "inputs": [
#      {
#        "id": "ore",
#        "amount": 2
#      }
#    ],
#    "output": {
#      "id": "metal",
#      "amount": 1
#    },
#    "time": 5
#  }
#}
var _data := {}

func _ready():
  _data = _load_building()
  _parse_data()

func _parse_data():
#  Eat the data into a first party data structure
  inputs = _data["production"]["inputs"]
  output = _data["production"]["output"]
  production_time = _data["production"]["time"]

func _load_building():
  var file = File.new()
  file.open("res://data/" + id + ".building.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result
