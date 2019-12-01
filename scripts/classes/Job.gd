extends Node2D
class_name Job

export var type: String

signal job_available
signal job_claimed
signal job_completed
signal job_in_progress
signal job_progressed

enum JOB_STATES {AVAILABLE, CLAIMED, IN_PROGRESS, COMPLETE}

var claimant
var completion: float
var data := {}
var state: int

func claim(actor):
  claimant = actor
  state = JOB_STATES.CLAIMED
  emit_signal("job_claimed")

func do_progress(amount: float):
  completion += amount

  if state != JOB_STATES.IN_PROGRESS:
    state = JOB_STATES.IN_PROGRESS
    emit_signal("job_in_progress")

  if completion >= 1:
    state = JOB_STATES.COMPLETE
    emit_signal("job_completed")
  else:
    emit_signal("job_progressed")

func unclaim():
  claimant = null
  if state != JOB_STATES.COMPLETE:
    state = JOB_STATES.AVAILABLE
    emit_signal("job_available")

func _ready():
  add_to_group("Jobs")
  unclaim()
