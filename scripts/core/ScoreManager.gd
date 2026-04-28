extends RefCounted


var level_name := "Small Banquet"
var total_waiter_wait_time := 0.0
var max_waiter_queue_length := 0
var dropoff_full_time := 0.0
var plates_scraped := 0
var plates_sorted := 0
var trays_completed := 0
var returned_trays := 0
var garbage_blocked_time := 0.0
var liquid_blocked_time := 0.0
var garbage_bag_runs := 0
var liquid_bucket_runs := 0
var crate_swap_runs := 0
var crate_blocked_attempts := 0
var scrape_quality_total := 0.0
var under_scraped_plates := 0
var dishwasher_complaints := 0
var glasses_dumped := 0
var glasses_sorted := 0
var crate_spill_incidents := 0
var garbage_spill_incidents := 0
var liquid_spill_incidents := 0


func reset(new_level_name: String) -> void:
	level_name = new_level_name
	total_waiter_wait_time = 0.0
	max_waiter_queue_length = 0
	dropoff_full_time = 0.0
	plates_scraped = 0
	plates_sorted = 0
	trays_completed = 0
	returned_trays = 0
	garbage_blocked_time = 0.0
	liquid_blocked_time = 0.0
	garbage_bag_runs = 0
	liquid_bucket_runs = 0
	crate_swap_runs = 0
	crate_blocked_attempts = 0
	scrape_quality_total = 0.0
	under_scraped_plates = 0
	dishwasher_complaints = 0
	glasses_dumped = 0
	glasses_sorted = 0
	crate_spill_incidents = 0
	garbage_spill_incidents = 0
	liquid_spill_incidents = 0


func record_waiter_wait(delta: float) -> void:
	total_waiter_wait_time += delta


func record_queue_length(queue_length: int) -> void:
	max_waiter_queue_length = maxi(max_waiter_queue_length, queue_length)


func record_dropoff_full(delta: float) -> void:
	dropoff_full_time += delta


func record_plate_scraped(scrape_quality: float = 100.0) -> void:
	plates_scraped += 1
	scrape_quality_total += clampf(scrape_quality, 0.0, 100.0)


func record_plate_sorted() -> void:
	plates_sorted += 1


func record_tray_completed() -> void:
	trays_completed += 1


func record_returned_tray() -> void:
	returned_trays += 1


func record_garbage_blocked(delta: float) -> void:
	garbage_blocked_time += delta


func record_liquid_blocked(delta: float) -> void:
	liquid_blocked_time += delta


func record_garbage_dump() -> void:
	garbage_bag_runs += 1


func record_liquid_dump() -> void:
	liquid_bucket_runs += 1


func record_crate_swap() -> void:
	crate_swap_runs += 1


func record_crate_blocked_attempt() -> void:
	crate_blocked_attempts += 1


func record_glass_dumped() -> void:
	glasses_dumped += 1


func record_glass_sorted() -> void:
	glasses_sorted += 1


func record_crate_spill() -> void:
	crate_spill_incidents += 1


func record_garbage_spill() -> void:
	garbage_spill_incidents += 1


func record_liquid_spill() -> void:
	liquid_spill_incidents += 1


func build_success_report(total_trays_spawned: int, collapse_value: float, collapse_max: float) -> String:
	var waiter_score := _score_waiter_efficiency()
	var scrape_score := _score_scrape_quality()
	var clean_score := _score_cleanliness()
	var sorting_score := _score_sorting_accuracy()
	var waste_score := _score_waste_management()
	var overall_score := int(round((waiter_score + scrape_score + clean_score + sorting_score + waste_score) / 5.0))

	var waiter_grade := _grade_for_score(waiter_score)
	var scrape_grade := _grade_for_score(scrape_score)
	var clean_grade := _grade_for_score(clean_score)
	var sorting_grade := _grade_for_score(sorting_score)
	var waste_grade := _grade_for_score(waste_score)
	var overall_grade := _grade_for_score(overall_score)
	var overall_status := _status_for_score(overall_score)
	var average_scrape_quality := _average_scrape_quality()
	var collapse_percent := 0.0
	if collapse_max > 0.0:
		collapse_percent = (collapse_value / collapse_max) * 100.0

	return "EVENT COMPLETE\n\nOverall Grade: %s\nStatus: %s\nLevel: %s\n\nWaiter Efficiency: %s | wait %.1fs | max queue %d\nScrape Quality: %s | avg %.0f%% | complaints %d\nCleanliness: %s | garbage %.1fs | liquid %.1fs | messes %d\nSorting Accuracy: %s | plates %d | glasses %d | blocked %d | crate spills %d\nWaste Management: %s | rack swaps %d | bucket runs %d | bag runs %d | overflow hits %d\n\nRun Stats\n- Trays processed: %d / %d\n- Returned trays: %d\n- Plates scraped: %d\n- Glasses dumped: %d\n- Final collapse: %.0f%%\n\nPress R to run the event again." % [
		overall_grade,
		overall_status,
		level_name,
		waiter_grade,
		total_waiter_wait_time,
		max_waiter_queue_length,
		scrape_grade,
		average_scrape_quality,
		dishwasher_complaints,
		clean_grade,
		garbage_blocked_time,
		liquid_blocked_time,
		garbage_spill_incidents + liquid_spill_incidents + crate_spill_incidents,
		sorting_grade,
		plates_sorted,
		glasses_sorted,
		crate_blocked_attempts,
		crate_spill_incidents,
		waste_grade,
		crate_swap_runs,
		liquid_bucket_runs,
		garbage_bag_runs,
		crate_spill_incidents + garbage_spill_incidents + liquid_spill_incidents,
		trays_completed,
		total_trays_spawned,
		returned_trays,
		plates_scraped,
		glasses_dumped,
		collapse_percent,
	]


func _average_scrape_quality() -> float:
	if plates_scraped <= 0:
		return 100.0
	return scrape_quality_total / float(plates_scraped)


func _score_waiter_efficiency() -> int:
	var raw_score := 98.0 - (total_waiter_wait_time * 0.5) - (float(max_waiter_queue_length) * 6.0) - (dropoff_full_time * 1.5)
	return int(round(clampf(raw_score, 0.0, 100.0)))


func _score_scrape_quality() -> int:
	var raw_score := _average_scrape_quality() - (float(under_scraped_plates) * 18.0) - (float(dishwasher_complaints) * 12.0)
	return int(round(clampf(raw_score, 0.0, 100.0)))


func _score_cleanliness() -> int:
	var raw_score := 96.0 - (garbage_blocked_time * 3.5) - (liquid_blocked_time * 3.75)
	raw_score -= float(garbage_spill_incidents + liquid_spill_incidents + crate_spill_incidents) * 6.0
	return int(round(clampf(raw_score, 0.0, 100.0)))


func _score_sorting_accuracy() -> int:
	var sorted_total := plates_sorted + glasses_sorted
	if sorted_total <= 0:
		return 75
	var raw_score := (float(sorted_total) / float(sorted_total + (crate_blocked_attempts * 2))) * 100.0
	raw_score -= float(crate_spill_incidents) * 8.0
	return int(round(clampf(raw_score, 0.0, 100.0)))


func _score_waste_management() -> int:
	var maintenance_bonus := minf(float(crate_swap_runs) * 5.0, 10.0)
	maintenance_bonus += minf(float(garbage_bag_runs) * 7.0, 12.0)
	maintenance_bonus += minf(float(liquid_bucket_runs) * 7.0, 12.0)
	var raw_score := 72.0 + maintenance_bonus - (garbage_blocked_time * 2.5) - (liquid_blocked_time * 2.5) - (float(crate_blocked_attempts) * 2.0)
	raw_score -= float(garbage_spill_incidents + liquid_spill_incidents) * 7.0
	raw_score -= float(crate_spill_incidents) * 4.0
	return int(round(clampf(raw_score, 0.0, 100.0)))


func _grade_for_score(score: int) -> String:
	if score >= 94:
		return "S"
	if score >= 84:
		return "A"
	if score >= 68:
		return "B"
	if score >= 52:
		return "C"
	return "D"


func _status_for_score(score: int) -> String:
	if score >= 95:
		return "Locked In"
	if score >= 85:
		return "Under Control"
	if score >= 70:
		return "Managed the Rush"
	if score >= 55:
		return "Shaky Service"
	return "Barely Held Together"
