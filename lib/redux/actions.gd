extends Node

onready var types = get_node('/root/action_types')

func game_set_start_time(time):
  return {
    'type': types.GAME_SET_START_TIME,
    'time': time
  }

func game_selection(node):
  return {
    'type': types.GAME_SELECTION,
    'node': node
  }

func player_add_resource_count(resource_id, amount):
  return {
    'type': types.PLAYER_ADD_RESOURCE_COUNT,
    'resource_id': resource_id,
    'amount': amount
  }
