extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_balance_playtest_prep_doc_exists()

	if failures.is_empty():
		print("production_docs_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("production_docs_tests: failed (%d)" % failures.size())
		quit(1)

func _test_balance_playtest_prep_doc_exists() -> void:
	var path := "res://docs/production/balance-playtest-prep.md"
	_expect_true(FileAccess.file_exists(path), "009 需要 balance / playtest prep 文件入口")
	if not FileAccess.file_exists(path):
		return
	var content := FileAccess.get_file_as_string(path)
	_expect_true(content.contains("Subaru 5/10"), "prep 文件需記錄 Subaru 目前 multiseed guardrail")
	_expect_true(content.contains("Botan 7/10"), "prep 文件需記錄 Botan 目前 multiseed guardrail")
	_expect_true(content.contains("AZKi 5/10"), "prep 文件需記錄 AZKi 目前 multiseed guardrail")
	_expect_true(content.contains("manual full-run"), "prep 文件需明確銜接 manual full-run gate")
	_expect_true(content.contains("不做 GUI/manual QA"), "prep 文件需明確本輪不代替 manual QA")

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)
