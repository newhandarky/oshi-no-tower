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
	_expect_true(content.contains("Subaru 6/10"), "prep 文件需記錄 Subaru 目前 multiseed guardrail")
	_expect_true(content.contains("Botan 7/10"), "prep 文件需記錄 Botan 目前 multiseed guardrail")
	_expect_true(content.contains("AZKi 7/10"), "prep 文件需記錄 AZKi 目前 multiseed guardrail")
	_expect_true(content.contains("manual full-run"), "prep 文件需明確銜接 manual full-run gate")
	_expect_true(content.contains("不做 GUI/manual QA"), "prep 文件需明確本輪不代替 manual QA")
	_expect_true(content.contains("QA 回報摘要"), "prep 文件需記錄 010 後結算畫面的 manual QA 摘要")
	_expect_true(content.contains("體感問題"), "prep 文件需提醒使用者補充自動摘要無法知道的體感問題")
	_expect_true(content.contains("qa_report"), "prep 文件需記錄 011 後 headless log 的 QA report 欄位")
	_expect_true(content.contains("主要 deck/relic"), "prep 文件需記錄 012 後結算畫面的中文 deck/relic 摘要")
	_expect_true(content.contains("CombatHoverPreview"), "prep 文件需記錄 012 後手牌 hover preview 規則")
	_expect_true(content.contains("Laplus 在敵方回合倒下後"), "prep 文件需記錄 012 後 Laplus 復活手測重點")
	_expect_true(content.contains("multiseed_balance_probe_failure_cases"), "prep 文件需記錄 013 後 multiseed 失敗案例分群輸出")
	_expect_true(content.contains("multiseed_balance_probe_failure_analysis"), "prep 文件需記錄 014 後 multiseed 失敗分析輸出")
	_expect_true(content.contains("likely_issues"), "prep 文件需記錄 014 後 failure analysis 的 likely_issues")
	_expect_true(content.contains("ssrb-giant-camouflage"), "prep 文件需記錄 015 後 AZKi boss repeated pattern guard")
	_expect_true(content.contains("ssrb-debuff-check"), "prep 文件需記錄 015 後 Subaru 中段 repeated pattern guard")
	_expect_true(content.contains("能量過多感"), "prep 文件需記錄 015 後 Subaru 能量體感手測重點")
	_expect_true(content.contains("不要在沒有玩家新回報時大幅調整敵人或 Botan"), "prep 文件需保護 013 後下一步不要無根據 buff / nerf")

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)
