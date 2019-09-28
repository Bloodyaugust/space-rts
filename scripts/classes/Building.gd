extends Node2D
class_name Building

export var id: String

#{
#  "id": "refinery",
#  "productiion": {
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
  
func _parse_data():
#  Eat the data into a first party data structure
    
func _load_building():
  var file = File.new()
  file.open("res://data/" + id + ".building.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result