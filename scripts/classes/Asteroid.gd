extends Node2D
class_name Asteroid

export var jobs_max: int
export(Array, int) var ore_range: Array
export var scale_max: float

var ore: int

func _ready():
  ore = int(rand_range(ore_range[0], ore_range[1]))
  var _ore_coefficient: float = (float(ore) / float(ore_range[1]))
  var _scale_member: float = _ore_coefficient * scale_max
  scale = Vector2(_scale_member, _scale_member)

  var _num_jobs: int = clamp(int(jobs_max * _ore_coefficient), 1, jobs_max)

  for i in range(0, _num_jobs):
    var _new_job = Job.new()
    _new_job.name = "Job"
    _new_job.type = "mine"
  
    add_child(_new_job)
