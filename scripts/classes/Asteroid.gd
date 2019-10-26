extends Node2D
class_name Asteroid

export var jobs_max: int
export(Array, int) var ore_range: Array
export var scale_max: float

var ore: int

func _ready():
  ore = int(rand_range(ore_range[0], ore_range[1]))
  scale = Vector2(ore / ore_range[1], ore / ore_range[1])

  var _num_jobs: int = clamp(int(jobs_max * (ore / ore_range[1])), 1, jobs_max)

  for i in range(0, _num_jobs):
    var _new_job = Job.new()
    _new_job.name = "Job"
    _new_job.type = "mine"
  
    add_child(_new_job)
