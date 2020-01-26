extends Node2D
class_name Drone

signal damage
signal drone_arrived
signal drone_destroyed
signal drone_idle
signal drone_job_assigned
signal drone_job_completed
signal drone_moving
signal drone_working

enum DRONE_STATES {IDLE, MOVING, WORKING, DESTROYED}

export var health: float
export var job_range: float
export var job_type_string: String
export var speed: float
export var team: int

onready var tree = get_tree()

var job: Job
var job_types: Array
var state: int

func do_idle():
  if is_instance_valid(job):
    job.unclaim()
    job.disconnect("job_completed", self, "_on_job_completed")
  
  job = null
  
  state = DRONE_STATES.IDLE
  emit_signal("drone_idle")

func do_job_progress(amount: float):
  if state != DRONE_STATES.WORKING:
    state = DRONE_STATES.WORKING
    emit_signal("drone_working")

  job.do_progress(amount)

func find_job(job_type = "", job_data_id = ""):
  var _jobs: Array = tree.get_nodes_in_group("Jobs")
  var _possible_jobs: Array = []
  var _possible_job_types: Array = []

  if job_type != "":
    _possible_job_types = [job_type]
  else:
    _possible_job_types = job_types

  for testing_job in _jobs:
    if _possible_job_types.has(testing_job.type) && position.distance_to(testing_job.position) <= job_range && testing_job.state == Job.JOB_STATES.AVAILABLE:
      if job_data_id != "":
        if testing_job.data.id == job_data_id:
          _possible_jobs.append(testing_job)
      else:
        _possible_jobs.append(testing_job)

  if _possible_jobs.size() > 0:
    _possible_jobs.sort_custom(self, "_sort_jobs")
    job = _possible_jobs[0]

    job.claim(self)
    job.connect("job_completed", self, "_on_job_completed")
    emit_signal("drone_job_assigned")
  else:
    do_idle()

func move_towards(point: Vector2):
  var _direction_vector: Vector2 = (point - position).normalized()

  if state != DRONE_STATES.MOVING:
    state = DRONE_STATES.MOVING
    emit_signal("drone_moving")

  if point.distance_to(position) <= speed * get_process_delta_time():
    position = point
    emit_signal("drone_arrived")
  else:
    look_at(position + _direction_vector)
    global_translate(_direction_vector * speed * get_process_delta_time())

func _exit_tree():
  store.dispatch(actions.player_add_resource_count("drones", -1))

func _on_damage(amount):
  health -= amount
  
  if health <= 0:
    do_idle()
    state = DRONE_STATES.DESTROYED
    emit_signal("drone_destroyed")
    queue_free()

func _on_job_completed():
  emit_signal("drone_job_completed")
  do_idle()

func _ready():
  job_types = Array(job_type_string.split(","))

  do_idle()

  connect("damage", self, "_on_damage")

func _sort_jobs(a, b):
  return a.position.distance_squared_to(position) < b.position.distance_squared_to(position)