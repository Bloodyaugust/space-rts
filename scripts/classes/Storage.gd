extends Node2D
class_name Storage

signal storage_item_stored
signal storage_item_retrieved

export var id: String

var current_storage: Dictionary
var storable_items: Array

var _storable_amount: Dictionary

func retrieve_item(resource_item_id: String)->bool:
  if current_storage.get(resource_item_id, 0) > 0:
    current_storage[resource_item_id] = current_storage[resource_item_id] - 1
    emit_signal("storage_item_retrieved")
    return true
  else:
    return false

func store_item(resource_item_id: String)->bool:
  if current_storage.get(resource_item_id, 0) < _storable_amount.get(resource_item_id, 0):
    current_storage[resource_item_id] = current_storage.get(resource_item_id, 0) + 1
    emit_signal("storage_item_stored")
    return true
  else:
    return false

func _parse_data():
  for _resource_storage_config in DataController.buildings[id]["storage"]:
    _storable_amount[_resource_storage_config.id] = _resource_storage_config.amount
    storable_items.append(_resource_storage_config.id)

func _ready():
  _parse_data()
