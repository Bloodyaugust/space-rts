extends Node2D
class_name Asteroid

export(Array, int) var ore_range: Array

var ore: int

func _ready():
  ore = int(rand_range(ore_range[0], ore_range[1]))

  var _new_job = Job.new()
  _new_job.name = "Job"
  _new_job.type = "mine"

  add_child(_new_job)

  
