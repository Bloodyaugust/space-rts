extends "res://addons/gut/test.gd"

onready var tree := get_tree()

var test_building : Building

func before_each():
  test_building = Building.new()
  test_building.id = "refinery"
  add_child(test_building)
  gut.p("ran setup", 2)

func after_each():
  clear_scene()
  gut.p("ran teardown", 2)
  
func test_assert_building_loads():
  gut.p(test_building, 2)
  yield(test_building, "children_spawned")
  assert_eq(test_building.inputs[0]["amount"], 2)
  assert_eq(test_building.inputs[0]["id"], "ore")
  assert_eq(test_building.spawns[0]["count"], 5)

func test_assert_spawns_actors():
  yield(yield_for(0), YIELD)
  assert_eq(tree.get_nodes_in_group("Drones").size(), 5)

func test_assert_produces_output_when_input_satisfied():
  test_building = Building.new()
  test_building.id = "refinery"
  test_building._ready()
  
  test_building.input_storage.ore = 2

  gut.simulate(test_building, 5, 1)
  gut.p("test_building time_to_production: " + str(test_building.time_to_production))
  assert_eq(test_building.input_storage.ore, 0)
  assert_eq(test_building.output_storage.metal, 1)
