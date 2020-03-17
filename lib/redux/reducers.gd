extends Node

onready var types = get_node('/root/action_types')
onready var store = get_node('/root/store')

func game(state, action):
  if action['type'] == action_types.GAME_SET_NEW_BUILDING_ID:
    var next_state = store.shallow_copy(state)
    next_state['new_building_id'] = action['id']
    return next_state
  if action['type'] == action_types.GAME_SET_START_TIME:
    var next_state = store.shallow_copy(state)
    next_state['start_time'] = action['time']
    return next_state
  if action['type'] == action_types.GAME_SELECTION:
    var next_state = store.shallow_copy(state)
    next_state['selection'] = action['node']
    return next_state
  return state

func player(state, action):
  if action['type'] == types.PLAYER_ADD_RESOURCE_COUNT:
    var next_state = store.shallow_copy(state)
    next_state['resources'][action['resource_id']] += action['amount']
    return next_state
  return state
