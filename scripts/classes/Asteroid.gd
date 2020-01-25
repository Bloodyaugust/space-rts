extends Node2D
class_name Asteroid

export var jobs_max: int
export(Array, int) var ore_range: Array
export var scale_max: float

var ore: int

func _create_mining_job():
    var _new_job = Job.new()
    _new_job.name = "Job"
    _new_job.type = "mine"
    _new_job.connect("job_completed", self, "_on_job_completed")
  
    add_child(_new_job)
    ore -= 1

func _get_child_jobs():
  var _matching_nodes = []

  for child_node in get_children():
    if child_node.get_class() == "Job":
      _matching_nodes.append(child_node)

  return _matching_nodes

func _on_job_completed():
  if ore > 0:
    _create_mining_job()

  elif _get_child_jobs().size() <= 1:
    queue_free()

func _ready():
  ore = int(rand_range(ore_range[0], ore_range[1]))
  var _ore_coefficient: float = (float(ore) / float(ore_range[1]))
  var _scale_member: float = _ore_coefficient * scale_max
  scale = Vector2(_scale_member, _scale_member)

  var _num_jobs: int = clamp(int(jobs_max * _ore_coefficient), 1, jobs_max)

  for i in range(0, _num_jobs):
    _create_mining_job()
