extends RefCounted


var current_value := 0.0
var max_value := 100.0
var issue_buckets: Dictionary = {}


func reset(new_max_value: float, initial_value: float = 0.0) -> void:
	max_value = maxf(1.0, new_max_value)
	current_value = clampf(initial_value, 0.0, max_value)
	issue_buckets.clear()


func add_pressure(amount: float, issue_name: String = "") -> void:
	current_value = clampf(current_value + amount, 0.0, max_value)
	if issue_name != "":
		issue_buckets[issue_name] = float(issue_buckets.get(issue_name, 0.0)) + amount


func relieve(amount: float) -> void:
	current_value = clampf(current_value - amount, 0.0, max_value)


func is_failed() -> bool:
	return current_value >= max_value


func top_issue_lines(max_lines: int = 3) -> Array:
	var ranked := []
	for issue_name in issue_buckets.keys():
		ranked.append({
			"name": issue_name,
			"value": float(issue_buckets[issue_name]),
		})

	for index in range(ranked.size()):
		var best_index := index
		for scan in range(index + 1, ranked.size()):
			if ranked[scan]["value"] > ranked[best_index]["value"]:
				best_index = scan
		if best_index != index:
			var temp: Dictionary = ranked[index]
			ranked[index] = ranked[best_index]
			ranked[best_index] = temp

	var lines: Array = []
	for entry in ranked:
		if entry["value"] > 0.25:
			lines.append("- %s" % entry["name"])
		if lines.size() >= max_lines:
			break
	if lines.is_empty():
		lines.append("- The whole station got away from you at once")
	return lines
