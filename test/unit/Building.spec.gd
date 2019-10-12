extends "res://addons/gut/test.gd"

var test_building : Building

func before_each():
  test_building = Building.new()
  test_building.id = "refinery"
  gut.p("ran setup", 2)

func after_each():
  gut.p("ran teardown", 2)
  
func test_assert_building_loads():
  test_building._ready()
  gut.p(test_building, 2)
  assert_not_null(test_building.inputs[0])