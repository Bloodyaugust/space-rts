extends Drone
class_name TransportDrone

enum TRANSPORT_STATES {LOAD, UNLOAD}

# job_types[0]: "load"
# job_types[1]: "unload"

export var load_unload_rate: float

var _current_id: String
var _transport_state: int
var _storage := {}

func _exit_tree():
  for _resource_id in _storage.keys():
    if _storage[_resource_id] > 0:
      store.dispatch(actions.player_add_resource_count(_resource_id, -_storage[_resource_id]))

func _on_drone_idle():
  pass

func _on_drone_arrived():
  do_job_progress(0)

func _on_drone_job_assigned():
  if _transport_state == TRANSPORT_STATES.LOAD:
    _current_id = job.data.id
    _storage[_current_id] = 0

func _on_drone_job_completed():
  if _transport_state == TRANSPORT_STATES.LOAD:
    job.get_parent().output_storage[_current_id] -= 1
    _storage[_current_id] += 1
    _transport_state = TRANSPORT_STATES.UNLOAD
  else:
    job.get_parent().input_storage[_current_id] += 1
    _storage[_current_id] -= 1
    _transport_state = TRANSPORT_STATES.LOAD

func _process(delta):
  if _transport_state == TRANSPORT_STATES.LOAD:
    if !is_instance_valid(job):
      find_job(job_types[0])

    if is_instance_valid(job):
      if state == Drone.DRONE_STATES.IDLE || state == Drone.DRONE_STATES.MOVING:
        move_towards(job.global_position)
        
      if state == Drone.DRONE_STATES.WORKING:
        do_job_progress(load_unload_rate * delta)

  if _transport_state == TRANSPORT_STATES.UNLOAD:
    if !is_instance_valid(job):
      find_job(job_types[1], _current_id)

    if is_instance_valid(job):
      if state == Drone.DRONE_STATES.IDLE || state == Drone.DRONE_STATES.MOVING:
        move_towards(job.global_position)
        
      if state == Drone.DRONE_STATES.WORKING:
        do_job_progress(load_unload_rate * delta)

func _ready():
  _transport_state = TRANSPORT_STATES.LOAD

  connect("drone_arrived", self, "_on_drone_arrived")
  connect("drone_idle", self, "_on_drone_idle")
  connect("drone_job_assigned", self, "_on_drone_job_assigned")
  connect("drone_job_completed", self, "_on_drone_job_completed")
