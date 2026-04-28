extends RefCounted
class_name LevelConfig


var level_id := "level_01"
var level_name := "Small Banquet"
var event_duration_seconds := 180.0
var dropoff_capacity := 4
var waiter_spawn_interval_seconds := 8.0
var waiter_spawn_interval_end_seconds := 5.5
var waiter_patience_seconds := 8.0
var tray_item_count_min := 2
var tray_item_count_max := 4
var glass_item_count_min := 0
var glass_item_count_max := 0
var glass_tray_chance := 0.0
var enabled_items := PackedStringArray(["plate_small"])
var enabled_systems := {
	"garbage": true,
	"crates": true,
	"glasses": false,
	"liquid_bucket": false,
	"cutlery": false,
	"post_event_report": true,
}
var crate_capacities := {
	"plate_small": 12,
}
var glass_rack_capacity := 8
var garbage_capacity := 100
var liquid_bucket_capacity := 6
var service_collapse_max := 100.0
var player_movement_speed := 180.0
var waiter_movement_speed := 120.0
var waiter_speed_variance := 8.0
var initial_clean_tray_stock := 3
var waiting_stress_per_second := 2.0
var dropoff_full_stress_per_second := 2.0
var garbage_blocked_stress_per_second := 2.8
var liquid_blocked_stress_per_second := 2.4
var calm_recovery_per_second := 1.8
var passive_recovery_per_second := 0.45


func load_from_file(path: String) -> LevelConfig:
	if not FileAccess.file_exists(path):
		return self

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return self

	var raw_data: Variant = JSON.parse_string(file.get_as_text())
	if raw_data is Dictionary:
		_apply_dictionary(raw_data)
	return self


func _apply_dictionary(data: Dictionary) -> void:
	level_id = str(data.get("level_id", level_id))
	level_name = str(data.get("name", level_name))
	event_duration_seconds = float(data.get("event_duration_seconds", event_duration_seconds))
	dropoff_capacity = int(data.get("dropoff_capacity", dropoff_capacity))
	waiter_spawn_interval_seconds = float(data.get("waiter_spawn_interval_seconds", waiter_spawn_interval_seconds))
	waiter_spawn_interval_end_seconds = float(data.get("waiter_spawn_interval_end_seconds", waiter_spawn_interval_end_seconds))
	waiter_patience_seconds = float(data.get("waiter_patience_seconds", waiter_patience_seconds))
	tray_item_count_min = int(data.get("tray_item_count_min", tray_item_count_min))
	tray_item_count_max = int(data.get("tray_item_count_max", tray_item_count_max))
	glass_item_count_min = int(data.get("glass_item_count_min", glass_item_count_min))
	glass_item_count_max = int(data.get("glass_item_count_max", glass_item_count_max))
	glass_tray_chance = float(data.get("glass_tray_chance", glass_tray_chance))
	garbage_capacity = int(data.get("garbage_capacity", garbage_capacity))
	liquid_bucket_capacity = int(data.get("liquid_bucket_capacity", liquid_bucket_capacity))
	service_collapse_max = float(data.get("service_collapse_max", service_collapse_max))
	player_movement_speed = float(data.get("player_movement_speed", player_movement_speed))
	waiter_movement_speed = float(data.get("waiter_movement_speed", waiter_movement_speed))
	waiter_speed_variance = float(data.get("waiter_speed_variance", waiter_speed_variance))
	initial_clean_tray_stock = int(data.get("initial_clean_tray_stock", initial_clean_tray_stock))
	waiting_stress_per_second = float(data.get("waiting_stress_per_second", waiting_stress_per_second))
	dropoff_full_stress_per_second = float(data.get("dropoff_full_stress_per_second", dropoff_full_stress_per_second))
	garbage_blocked_stress_per_second = float(data.get("garbage_blocked_stress_per_second", garbage_blocked_stress_per_second))
	liquid_blocked_stress_per_second = float(data.get("liquid_blocked_stress_per_second", liquid_blocked_stress_per_second))
	calm_recovery_per_second = float(data.get("calm_recovery_per_second", calm_recovery_per_second))
	passive_recovery_per_second = float(data.get("passive_recovery_per_second", passive_recovery_per_second))

	var raw_items: Variant = data.get("enabled_items", enabled_items)
	if raw_items is Array:
		var items := PackedStringArray()
		for item in raw_items:
			items.append(str(item))
		enabled_items = items

	var raw_systems: Variant = data.get("enabled_systems", enabled_systems)
	if raw_systems is Dictionary:
		var merged_systems: Dictionary = enabled_systems.duplicate(true)
		for key in raw_systems.keys():
			merged_systems[key] = bool(raw_systems[key])
		enabled_systems = merged_systems

	var raw_crates: Variant = data.get("crate_capacities", crate_capacities)
	if raw_crates is Dictionary:
		var parsed_crates: Dictionary = {}
		for key in raw_crates.keys():
			parsed_crates[str(key)] = int(raw_crates[key])
		crate_capacities = parsed_crates

	glass_rack_capacity = int(data.get("glass_rack_capacity", glass_rack_capacity))
