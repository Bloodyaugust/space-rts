extends "res://addons/gut/test.gd"

onready var tree := get_tree()

var test_asteroid : Asteroid

func before_each():
  test_asteroid = Asteroid.new()
  test_asteroid.ore_range = [100, 200]
  add_child(test_asteroid)
  gut.p("ran setup", 2)

func after_each():
  clear_scene()
  gut.p("ran teardown", 2)
  
func test_assert_asteroid_initializes():
  gut.p(test_asteroid, 2)
  yield(yield_for(0), YIELD)

  assert_gt(test_asteroid.ore, 99)

  var _asteroid_job = test_asteroid.get_node_or_null("Job")
  assert_not_null(_asteroid_job)
  assert_eq(_asteroid_job.type, "mine")
