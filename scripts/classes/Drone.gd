extends Node2D
class_name Drone

signal drone_destroyed
signal drone_idle
signal drone_moving
signal drone_working

enum DRONE_STATES {IDLE, MOVING, WORKING, DESTROYED}

export var health: float
export var job_range: float
export var job_type: String
export var speed: float

onready var tree = get_tree()

var job: Job
var state: int

func damage(amount: float):
  health -= amount

  if health <= 0:
    state = DRONE_STATES.DESTROYED
    emit_signal("drone_destroyed")

func do_idle():
  state = DRONE_STATES.IDLE
  emit_signal("drone_idle")

func do_job_progress(amount: float):
  if state != DRONE_STATES.WORKING:
    state = DRONE_STATES.WORKING
    emit_signal("drone_working")

  job.do_progress(amount)

func find_job():
  var _jobs: Array = tree.get_nodes_in_group("Jobs")
  var _possible_jobs: Array = []

  for testing_job in _jobs:
    if testing_job.type == job_type && position.distance_to(testing_job.position) <= job_range:
      _possible_jobs.append(testing_job)

  _possible_jobs.sort_custom(self, "_sort_jobs")

  job = _possible_jobs[0]

func move_towards(point: Vector2):
  var _direction_vector: Vector2 = (point - position).normalized()

  if state != DRONE_STATES.MOVING:
    state = DRONE_STATES.MOVING
    emit_signal("drone_moving")

  if point.distance_to(position) <= speed:
    position = point
    do_idle()
  else:
    global_translate(_direction_vector * speed * get_process_delta_time())

func _ready():
  do_idle()

func _sort_jobs(a, b):
  return a.position.distance_squared_to(position) < b.position.distance_squared_to(position)