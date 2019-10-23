extends "res://addons/gut/test.gd"

onready var tree := get_tree()

var test_job : Job

func before_each():
  test_job = Job.new()
  watch_signals(test_job)
  test_job._ready()
  gut.p("ran setup", 2)

func after_each():
  clear_scene()
  gut.p("ran teardown", 2)
  
func test_assert_job_provider_initializes():
  assert_signal_emitted(test_job, "job_available")
  assert_eq(test_job.claimant, null)
  assert_eq(test_job.state, Job.JOB_STATES.AVAILABLE)
  assert_eq(test_job.completion, 0)

func test_assert_job_provider_claims():
  var _claimant = {}
  test_job.claim(_claimant)

  assert_signal_emitted(test_job, "job_claimed")
  assert_eq(test_job.claimant, _claimant)
  assert_eq(test_job.state, Job.JOB_STATES.CLAIMED)

func test_assert_job_provider_progresses():
  test_job.do_progress(0.1)

  assert_signal_emitted(test_job, "job_in_progress")
  assert_eq(test_job.completion, 0.1)
  assert_eq(test_job.state, Job.JOB_STATES.IN_PROGRESS)

  test_job.do_progress(0.9)
  assert_eq(test_job.completion, 1)
  assert_eq(test_job.state, Job.JOB_STATES.COMPLETE)
  assert_signal_emit_count(test_job, "job_progressed", 1)
  assert_signal_emitted(test_job, "job_completed")

