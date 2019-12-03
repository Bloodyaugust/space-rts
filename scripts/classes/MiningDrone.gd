extends Drone
class_name MiningDrone

enum MINING_STATES {JOB, RETURN_MATERIALS}

export var mining_range: float
export var mining_rate: float

var parent_building: Building

var _mining_state: int
var _move_target: Vector2
var _ore_storage: int

func _on_drone_idle():
  pass

func _on_drone_arrived():
  if _mining_state == MINING_STATES.JOB:
    do_job_progress(0)

  if _mining_state == MINING_STATES.RETURN_MATERIALS:
    parent_building.input_storage["ore"] += _ore_storage
    _ore_storage = 0
    _mining_state = MINING_STATES.JOB

func _on_drone_job_assigned():
  _move_target = _randomized_move_target()
  _mining_state = MINING_STATES.JOB

  job.connect("job_completed", self, "_on_job_completed")

func _on_job_completed():
  _ore_storage = 1
  _mining_state = MINING_STATES.RETURN_MATERIALS

  job.disconnect("job_completed", self, "_on_job_completed")
  ._on_job_completed()

func _process(delta):
  if _mining_state == MINING_STATES.JOB:
    if job == null:
      find_job()

    if job != null:
      if state == Drone.DRONE_STATES.IDLE || state == Drone.DRONE_STATES.MOVING:
        move_towards(_move_target)
        
      if state == Drone.DRONE_STATES.WORKING:
        do_job_progress(mining_rate * delta)

  if _mining_state == MINING_STATES.RETURN_MATERIALS:
    var _buildings = tree.get_nodes_in_group("Buildings")
    var _refineries := []

    for _building in _buildings:
      if _building.id == "refinery":
        _refineries.append(_building)

    if _refineries.size() > 0:
      _refineries.sort_custom(self, "_sort_refineries")
      move_towards(_refineries[0].position)
    
func _randomized_move_target():
  return job.global_position + (Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * mining_range)

func _ready():
  _ore_storage = 0
  _mining_state = MINING_STATES.JOB

  connect("drone_arrived", self, "_on_drone_arrived")
  connect("drone_idle", self, "_on_drone_idle")
  connect("drone_job_assigned", self, "_on_drone_job_assigned")

func _sort_refineries(a, b):
  return a.position.distance_squared_to(position) < b.position.distance_squared_to(position)