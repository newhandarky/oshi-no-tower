extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const RunStateScript := preload("res://scripts/core/RunState.gd")

var database = RuntimeDatabaseScript.new()
var run_state = RunStateScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_random_run_initializes_active_map()
	_test_only_available_nodes_can_be_entered()
	_test_completing_node_advances_available_nodes()
	_test_fixed_route_start_remains_available_for_fallback()

	if failures.is_empty():
		print("run_state_random_map_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("run_state_random_map_tests: failed (%d)" % failures.size())
		quit(1)

func _test_random_run_initializes_active_map() -> void:
	run_state.start_random_run(database, "subaru", 20260509)

	_expect_eq(run_state.character_id, "subaru", "random run 必須保留角色")
	_expect_eq(run_state.map_seed, 20260509, "random run 必須保存 seed")
	_expect_false(run_state.active_map.is_empty(), "random run 必須建立 active_map")
	_expect_eq(run_state.current_node_id, "start", "random run 起點必須是 start")
	_expect_true(run_state.available_node_ids.size() > 0, "random run 起點後必須有可到達節點")
	_expect_eq(run_state.visited_node_ids.size(), 0, "random run 開始時尚未拜訪任何節點")

func _test_only_available_nodes_can_be_entered() -> void:
	run_state.start_random_run(database, "subaru", 20260509)
	var available_id := str(run_state.available_node_ids[0])
	var unavailable_id := ""
	for node in run_state.active_map["nodes"]:
		var node_id := str(node["id"])
		if node_id != "start" and not run_state.available_node_ids.has(node_id):
			unavailable_id = node_id
			break

	_expect_true(run_state.can_enter_node(available_id), "可到達節點必須可進入")
	_expect_false(run_state.can_enter_node(unavailable_id), "不可到達節點不可進入")
	_expect_false(run_state.set_current_node(unavailable_id), "不可到達節點不可設為目前節點")
	_expect_true(run_state.set_current_node(available_id), "可到達節點可設為目前節點")
	_expect_eq(run_state.current_node_id, available_id, "目前節點必須更新為選取節點")

func _test_completing_node_advances_available_nodes() -> void:
	run_state.start_random_run(database, "subaru", 20260509)
	var first_id := str(run_state.available_node_ids[0])
	var first_node: Dictionary = run_state.get_node_by_id(first_id)
	var expected_next: Array[String] = []
	for outgoing_id in first_node.get("outgoing", []):
		expected_next.append(str(outgoing_id))

	run_state.set_current_node(first_id)
	run_state.complete_current_node(database)

	_expect_true(run_state.visited_node_ids.has(first_id), "完成節點後必須記錄 visited")
	_expect_eq(var_to_str(run_state.available_node_ids), var_to_str(expected_next), "完成節點後 available 必須等於 outgoing")

func _test_fixed_route_start_remains_available_for_fallback() -> void:
	run_state.start_run(database, "botan")

	_expect_true(run_state.active_map.is_empty(), "固定 fallback start_run 不應建立 active_map")
	_expect_eq(run_state.current_node_index, 0, "固定 fallback 必須保留 current_node_index")
	_expect_eq(run_state.character_id, "botan", "固定 fallback 必須保留角色")

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
