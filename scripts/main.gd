extends Node2D

const LevelConfigData = preload("res://scripts/core/LevelConfig.gd")
const ScoreManagerData = preload("res://scripts/core/ScoreManager.gd")
const ServiceCollapseManagerData = preload("res://scripts/core/ServiceCollapseManager.gd")

const LEVEL_CONFIG_PATH := "res://data/levels/level_01.json"
const WORLD_SIZE := Vector2(1600, 900)
const PLAYER_SPEED := 180.0
const INTERACT_RANGE := 84.0
const INTERCEPT_RANGE := 52.0
const SLIDE_RANGE := 180.0
const PROMPT_RANGE := 140.0
const EVENT_DURATION := 180.0
const MAX_SERVICE_COLLAPSE := 100.0
const DROP_OFF_CAPACITY := 4
const CRATE_CAPACITY := 12
const GARBAGE_CAPACITY := 100
const INITIAL_SERVICE_COLLAPSE := 10.0

const FLOOR_COLOR := Color(0.93, 0.91, 0.85)
const FLOOR_LINE_COLOR := Color(0.86, 0.83, 0.76)
const TEXT_COLOR := Color(0.04, 0.04, 0.04)
const SHADOW_COLOR := Color(0.05, 0.04, 0.03, 0.16)
const WARNING_COLOR := Color(0.76, 0.22, 0.19)
const OK_COLOR := Color(0.18, 0.51, 0.31)
const TABLE_COLOR := Color(0.7, 0.61, 0.51)
const TABLE_EDGE_COLOR := Color(0.32, 0.26, 0.21)
const BUFFER_COLOR := Color(0.63, 0.58, 0.53)
const WORK_COLOR := Color(0.74, 0.64, 0.53)
const TRAY_COLOR := Color(0.31, 0.37, 0.45)
const TRAY_EMPTY_COLOR := Color(0.73, 0.76, 0.8)
const PLAYER_COLOR := Color(0.18, 0.42, 0.77)
const WAITER_COLOR := Color(0.8, 0.45, 0.18)
const CRATE_COLOR := Color(0.53, 0.38, 0.2)
const GARBAGE_COLOR := Color(0.16, 0.18, 0.15)
const RETURN_RAIL_COLOR := Color(0.83, 0.79, 0.72)
const GLASS_RACK_COLOR := Color(0.78, 0.89, 0.95)
const LIQUID_COLOR := Color(0.69, 0.84, 0.9)
const KITCHEN_COLOR := Color(0.67, 0.74, 0.84)
const DISPOSAL_COLOR := Color(0.58, 0.69, 0.57)
const PROMPT_BG_COLOR := Color(0.97, 0.96, 0.92, 0.95)
const PROMPT_TEXT_COLOR := TEXT_COLOR
const PROMPT_SOFT_COLOR := Color(0.82, 0.77, 0.66)
const DIRTY_TRAY_COLOR := Color(0.26, 0.29, 0.33)
const OVERLAY_BACKDROP_COLOR := Color(0.05, 0.05, 0.04, 0.46)
const OVERLAY_PANEL_COLOR := Color(0.95, 0.93, 0.89, 0.97)

const DROP_OFF_RECT := Rect2(290, 120, 200, 210)
const WORK_RECT := Rect2(520, 120, 300, 210)
const CRATE_SLOT_RECT := Rect2(940, 120, 180, 180)
const LIQUID_BUCKET_RECT := Rect2(760, 430, 140, 140)
const GARBAGE_RECT := Rect2(940, 410, 180, 180)
const CLEAN_STACK_RECT := Rect2(520, 430, 210, 120)
const GLASS_RACK_RECT := Rect2(940, 660, 180, 120)
const KITCHEN_RECT := Rect2(1230, 120, 240, 180)
const DISPOSAL_RECT := Rect2(1230, 430, 240, 180)
const FUTURE_SINK_RECT := Rect2(1230, 660, 240, 120)

const WORK_SLOT_POS := Vector2(670, 225)
const CRATE_SLOT_POS := Vector2(1030, 210)
const LIQUID_BUCKET_POS := Vector2(830, 500)
const GARBAGE_POS := Vector2(1030, 500)
const CLEAN_STACK_POS := Vector2(625, 490)
const GLASS_RACK_POS := Vector2(1030, 720)
const KITCHEN_POS := Vector2(1350, 210)
const CLEAN_TRAY_PICKUP_POS := Vector2(1398, 238)
const DISPOSAL_POS := Vector2(1350, 520)
const SINK_POS := Vector2(1350, 720)
const PLAYER_START_POS := Vector2(646, 360)
const DROP_POINT := Vector2(455, 210)
const ENTRY_POS := Vector2(-90, 210)
const EXIT_POS := Vector2(-120, 80)
const QUEUE_BASE_POS := Vector2(120, 210)
const QUEUE_SPACING := 74.0

var player_position := PLAYER_START_POS
var player_facing := Vector2.DOWN
var mouse_world_position := Vector2.ZERO
var carried_object = null

var work_tray = null
var drop_off_slots := []
var waiters := []

var level_config = null
var score_manager = null
var collapse_manager = null
var player_speed := PLAYER_SPEED
var event_duration := EVENT_DURATION
var drop_off_capacity := DROP_OFF_CAPACITY
var crate_capacity := CRATE_CAPACITY
var garbage_capacity := GARBAGE_CAPACITY
var service_collapse_max := MAX_SERVICE_COLLAPSE
var waiter_patience_seconds := 8.0
var waiter_spawn_interval_start := 8.0
var waiter_spawn_interval_end := 5.5
var waiter_speed_base := 120.0
var waiter_speed_variance := 8.0
var initial_clean_tray_stock := 3
var glass_item_count_min := 0
var glass_item_count_max := 0
var glass_tray_chance := 0.0
var waiting_stress_per_second := 2.0
var dropoff_full_stress_per_second := 2.0
var garbage_blocked_stress_per_second := 2.8
var liquid_blocked_stress_per_second := 2.4
var calm_recovery_per_second := 1.8
var passive_recovery_per_second := 0.45
var glass_rack_capacity := 8
var liquid_bucket_capacity := 6
var glasses_enabled := false
var liquid_bucket_enabled := false
var post_event_report_enabled := true

var event_time_left := EVENT_DURATION
var waiter_spawn_timer := 2.0
var garbage_fill := 0
var garbage_state := "available"
var crate_installed := true
var crate_fill := 0
var liquid_bucket_installed := true
var liquid_bucket_fill := 0
var glass_rack_installed := true
var glass_rack_fill := 0
var kitchen_empty_crates := 0
var kitchen_empty_glass_racks := 0
var returned_trays := 0
var dirty_tray_pit_count := 0
var clean_tray_stock := 3
var dish_pit_clean_timer := 0.0
var total_trays_spawned := 0
var waiters_spawned := 0
var trays_completed := 0
var plates_sorted := 0
var game_state := "playing"
var is_paused := false
var status_text := ""
var status_timer := 0.0
var ui_anim_time := 0.0
var mess_marks := []

var collapse_bar: ProgressBar
var hud_label: Label
var hint_label: Label
var overlay_backdrop: ColorRect
var overlay_panel: ColorRect
var overlay_label: Label


func _ready() -> void:
	randomize()
	_load_level_config()
	score_manager = ScoreManagerData.new()
	collapse_manager = ServiceCollapseManagerData.new()
	_build_ui()
	_restart_event()


func _load_level_config() -> void:
	level_config = LevelConfigData.new().load_from_file(LEVEL_CONFIG_PATH)
	player_speed = level_config.player_movement_speed
	event_duration = level_config.event_duration_seconds
	drop_off_capacity = level_config.dropoff_capacity
	crate_capacity = int(level_config.crate_capacities.get("plate_small", CRATE_CAPACITY))
	garbage_capacity = level_config.garbage_capacity
	service_collapse_max = level_config.service_collapse_max
	waiter_patience_seconds = level_config.waiter_patience_seconds
	waiter_spawn_interval_start = level_config.waiter_spawn_interval_seconds
	waiter_spawn_interval_end = level_config.waiter_spawn_interval_end_seconds
	waiter_speed_base = level_config.waiter_movement_speed
	waiter_speed_variance = level_config.waiter_speed_variance
	initial_clean_tray_stock = level_config.initial_clean_tray_stock
	glass_item_count_min = level_config.glass_item_count_min
	glass_item_count_max = level_config.glass_item_count_max
	glass_tray_chance = level_config.glass_tray_chance
	waiting_stress_per_second = level_config.waiting_stress_per_second
	dropoff_full_stress_per_second = level_config.dropoff_full_stress_per_second
	garbage_blocked_stress_per_second = level_config.garbage_blocked_stress_per_second
	liquid_blocked_stress_per_second = level_config.liquid_blocked_stress_per_second
	calm_recovery_per_second = level_config.calm_recovery_per_second
	passive_recovery_per_second = level_config.passive_recovery_per_second
	glass_rack_capacity = level_config.glass_rack_capacity
	liquid_bucket_capacity = level_config.liquid_bucket_capacity
	glasses_enabled = bool(level_config.enabled_systems.get("glasses", false))
	liquid_bucket_enabled = bool(level_config.enabled_systems.get("liquid_bucket", false))
	post_event_report_enabled = bool(level_config.enabled_systems.get("post_event_report", true))


func _process(delta: float) -> void:
	mouse_world_position = get_global_mouse_position()
	ui_anim_time += delta
	if game_state == "playing" and not is_paused:
		_update_player(delta)
		_update_dish_pit(delta)
		_update_waiter_spawns(delta)
		_update_waiters(delta)
		_update_station_pressure(delta)
		_update_event_timer(delta)
	if status_timer > 0.0:
		status_timer = max(0.0, status_timer - delta)
	_update_hud()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and game_state == "playing":
			_toggle_pause()
			return
		if event.keycode == KEY_R and game_state != "playing":
			_restart_event()
			return
		if game_state != "playing":
			return
		if is_paused:
			match event.keycode:
				KEY_SPACE, KEY_ENTER, KEY_ESCAPE:
					_toggle_pause()
				KEY_R:
					_restart_event()
				KEY_Q:
					get_tree().quit()
			return
		match event.keycode:
			KEY_SPACE:
				_handle_pickup_drop()
			KEY_Q:
				_handle_slide_tray()
			KEY_E:
				_handle_scrape()
			KEY_F:
				_handle_sort()


func _draw() -> void:
	_draw_floor()
	_draw_station_rect(DROP_OFF_RECT, BUFFER_COLOR, "Dirty Tray Buffer", "%d / %d trays ready to slide" % [_occupied_drop_slots(), drop_off_capacity], "buffer")
	_draw_station_rect(WORK_RECT, WORK_COLOR, "Work Table", _work_table_subtext(), "work")
	_draw_station_rect(CRATE_SLOT_RECT, TABLE_COLOR, "Plate Crate Slot", _crate_subtext(), "crate")
	_draw_station_rect(LIQUID_BUCKET_RECT, LIQUID_COLOR, "Liquid Bucket", _liquid_bucket_subtext(), "liquid")
	_draw_station_rect(GARBAGE_RECT, GARBAGE_COLOR.lightened(0.15), "Garbage", _garbage_subtext(), "garbage")
	_draw_station_rect(CLEAN_STACK_RECT, RETURN_RAIL_COLOR, "Tray Return Rail", "Send empty trays to the dish pit", "return")
	_draw_station_rect(GLASS_RACK_RECT, GLASS_RACK_COLOR, "Glass Rack", _glass_rack_subtext(), "glass")
	_draw_station_rect(KITCHEN_RECT, KITCHEN_COLOR, "Kitchen Pit", _kitchen_subtext(), "kitchen")
	_draw_station_rect(DISPOSAL_RECT, DISPOSAL_COLOR, "Bag Drop Zone", "Full bags disappear here", "disposal")
	_draw_station_rect(FUTURE_SINK_RECT, KITCHEN_COLOR.darkened(0.15), "Sink", "Dump the liquid bucket here", "sink")
	_draw_drop_off_slots()
	_draw_work_table()
	_draw_crate_slot()
	_draw_liquid_bucket()
	_draw_garbage_bin()
	_draw_return_rail()
	_draw_glass_rack()
	_draw_kitchen_pit()
	_draw_mess_marks()
	_draw_world_prompts()
	_draw_waiters()
	_draw_player()


func _build_ui() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)

	collapse_bar = ProgressBar.new()
	collapse_bar.position = Vector2(16, 16)
	collapse_bar.size = Vector2(380, 24)
	collapse_bar.min_value = 0.0
	collapse_bar.max_value = service_collapse_max
	collapse_bar.show_percentage = false
	hud.add_child(collapse_bar)

	hud_label = Label.new()
	hud_label.position = Vector2(16, 52)
	hud_label.size = Vector2(600, 340)
	hud_label.add_theme_color_override("font_color", TEXT_COLOR)
	hud.add_child(hud_label)

	hint_label = Label.new()
	hint_label.position = Vector2(16, 840)
	hint_label.size = Vector2(1560, 40)
	hint_label.add_theme_color_override("font_color", TEXT_COLOR)
	hud.add_child(hint_label)

	overlay_backdrop = ColorRect.new()
	overlay_backdrop.position = Vector2.ZERO
	overlay_backdrop.size = WORLD_SIZE
	overlay_backdrop.color = OVERLAY_BACKDROP_COLOR
	overlay_backdrop.visible = false
	hud.add_child(overlay_backdrop)

	overlay_panel = ColorRect.new()
	overlay_panel.position = Vector2(390, 160)
	overlay_panel.size = Vector2(820, 440)
	overlay_panel.color = OVERLAY_PANEL_COLOR
	overlay_panel.visible = false
	hud.add_child(overlay_panel)

	overlay_label = Label.new()
	overlay_label.position = overlay_panel.position + Vector2(36, 34)
	overlay_label.size = overlay_panel.size - Vector2(72, 68)
	overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_label.add_theme_color_override("font_color", TEXT_COLOR)
	overlay_label.add_theme_font_size_override("font_size", 30)
	overlay_label.visible = false
	hud.add_child(overlay_label)


func _restart_event() -> void:
	player_position = PLAYER_START_POS
	player_facing = Vector2.UP
	carried_object = null
	work_tray = null
	waiters = []
	drop_off_slots.clear()
	var slot_columns := mini(2, drop_off_capacity)
	var slot_rows := int(ceil(float(drop_off_capacity) / float(slot_columns)))
	var slot_left_margin := 36.0
	var slot_right_margin := 36.0
	var slot_top_margin := 86.0
	var slot_bottom_margin := 28.0
	var slot_track_width := DROP_OFF_RECT.size.x - slot_left_margin - slot_right_margin
	var slot_track_height := DROP_OFF_RECT.size.y - slot_top_margin - slot_bottom_margin
	var slot_spacing_x := 0.0 if slot_columns <= 1 else slot_track_width / float(slot_columns - 1)
	var slot_spacing_y := 0.0 if slot_rows <= 1 else slot_track_height / float(slot_rows - 1)
	for index in range(drop_off_capacity):
		var slot_row := int(index / slot_columns)
		var slot_column := index % slot_columns
		drop_off_slots.append({
			"position": Vector2(
				DROP_OFF_RECT.position.x + slot_left_margin + (slot_column * slot_spacing_x),
				DROP_OFF_RECT.position.y + slot_top_margin + (slot_row * slot_spacing_y)
			),
			"tray": null,
		})
	event_time_left = event_duration
	waiter_spawn_timer = minf(2.0, waiter_spawn_interval_start)
	garbage_fill = 0
	garbage_state = "available"
	crate_installed = true
	crate_fill = 0
	liquid_bucket_installed = true
	liquid_bucket_fill = 0
	glass_rack_installed = true
	glass_rack_fill = 0
	kitchen_empty_crates = 0
	kitchen_empty_glass_racks = 0
	returned_trays = 0
	dirty_tray_pit_count = 0
	clean_tray_stock = initial_clean_tray_stock
	dish_pit_clean_timer = 0.0
	total_trays_spawned = 0
	waiters_spawned = 0
	trays_completed = 0
	plates_sorted = 0
	game_state = "playing"
	is_paused = false
	score_manager.reset(level_config.level_name)
	collapse_manager.reset(service_collapse_max, INITIAL_SERVICE_COLLAPSE)
	collapse_bar.max_value = service_collapse_max
	mess_marks.clear()
	_hide_overlay()
	_set_status("Keep the tray buffer moving before the queue jams.")
	_update_hud()
	queue_redraw()


func _toggle_pause() -> void:
	is_paused = not is_paused
	if is_paused:
		_show_overlay("PAUSED\n\nEsc / Space Resume\nR Restart Event\nQ Quit Game")
	else:
		_hide_overlay()


func _show_overlay(text: String) -> void:
	overlay_label.text = text
	overlay_backdrop.visible = true
	overlay_panel.visible = true
	overlay_label.visible = true


func _hide_overlay() -> void:
	overlay_backdrop.visible = false
	overlay_panel.visible = false
	overlay_label.visible = false


func _update_dish_pit(delta: float) -> void:
	if dirty_tray_pit_count <= 0:
		dish_pit_clean_timer = 0.0
		return

	if dish_pit_clean_timer <= 0.0:
		_schedule_next_dish_pit_cycle()

	dish_pit_clean_timer -= delta
	if dish_pit_clean_timer > 0.0:
		return

	dirty_tray_pit_count = maxi(0, dirty_tray_pit_count - 1)
	clean_tray_stock += 1
	_schedule_next_dish_pit_cycle()


func _schedule_next_dish_pit_cycle() -> void:
	if dirty_tray_pit_count <= 0:
		dish_pit_clean_timer = 0.0
		return
	dish_pit_clean_timer = randf_range(2.4, 4.8)


func _update_player(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		input_vector.y += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		input_vector.x += 1.0

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		player_facing = input_vector
		player_position += input_vector * player_speed * delta

	player_position.x = clamp(player_position.x, 32.0, WORLD_SIZE.x - 32.0)
	player_position.y = clamp(player_position.y, 32.0, WORLD_SIZE.y - 32.0)


func _update_waiter_spawns(delta: float) -> void:
	waiter_spawn_timer -= delta
	if waiter_spawn_timer > 0.0 or event_time_left <= 0.0:
		return

	var intensity := 1.0 - (event_time_left / maxf(1.0, event_duration))
	var base_interval := lerpf(waiter_spawn_interval_start, waiter_spawn_interval_end, intensity)
	_spawn_waiter()
	waiter_spawn_timer = _roll_next_waiter_spawn_interval(base_interval)


func _roll_next_waiter_spawn_interval(base_interval: float) -> float:
	var roll := randf()
	if roll < 0.25:
		return maxf(3.2, randf_range(base_interval * 0.42, base_interval * 0.68))
	if roll < 0.50:
		return randf_range(base_interval * 1.35, base_interval * 1.8)
	return randf_range(base_interval * 0.88, base_interval * 1.12)


func _spawn_waiter() -> void:
	waiters_spawned += 1
	waiters.append({
		"position": ENTRY_POS,
		"speed": randf_range(waiter_speed_base - waiter_speed_variance, waiter_speed_base + waiter_speed_variance),
		"state": "queueing",
		"queue_index": 0,
		"target_slot_index": -1,
		"wait_time": 0.0,
		"has_clean_tray": false,
		"tray": _make_tray(),
	})


func _make_tray() -> Dictionary:
	total_trays_spawned += 1
	var plates := randi_range(level_config.tray_item_count_min, level_config.tray_item_count_max)
	var glasses := 0
	if glasses_enabled and glass_item_count_max > 0 and randf() <= glass_tray_chance:
		glasses = randi_range(glass_item_count_min, glass_item_count_max)
	return {
		"id": total_trays_spawned,
		"dirty_plates": plates,
		"ready_plates": 0,
		"plate_total": plates,
		"dirty_glasses": glasses,
		"ready_glasses": 0,
		"glass_total": glasses,
	}


func _update_waiters(delta: float) -> void:
	var queue := []
	for waiter in waiters:
		if _waiter_counts_toward_queue(waiter):
			queue.append(waiter)
	score_manager.record_queue_length(queue.size())

	for index in range(queue.size()):
		queue[index]["queue_index"] = index

	for waiter in waiters:
		if _waiter_counts_toward_queue(waiter):
			waiter["wait_time"] += delta
			score_manager.record_waiter_wait(delta)
			if waiter["wait_time"] > waiter_patience_seconds:
				collapse_manager.add_pressure(delta * waiting_stress_per_second, "Waiters waited too long")

		match waiter["state"]:
			"queueing":
				if waiter["queue_index"] == 0 and _has_free_drop_slot():
					var target_slot_index: int = _closest_open_drop_slot_index(waiter["position"])
					if target_slot_index >= 0:
						waiter["target_slot_index"] = target_slot_index
						waiter["state"] = "dropping"
					else:
						_move_agent(waiter, _queue_position(waiter["queue_index"]), delta)
				else:
					_move_agent(waiter, _queue_position(waiter["queue_index"]), delta)
			"dropping":
				var target_slot_index: int = waiter["target_slot_index"]
				if target_slot_index < 0 or target_slot_index >= drop_off_slots.size():
					target_slot_index = _closest_open_drop_slot_index(waiter["position"])
					waiter["target_slot_index"] = target_slot_index
				if target_slot_index < 0:
					waiter["state"] = "queueing"
				else:
					var target_position: Vector2 = drop_off_slots[target_slot_index]["position"]
					_move_agent(waiter, target_position, delta)
					if waiter["position"].distance_to(target_position) < 4.0:
						_deliver_waiter_tray(waiter)
			"pickup_clean_tray":
				_move_agent(waiter, CLEAN_TRAY_PICKUP_POS, delta)
				if waiter["position"].distance_to(CLEAN_TRAY_PICKUP_POS) < 4.0:
					_try_pickup_clean_tray(waiter)
			"leaving":
				_move_agent(waiter, EXIT_POS, delta)

	var survivors := []
	for waiter in waiters:
		if waiter["state"] == "leaving" and waiter["position"].distance_to(EXIT_POS) < 6.0:
			continue
		survivors.append(waiter)
	waiters = survivors


func _move_agent(agent: Dictionary, target: Vector2, delta: float) -> void:
	var current_position: Vector2 = agent["position"]
	var speed: float = agent["speed"]
	var offset: Vector2 = target - current_position
	var max_step: float = speed * delta
	if offset.length() <= max_step:
		agent["position"] = target
	else:
		agent["position"] = current_position + (offset.normalized() * max_step)


func _deliver_waiter_tray(waiter: Dictionary) -> void:
	var slot: Variant = null
	var target_slot_index: int = waiter["target_slot_index"]
	if target_slot_index >= 0 and target_slot_index < drop_off_slots.size():
		var target_slot: Dictionary = drop_off_slots[target_slot_index]
		if target_slot["tray"] == null:
			slot = target_slot
	if slot == null:
		var fallback_slot_index: int = _closest_open_drop_slot_index(waiter["position"])
		if fallback_slot_index >= 0:
			waiter["target_slot_index"] = fallback_slot_index
			slot = drop_off_slots[fallback_slot_index]
	if slot == null:
		waiter["state"] = "queueing"
		waiter["target_slot_index"] = -1
		return
	slot["tray"] = waiter["tray"]
	waiter["tray"] = null
	waiter["target_slot_index"] = -1
	_send_waiter_to_clean_stack(waiter)
	_set_status("A waiter dropped tray T%d on the station." % slot["tray"]["id"])


func _send_waiter_to_clean_stack(waiter: Dictionary) -> void:
	waiter["target_slot_index"] = -1
	waiter["state"] = "pickup_clean_tray"
	waiter["has_clean_tray"] = false
	waiter["wait_time"] = 0.0


func _try_pickup_clean_tray(waiter: Dictionary) -> void:
	if clean_tray_stock <= 0:
		return
	clean_tray_stock -= 1
	waiter["has_clean_tray"] = true
	waiter["state"] = "leaving"


func _update_station_pressure(delta: float) -> void:
	if not _has_free_drop_slot() and _active_waiter_count() > 0:
		score_manager.record_dropoff_full(delta)
		collapse_manager.add_pressure(delta * dropoff_full_stress_per_second, "Drop-off table stayed full")

	if garbage_state != "available":
		score_manager.record_garbage_blocked(delta)
		collapse_manager.add_pressure(delta * garbage_blocked_stress_per_second, "Garbage backed up")

	if liquid_bucket_enabled and _liquid_bucket_blocked():
		score_manager.record_liquid_blocked(delta)
		collapse_manager.add_pressure(delta * liquid_blocked_stress_per_second, "Liquid bucket backed up")

	if _active_waiter_count() == 0 and _occupied_drop_slots() <= 1 and garbage_state == "available" and not (liquid_bucket_enabled and _liquid_bucket_blocked()):
		collapse_manager.relieve(delta * calm_recovery_per_second)
	else:
		collapse_manager.relieve(delta * passive_recovery_per_second)

	if collapse_manager.is_failed():
		_finish_event(false)


func _update_event_timer(delta: float) -> void:
	event_time_left = max(0.0, event_time_left - delta)
	if event_time_left <= 0.0:
		_finish_event(true)


func _handle_pickup_drop() -> void:
	if carried_object != null:
		match carried_object["type"]:
			"tray":
				if _player_near(WORK_SLOT_POS) and work_tray == null:
					work_tray = carried_object["tray"]
					carried_object = null
					_set_status("Tray placed on the work table.")
					return
				if _player_near(CLEAN_STACK_POS) and _tray_is_empty(carried_object["tray"]):
					returned_trays += 1
					trays_completed += 1
					dirty_tray_pit_count += 1
					_schedule_next_dish_pit_cycle()
					score_manager.record_returned_tray()
					score_manager.record_tray_completed()
					carried_object = null
					_set_status("Empty tray sent to the dish pit.")
					return
				var open_drop_slot: Variant = _nearby_open_drop_slot()
				if open_drop_slot != null:
					open_drop_slot["tray"] = carried_object["tray"]
					carried_object = null
					_set_status("Tray put back onto the tray buffer.")
					return
				_set_status("Carry the tray to the work table, or return it if it is empty.")
			"full_crate":
				if _player_near(KITCHEN_POS):
					kitchen_empty_crates += 1
					carried_object = null
					_set_status("Full crate dropped at the kitchen. An empty crate is ready.")
					return
				_set_status("Carry the full crate to the kitchen station.")
			"empty_crate":
				if _player_near(CRATE_SLOT_POS) and not crate_installed:
					crate_installed = true
					crate_fill = 0
					score_manager.record_crate_swap()
					carried_object = null
					_set_status("Empty crate installed back at the station.")
					return
				_set_status("Bring the empty crate back to the crate slot.")
			"full_glass_rack":
				if _player_near(KITCHEN_POS):
					kitchen_empty_glass_racks += 1
					carried_object = null
					_set_status("Full glass rack dropped at the kitchen. An empty rack is ready.")
					return
				_set_status("Carry the full glass rack to the kitchen station.")
			"empty_glass_rack":
				if _player_near(GLASS_RACK_POS) and not glass_rack_installed:
					glass_rack_installed = true
					glass_rack_fill = 0
					score_manager.record_crate_swap()
					carried_object = null
					_set_status("Empty glass rack installed back at the station.")
					return
				_set_status("Bring the empty glass rack back to the rack slot.")
			"full_liquid_bucket":
				if _player_near(SINK_POS):
					liquid_bucket_fill = 0
					carried_object = {"type": "empty_liquid_bucket"}
					score_manager.record_liquid_dump()
					_set_status("Liquid bucket dumped. Bring it back to the station.")
					return
				_set_status("Carry the liquid bucket to the sink.")
			"empty_liquid_bucket":
				if _player_near(LIQUID_BUCKET_POS) and not liquid_bucket_installed:
					liquid_bucket_installed = true
					carried_object = null
					_set_status("Liquid bucket returned to the station.")
					return
				_set_status("Bring the empty liquid bucket back to the station.")
			"garbage_bag":
				if _player_near(DISPOSAL_POS):
					garbage_fill = 0
					garbage_state = "available"
					score_manager.record_garbage_dump()
					carried_object = null
					_set_status("Garbage bag dumped. Fresh bag is back in service.")
					return
				_set_status("Carry the garbage bag to the drop zone.")
		return

	var nearby_waiter: Variant = _nearby_waiter_with_tray()
	if nearby_waiter != null:
		carried_object = {"type": "tray", "tray": nearby_waiter["tray"]}
		nearby_waiter["tray"] = null
		nearby_waiter["target_slot_index"] = -1
		_send_waiter_to_clean_stack(nearby_waiter)
		_set_status("You grabbed the tray off the waiter before the drop-off.")
		return

	if work_tray != null and _player_near(WORK_SLOT_POS):
		carried_object = {"type": "tray", "tray": work_tray}
		work_tray = null
		_set_status("Picked up the work tray.")
		return

	var drop_slot: Variant = _nearby_filled_drop_slot()
	if drop_slot != null:
		carried_object = {"type": "tray", "tray": drop_slot["tray"]}
		drop_slot["tray"] = null
		_set_status("Pulled a dirty tray off the tray buffer.")
		return

	if crate_installed and crate_fill >= crate_capacity and _player_near(CRATE_SLOT_POS):
		var crate_spill_text := _resolve_overflow_move_risk("crate", crate_fill, crate_capacity)
		carried_object = {"type": "full_crate"}
		crate_installed = false
		_set_status("Full crate lifted. Take it to the kitchen." if crate_spill_text == "" else crate_spill_text)
		return

	if not crate_installed and kitchen_empty_crates > 0 and _player_near(KITCHEN_POS):
		kitchen_empty_crates -= 1
		carried_object = {"type": "empty_crate"}
		_set_status("Picked up an empty crate from the kitchen.")
		return

	if glasses_enabled and glass_rack_installed and glass_rack_fill >= glass_rack_capacity and _player_near(GLASS_RACK_POS):
		carried_object = {"type": "full_glass_rack"}
		glass_rack_installed = false
		_set_status("Full glass rack lifted. Take it to the kitchen.")
		return

	if glasses_enabled and not glass_rack_installed and kitchen_empty_glass_racks > 0 and _player_near(KITCHEN_POS):
		kitchen_empty_glass_racks -= 1
		carried_object = {"type": "empty_glass_rack"}
		_set_status("Picked up an empty glass rack from the kitchen.")
		return

	if liquid_bucket_enabled and liquid_bucket_installed and liquid_bucket_fill > 0 and _player_near(LIQUID_BUCKET_POS):
		var liquid_spill_text := _resolve_overflow_move_risk("liquid", liquid_bucket_fill, liquid_bucket_capacity)
		liquid_bucket_installed = false
		carried_object = {"type": "full_liquid_bucket"}
		_set_status("Liquid bucket lifted. Take it to the sink." if liquid_spill_text == "" else liquid_spill_text)
		return

	if garbage_state != "missing" and garbage_fill > 0 and _player_near(GARBAGE_POS):
		var garbage_spill_text := _resolve_overflow_move_risk("garbage", garbage_fill, garbage_capacity)
		garbage_state = "missing"
		carried_object = {"type": "garbage_bag"}
		_set_status("Garbage bag lifted. Take it to the drop zone." if garbage_spill_text == "" else garbage_spill_text)
		return

	_set_status("Nothing to pick up or drop here.")


func _handle_slide_tray() -> void:
	if carried_object != null:
		_set_status("Hands are full. You can only slide with free hands.")
		return
	if work_tray != null:
		_set_status("Work table is occupied. Clear it before sliding another tray.")
		return
	if not _player_near(WORK_SLOT_POS, 150.0):
		_set_status("Stand at the scraping station to slide trays over.")
		return

	var slot_index: int = _hovered_drop_slot_index(true)
	if slot_index < 0:
		slot_index = _closest_filled_drop_slot_index(WORK_SLOT_POS)
	if slot_index < 0:
		_set_status("No tray is ready to slide over.")
		return

	var slot: Dictionary = drop_off_slots[slot_index]
	work_tray = slot["tray"]
	slot["tray"] = null
	_set_status("Tray slid from the buffer to the work table.")


func _handle_scrape() -> void:
	if carried_object != null:
		_set_status("Hands are full.")
		return
	if work_tray == null or not _player_near(WORK_SLOT_POS):
		_set_status("Set a tray on the work table first.")
		return
	if work_tray["dirty_plates"] <= 0 and work_tray["dirty_glasses"] <= 0:
		if work_tray["ready_plates"] > 0 or work_tray["ready_glasses"] > 0:
			_set_status("Use F to put the processed items away.")
		else:
			_set_status("Tray is empty. Return it to the tray return rail.")
		return

	if work_tray["dirty_plates"] > 0 and _garbage_can_accept_more():
		work_tray["dirty_plates"] -= 1
		work_tray["ready_plates"] += 1
		score_manager.record_plate_scraped()
		garbage_fill += 1
		if garbage_fill > _overflow_limit(garbage_capacity):
			garbage_fill = _overflow_limit(garbage_capacity)
			_set_status("Garbage is packed to the limit. Dump it before it rips.")
		elif garbage_fill > garbage_capacity:
			_set_status("Garbage is overfilled. Moving it now may rip the bag.")
		elif garbage_fill == garbage_capacity:
			_set_status("Garbage is full. You can dump it now or push your luck.")
		else:
			_set_status("Plate scraped. Ready plates can be put in the crate with F.")
		return

	if work_tray["dirty_glasses"] > 0 and _liquid_bucket_can_accept_more():
		work_tray["dirty_glasses"] -= 1
		work_tray["ready_glasses"] += 1
		liquid_bucket_fill += 1
		score_manager.record_glass_dumped()
		if liquid_bucket_fill > _overflow_limit(liquid_bucket_capacity):
			liquid_bucket_fill = _overflow_limit(liquid_bucket_capacity)
			_set_status("Liquid bucket is packed to the limit. Empty it before it spills.")
		elif liquid_bucket_fill > liquid_bucket_capacity:
			_set_status("Liquid bucket is overfilled. Moving it now may spill.")
		elif liquid_bucket_fill == liquid_bucket_capacity:
			_set_status("Liquid bucket is full. You can empty it now or keep pushing.")
		else:
			_set_status("Glass dumped. Use F to rack it.")
		return

	if work_tray["dirty_plates"] > 0 and garbage_state == "missing":
		_set_status("Garbage is blocked. Empty the bag before scraping more plates.")
		return

	if work_tray["dirty_plates"] > 0:
		_set_status("Garbage is packed to the limit. Dump it before scraping more plates.")
		return

	if work_tray["dirty_glasses"] > 0:
		if liquid_bucket_installed:
			_set_status("Liquid bucket is packed to the limit. Empty it before dumping more glasses.")
		else:
			_set_status("Liquid bucket is blocked. Take it to the sink and bring it back.")
		return

	_set_status("Nothing on this tray can be processed right now.")


func _handle_sort() -> void:
	if carried_object != null:
		_set_status("Hands are full.")
		return
	if work_tray == null or not _player_near(WORK_SLOT_POS):
		_set_status("Set a tray on the work table first.")
		return
	if work_tray["ready_plates"] <= 0 and work_tray["ready_glasses"] <= 0:
		if work_tray["dirty_plates"] > 0 or work_tray["dirty_glasses"] > 0:
			_set_status("Process tray items with E before putting them away.")
		else:
			_set_status("Tray is empty. Return it to the tray return rail.")
		return

	if work_tray["ready_plates"] > 0 and crate_installed and crate_fill < _overflow_limit(crate_capacity):
		work_tray["ready_plates"] -= 1
		crate_fill += 1
		plates_sorted += 1
		score_manager.record_plate_sorted()
		if crate_fill > crate_capacity:
			_set_status("Crate is overfilled. The more you push it, the riskier the carry.")
		elif crate_fill == crate_capacity:
			_set_status("Crate filled up. Carry it to the kitchen or risk an overfill.")
		elif _tray_is_empty(work_tray):
			_set_status("Tray cleared. Return the empty tray to the tray return rail.")
		else:
			_set_status("Plate put into the crate.")
		return

	if work_tray["ready_glasses"] > 0 and glass_rack_installed and glass_rack_fill < glass_rack_capacity:
		work_tray["ready_glasses"] -= 1
		glass_rack_fill += 1
		score_manager.record_glass_sorted()
		if glass_rack_fill >= glass_rack_capacity:
			glass_rack_fill = glass_rack_capacity
			_set_status("Glass rack filled up. Carry it to the kitchen and swap it.")
		elif _tray_is_empty(work_tray):
			_set_status("Tray cleared. Return the empty tray to the tray return rail.")
		else:
			_set_status("Glass racked.")
		return

	score_manager.record_crate_blocked_attempt()
	if work_tray["ready_plates"] > 0:
		if not crate_installed:
			_set_status("Crate slot is empty. Bring back a fresh crate.")
		else:
			_set_status("Crate is full. Carry it to the kitchen.")
		return

	if work_tray["ready_glasses"] > 0:
		if not glass_rack_installed:
			_set_status("Glass rack slot is empty. Bring back a fresh rack.")
		else:
			_set_status("Glass rack is full. Carry it to the kitchen.")
		return

	_set_status("Nothing can be sorted right now.")


func _finish_event(success: bool) -> void:
	if game_state != "playing":
		return
	game_state = "success" if success else "failure"
	if success:
		_show_overlay(_success_report())
	else:
		_show_overlay(_failure_report())


func _success_report() -> String:
	if not post_event_report_enabled:
		return "EVENT COMPLETE\n\nYou held the station together.\n\nPress R to run the event again."
	return score_manager.build_success_report(total_trays_spawned, collapse_manager.current_value, collapse_manager.max_value)


func _failure_report() -> String:
	var lines: Array = collapse_manager.top_issue_lines()
	return "EVENT FAILED\n\nService collapsed before the event ended.\n\nMain issues:\n%s\n\nTry again and focus on keeping the tray buffer clear.\n\nPress R to restart." % "\n".join(lines)


func _top_issue_lines() -> Array:
	return collapse_manager.top_issue_lines()


func _update_hud() -> void:
	collapse_bar.value = collapse_manager.current_value

	var seconds_left: int = max(0, int(ceil(event_time_left)))
	var minutes: int = int(seconds_left / 60)
	var seconds: int = seconds_left % 60
	var visible_status := status_text if status_timer > 0.0 else "Follow the prompts over stations."
	var queue_count := _active_waiter_count()
	var carried_label := _carried_object_label()

	hud_label.text = "Level: %s\nService Collapse\nTime: %02d:%02d\nQueue: %d waiter(s)\nTray Buffer: %d / %d trays\nWork Tray: %s\nPlate Crate: %s\nGlass Rack: %s\nLiquid Bucket: %s\nGarbage: %s\nCarrying: %s\nReturned Trays: %d\nStatus: %s" % [
		level_config.level_name,
		minutes,
		seconds,
		queue_count,
		_occupied_drop_slots(),
		drop_off_capacity,
		_work_tray_status(),
		_crate_subtext(),
		_glass_rack_subtext(),
		_liquid_bucket_subtext(),
		_garbage_subtext(),
		carried_label,
		returned_trays,
		visible_status,
	]

	hint_label.text = _context_hint()


func _context_hint() -> String:
	if game_state != "playing":
		return "Press R to restart the event."
	if is_paused:
		return "Paused | Esc or Space resume | R restart | Q quit"

	return "WASD move | Space pick up/drop | Q slide hovered tray | E process item | F put away item"


func _set_status(message: String) -> void:
	status_text = message
	status_timer = 3.0


func _carried_object_label() -> String:
	if carried_object == null:
		return "empty"
	match carried_object["type"]:
		"full_crate":
			return "full plate crate"
		"empty_crate":
			return "empty plate crate"
		"full_glass_rack":
			return "full glass rack"
		"empty_glass_rack":
			return "empty glass rack"
		"full_liquid_bucket":
			return "liquid bucket"
		"empty_liquid_bucket":
			return "empty liquid bucket"
	return str(carried_object["type"])


func _player_near(point: Vector2, distance_limit: float = INTERACT_RANGE) -> bool:
	return player_position.distance_to(point) <= distance_limit


func _tray_is_empty(tray: Dictionary) -> bool:
	return tray["dirty_plates"] <= 0 and tray["ready_plates"] <= 0 and tray["dirty_glasses"] <= 0 and tray["ready_glasses"] <= 0


func _liquid_bucket_ready_for_use() -> bool:
	return liquid_bucket_enabled and liquid_bucket_installed


func _liquid_bucket_blocked() -> bool:
	return liquid_bucket_enabled and not liquid_bucket_installed


func _garbage_can_accept_more() -> bool:
	return garbage_state != "missing" and garbage_fill < _overflow_limit(garbage_capacity)


func _liquid_bucket_can_accept_more() -> bool:
	return liquid_bucket_enabled and liquid_bucket_installed and liquid_bucket_fill < _overflow_limit(liquid_bucket_capacity)


func _overflow_limit(capacity: int, minimum_extra: int = 3) -> int:
	return capacity + maxi(minimum_extra, int(round(float(capacity) * 0.5)))


func _warning_pulse(strength: float) -> float:
	return 0.45 + (0.55 * ((sin(ui_anim_time * 5.2) * 0.5) + 0.5) * clampf(strength, 0.0, 1.0))


func _station_alert_strength(station_id: String) -> float:
	match station_id:
		"buffer":
			return clampf(float(_occupied_drop_slots()) / float(maxi(1, drop_off_capacity)), 0.0, 1.0) * 0.35
		"crate":
			if crate_fill > crate_capacity:
				return 1.0
			if crate_fill >= crate_capacity:
				return 0.65
		"liquid":
			if liquid_bucket_fill > liquid_bucket_capacity:
				return 1.0
			if liquid_bucket_fill >= liquid_bucket_capacity:
				return 0.68
		"garbage":
			if garbage_fill > garbage_capacity:
				return 1.0
			if garbage_fill >= garbage_capacity:
				return 0.68
		"glass":
			if glass_rack_fill >= glass_rack_capacity:
				return 0.58
	return 0.0


func _spawn_mess_mark(position: Vector2, color: Color, label: String) -> void:
	var mess_entry := {
		"position": position + Vector2(randf_range(-22.0, 22.0), randf_range(-18.0, 18.0)),
		"color": color,
		"label": label,
	}
	mess_marks.append(mess_entry)
	if mess_marks.size() > 12:
		mess_marks.pop_front()


func _draw_mess_marks() -> void:
	for mess_mark in mess_marks:
		var mark_position: Vector2 = mess_mark["position"]
		var mark_color: Color = mess_mark["color"]
		var pulse := 0.86 + (0.14 * sin(ui_anim_time * 3.6))
		draw_circle(mark_position + Vector2(-8, 2), 15.0, Color(mark_color.r, mark_color.g, mark_color.b, 0.16 * pulse))
		draw_circle(mark_position + Vector2(10, -1), 12.0, Color(mark_color.r, mark_color.g, mark_color.b, 0.14 * pulse))
		draw_circle(mark_position + Vector2(0, -6), 10.0, Color(mark_color.r, mark_color.g, mark_color.b, 0.18 * pulse))
		_draw_text(str(mess_mark["label"]), mark_position + Vector2(-18, 28), mark_color.darkened(0.35), 12)


func _overflow_pickup_chance(fill_amount: int, capacity: int) -> float:
	if fill_amount <= capacity:
		return 0.0
	var extra_capacity := maxi(1, _overflow_limit(capacity) - capacity)
	var overflow_ratio := float(fill_amount - capacity) / float(extra_capacity)
	return clampf(0.14 + (overflow_ratio * 0.72), 0.14, 0.9)


func _resolve_overflow_move_risk(kind: String, fill_amount: int, capacity: int) -> String:
	if fill_amount <= capacity:
		return ""
	var spill_chance := _overflow_pickup_chance(fill_amount, capacity)
	if randf() > spill_chance:
		return ""

	var overflow_amount := fill_amount - capacity
	var lost_amount := maxi(1, int(ceil(float(overflow_amount) * randf_range(0.8, 1.45))))
	match kind:
		"crate":
			crate_fill = maxi(capacity, fill_amount - lost_amount)
			score_manager.record_crate_spill()
			collapse_manager.add_pressure(7.0 + (spill_chance * 10.0), "Crate spills caused a mess")
			_spawn_mess_mark(CRATE_SLOT_POS, Color(0.72, 0.49, 0.22), "spill")
			return "The overfilled crate spilled plates while you lifted it."
		"garbage":
			garbage_fill = maxi(capacity, fill_amount - lost_amount)
			score_manager.record_garbage_spill()
			collapse_manager.add_pressure(8.0 + (spill_chance * 10.0), "Garbage bags ripped and spilled")
			_spawn_mess_mark(GARBAGE_POS, Color(0.41, 0.32, 0.18), "trash")
			return "The overfilled garbage bag ripped and spilled."
		"liquid":
			liquid_bucket_fill = maxi(capacity, fill_amount - lost_amount)
			score_manager.record_liquid_spill()
			collapse_manager.add_pressure(8.0 + (spill_chance * 10.0), "Liquid bucket spills made a mess")
			_spawn_mess_mark(LIQUID_BUCKET_POS, Color(0.27, 0.52, 0.73), "spill")
			return "The overfilled liquid bucket sloshed everywhere."
	return ""


func _occupied_drop_slots() -> int:
	var count := 0
	for slot in drop_off_slots:
		if slot["tray"] != null:
			count += 1
	return count


func _active_waiter_count() -> int:
	var count := 0
	for waiter in waiters:
		if _waiter_counts_toward_queue(waiter):
			count += 1
	return count


func _waiter_counts_toward_queue(waiter: Dictionary) -> bool:
	return waiter["state"] == "queueing" or waiter["state"] == "dropping"


func _has_free_drop_slot() -> bool:
	return _occupied_drop_slots() < drop_off_capacity


func _first_open_drop_slot():
	for slot in drop_off_slots:
		if slot["tray"] == null:
			return slot
	return null


func _closest_open_drop_slot_index(from_position: Vector2) -> int:
	var best_index := -1
	var best_distance := INF
	for index in range(drop_off_slots.size()):
		var slot: Dictionary = drop_off_slots[index]
		if slot["tray"] != null:
			continue
		var distance_to_slot := from_position.distance_squared_to(slot["position"])
		if distance_to_slot < best_distance:
			best_distance = distance_to_slot
			best_index = index
	return best_index


func _closest_filled_drop_slot_index(from_position: Vector2) -> int:
	var best_index := -1
	var best_distance := INF
	for index in range(drop_off_slots.size()):
		var slot: Dictionary = drop_off_slots[index]
		if slot["tray"] == null:
			continue
		var distance_to_slot := from_position.distance_squared_to(slot["position"])
		if distance_to_slot < best_distance:
			best_distance = distance_to_slot
			best_index = index
	return best_index


func _hovered_drop_slot_index(require_filled: bool = false) -> int:
	for index in range(drop_off_slots.size()):
		var slot: Dictionary = drop_off_slots[index]
		if require_filled and slot["tray"] == null:
			continue
		if _drop_off_slot_rect(slot["position"]).has_point(mouse_world_position):
			return index
	return -1


func _nearby_filled_drop_slot(distance_limit: float = INTERACT_RANGE):
	for slot in drop_off_slots:
		if slot["tray"] != null and _player_near(slot["position"], distance_limit):
			return slot
	return null


func _nearby_waiter_with_tray(distance_limit: float = INTERCEPT_RANGE):
	var best_waiter: Variant = null
	var best_distance := INF
	for waiter in waiters:
		if waiter["tray"] == null or waiter["state"] == "leaving":
			continue
		var distance_to_waiter := player_position.distance_squared_to(waiter["position"])
		if distance_to_waiter <= distance_limit * distance_limit and distance_to_waiter < best_distance:
			best_distance = distance_to_waiter
			best_waiter = waiter
	return best_waiter


func _nearby_open_drop_slot(distance_limit: float = INTERACT_RANGE):
	var best_slot: Variant = null
	var best_distance := INF
	for slot in drop_off_slots:
		if slot["tray"] != null:
			continue
		var distance_to_slot := player_position.distance_squared_to(slot["position"])
		if distance_to_slot <= distance_limit * distance_limit and distance_to_slot < best_distance:
			best_distance = distance_to_slot
			best_slot = slot
	return best_slot


func _queue_position(index: int) -> Vector2:
	return QUEUE_BASE_POS + Vector2(-QUEUE_SPACING * float(index), 0.0)


func _work_tray_status() -> String:
	if work_tray == null:
		return "empty"
	return "T%d | P %d/%d | G %d/%d" % [work_tray["id"], work_tray["dirty_plates"], work_tray["ready_plates"], work_tray["dirty_glasses"], work_tray["ready_glasses"]]


func _work_table_subtext() -> String:
	if work_tray == null:
		return "Slide or place one dirty tray here to process it"
	return "T%d | plates %d/%d | glasses %d/%d" % [work_tray["id"], work_tray["dirty_plates"], work_tray["ready_plates"], work_tray["dirty_glasses"], work_tray["ready_glasses"]]


func _crate_subtext() -> String:
	if not crate_installed:
		if kitchen_empty_crates > 0:
			return "Slot empty | kitchen has a replacement"
		return "Slot empty | take the full crate away first"
	if crate_fill > crate_capacity:
		return "%d / %d overfilled | spill risk on move" % [crate_fill, crate_capacity]
	if crate_fill >= crate_capacity:
		return "%d / %d full | carry to kitchen" % [crate_fill, crate_capacity]
	return "%d / %d plates sorted" % [crate_fill, crate_capacity]


func _liquid_bucket_subtext() -> String:
	if not liquid_bucket_enabled:
		return "Disabled for this level"
	if not liquid_bucket_installed:
		return "Bucket away | bring it back from the sink"
	if liquid_bucket_fill > liquid_bucket_capacity:
		return "%d / %d overfilled | spill risk" % [liquid_bucket_fill, liquid_bucket_capacity]
	if liquid_bucket_fill >= liquid_bucket_capacity:
		return "%d / %d full | carry to sink" % [liquid_bucket_fill, liquid_bucket_capacity]
	if liquid_bucket_fill > 0:
		return "%d / %d liquid | can empty anytime" % [liquid_bucket_fill, liquid_bucket_capacity]
	return "%d / %d liquid dumped" % [liquid_bucket_fill, liquid_bucket_capacity]


func _garbage_subtext() -> String:
	match garbage_state:
		"available":
			if garbage_fill > garbage_capacity:
				return "%d / %d overfilled | rip risk on move" % [garbage_fill, garbage_capacity]
			if garbage_fill > 0:
				return "%d / %d fill | can dump anytime" % [garbage_fill, garbage_capacity]
			return "%d / %d fill" % [garbage_fill, garbage_capacity]
		"missing":
			return "NO BAG | disposal run in progress"
	return ""


func _glass_rack_subtext() -> String:
	if not glasses_enabled:
		return "Disabled for this level"
	if not glass_rack_installed:
		if kitchen_empty_glass_racks > 0:
			return "Rack empty | kitchen has a replacement"
		return "Rack empty | take the full rack away first"
	if glass_rack_fill >= glass_rack_capacity:
		return "%d / %d full | carry to kitchen" % [glass_rack_fill, glass_rack_capacity]
	return "%d / %d glasses sorted" % [glass_rack_fill, glass_rack_capacity]


func _kitchen_subtext() -> String:
	return "Dirty trays %d | Clean trays %d | Plate crates %d | Glass racks %d" % [dirty_tray_pit_count, clean_tray_stock, kitchen_empty_crates, kitchen_empty_glass_racks]


func _draw_floor() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), FLOOR_COLOR, true)
	draw_rect(Rect2(0, 96, WORLD_SIZE.x, 266), Color(0.9, 0.87, 0.8, 0.32), true)
	draw_rect(Rect2(0, 620, WORLD_SIZE.x, 110), Color(0.89, 0.9, 0.84, 0.24), true)
	draw_rect(Rect2(500, 96, 34, 470), Color(0.82, 0.74, 0.62, 0.32), true)
	for x in range(0, int(WORLD_SIZE.x), 64):
		draw_line(Vector2(x, 0), Vector2(x, WORLD_SIZE.y), FLOOR_LINE_COLOR, 1.0)
	for y in range(0, int(WORLD_SIZE.y), 64):
		draw_line(Vector2(0, y), Vector2(WORLD_SIZE.x, y), FLOOR_LINE_COLOR, 1.0)
	for lane_x in [505.0, 520.0]:
		draw_line(Vector2(lane_x, 110), Vector2(lane_x, 544), Color(0.66, 0.56, 0.42, 0.5), 2.0)


func _draw_station_rect(rect: Rect2, fill: Color, title: String, subtitle: String, station_id: String = "") -> void:
	var alert_strength := _station_alert_strength(station_id)
	var border_color := TABLE_EDGE_COLOR
	if alert_strength > 0.0:
		border_color = TABLE_EDGE_COLOR.lerp(WARNING_COLOR, _warning_pulse(alert_strength))
	var shadow_rect := rect
	shadow_rect.position += Vector2(8, 8)
	draw_rect(shadow_rect, SHADOW_COLOR, true)
	draw_rect(rect, fill, true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 32)), fill.darkened(0.12), true)
	draw_rect(rect.grow(3.0), border_color, false, 3.0)
	draw_line(rect.position + Vector2(0, 32), rect.position + Vector2(rect.size.x, 32), border_color.darkened(0.1), 2.0)
	_draw_text(title, rect.position + Vector2(12, 22), TEXT_COLOR, 16)
	_draw_text(subtitle, rect.position + Vector2(12, 52), TEXT_COLOR, 13)


func _draw_drop_off_slots() -> void:
	draw_line(DROP_OFF_RECT.position + Vector2(24, 74), DROP_OFF_RECT.position + Vector2(DROP_OFF_RECT.size.x - 24, 74), Color(0.41, 0.34, 0.28, 0.35), 3.0)
	for slot in drop_off_slots:
		var tray_rect := _drop_off_slot_rect(slot["position"])
		draw_rect(tray_rect, Color(0.35, 0.32, 0.28, 0.2), true)
		draw_rect(tray_rect, TABLE_EDGE_COLOR, false, 2.0)
		if tray_rect.has_point(mouse_world_position):
			draw_rect(tray_rect.grow(4.0), OK_COLOR, false, 2.0)
		if slot["tray"] != null:
			_draw_tray(tray_rect, slot["tray"])


func _drop_off_slot_rect(slot_position: Vector2) -> Rect2:
	return Rect2(slot_position - Vector2(30, 20), Vector2(60, 40))


func _draw_work_table() -> void:
	var tray_rect := Rect2(WORK_SLOT_POS - Vector2(60, 45), Vector2(120, 90))
	draw_rect(tray_rect.grow(8.0), Color(0.5, 0.4, 0.3, 0.08), true)
	draw_rect(tray_rect, Color(0.37, 0.34, 0.31, 0.22), true)
	draw_rect(tray_rect, TABLE_EDGE_COLOR, false, 2.0)
	if work_tray != null:
		_draw_tray(tray_rect, work_tray, true)


func _draw_tray(rect: Rect2, tray: Dictionary, large: bool = false) -> void:
	draw_rect(rect, TRAY_COLOR, true)
	draw_rect(rect, Color.WHITE, false, 2.0)
	var font_size := 10 if not large else 13
	_draw_text("T%d" % tray["id"], rect.position + Vector2(6, 16 if not large else 18), TEXT_COLOR, font_size)
	_draw_text("P %d|%d" % [tray["dirty_plates"], tray["ready_plates"]], rect.position + Vector2(6, 28 if not large else 38), TEXT_COLOR, font_size)
	_draw_text("G %d|%d" % [tray["dirty_glasses"], tray["ready_glasses"]], rect.position + Vector2(6, 40 if not large else 58), TEXT_COLOR, font_size)


func _draw_crate_slot() -> void:
	var crate_rect := Rect2(CRATE_SLOT_POS - Vector2(48, 48), Vector2(96, 96))
	var crate_fill_color := CRATE_COLOR
	if crate_fill > crate_capacity:
		crate_fill_color = WARNING_COLOR
	draw_rect(crate_rect, crate_fill_color if crate_installed else Color(0.44, 0.36, 0.28, 0.35), true)
	draw_rect(crate_rect, TABLE_EDGE_COLOR, false, 3.0)
	if crate_installed:
		draw_circle(crate_rect.position + Vector2(28, 24), 8.0, Color(0.95, 0.92, 0.83, 0.75))
		draw_circle(crate_rect.position + Vector2(50, 24), 8.0, Color(0.95, 0.92, 0.83, 0.75))
		_draw_meter(crate_rect.position + Vector2(10, 72), 76, float(crate_fill) / float(maxi(1, _overflow_limit(crate_capacity))), OK_COLOR)
		_draw_text("%d / %d" % [crate_fill, crate_capacity], crate_rect.position + Vector2(18, 60), TEXT_COLOR, 13)
	else:
		_draw_text("EMPTY", crate_rect.position + Vector2(18, 54), TEXT_COLOR, 13)


func _draw_liquid_bucket() -> void:
	var rect := Rect2(LIQUID_BUCKET_POS - Vector2(40, 46), Vector2(80, 92))
	var fill_color := Color(0.42, 0.62, 0.77) if liquid_bucket_enabled else Color(0.7, 0.7, 0.7, 0.45)
	if not liquid_bucket_installed:
		fill_color = Color(0.5, 0.5, 0.5, 0.35)
	elif liquid_bucket_fill > liquid_bucket_capacity and liquid_bucket_enabled:
		fill_color = WARNING_COLOR
	elif liquid_bucket_fill >= liquid_bucket_capacity and liquid_bucket_enabled:
		fill_color = Color(0.24, 0.42, 0.61)
	draw_rect(rect, fill_color, true)
	draw_rect(rect, TABLE_EDGE_COLOR, false, 3.0)
	if not liquid_bucket_enabled:
		_draw_text("OFF", rect.position + Vector2(22, 52), TEXT_COLOR, 13)
	elif not liquid_bucket_installed:
		_draw_text("AWAY", rect.position + Vector2(16, 52), TEXT_COLOR, 13)
	else:
		draw_line(rect.position + Vector2(18, 24), rect.position + Vector2(32, 18), Color(1, 1, 1, 0.6), 2.0)
		draw_line(rect.position + Vector2(32, 18), rect.position + Vector2(46, 24), Color(1, 1, 1, 0.6), 2.0)
		draw_line(rect.position + Vector2(46, 24), rect.position + Vector2(60, 18), Color(1, 1, 1, 0.6), 2.0)
		_draw_meter(rect.position + Vector2(10, 68), 60, float(liquid_bucket_fill) / float(maxi(1, _overflow_limit(liquid_bucket_capacity))), Color(0.18, 0.39, 0.69))
		_draw_text("%d / %d" % [liquid_bucket_fill, liquid_bucket_capacity], rect.position + Vector2(12, 56), TEXT_COLOR, 13)


func _draw_garbage_bin() -> void:
	var rect := Rect2(GARBAGE_POS - Vector2(52, 52), Vector2(104, 104))
	var fill_color := GARBAGE_COLOR
	if garbage_fill > garbage_capacity:
		fill_color = WARNING_COLOR
	elif garbage_fill >= garbage_capacity:
		fill_color = WARNING_COLOR
	elif garbage_state == "missing":
		fill_color = Color(0.5, 0.5, 0.5)
	draw_rect(rect, fill_color, true)
	draw_rect(rect, TABLE_EDGE_COLOR, false, 3.0)
	if garbage_state == "available":
		draw_line(rect.position + Vector2(26, 18), rect.position + Vector2(40, 8), Color(0.86, 0.86, 0.8, 0.8), 2.0)
		draw_line(rect.position + Vector2(54, 18), rect.position + Vector2(40, 8), Color(0.86, 0.86, 0.8, 0.8), 2.0)
		_draw_meter(rect.position + Vector2(12, 76), 80, float(garbage_fill) / float(maxi(1, _overflow_limit(garbage_capacity))), WARNING_COLOR)
		_draw_text("%d / %d" % [garbage_fill, garbage_capacity], rect.position + Vector2(18, 60), TEXT_COLOR, 13)
	else:
		_draw_text("NO BAG", rect.position + Vector2(16, 58), TEXT_COLOR, 14)


func _draw_return_rail() -> void:
	for index in range(2):
		var offset := Vector2(index * 10, -index * 6)
		var rect := Rect2(CLEAN_STACK_POS - Vector2(44, 22) + offset, Vector2(88, 44))
		draw_rect(rect, Color(0.85, 0.82, 0.78, 0.45), true)
		draw_rect(rect, TABLE_EDGE_COLOR, false, 2.0)
	_draw_text("EMPTY", CLEAN_STACK_POS + Vector2(-24, 6), TEXT_COLOR, 12)


func _draw_glass_rack() -> void:
	var rack_rect := Rect2(GLASS_RACK_POS - Vector2(48, 34), Vector2(96, 68))
	var fill_color := Color(0.7, 0.86, 0.92) if glass_rack_installed else Color(0.44, 0.36, 0.28, 0.35)
	draw_rect(rack_rect, fill_color, true)
	draw_rect(rack_rect, TABLE_EDGE_COLOR, false, 3.0)
	if not glasses_enabled:
		_draw_text("OFF", rack_rect.position + Vector2(28, 40), TEXT_COLOR, 13)
	elif glass_rack_installed:
		for glass_index in range(3):
			var glass_x := rack_rect.position.x + 18 + (glass_index * 22)
			draw_rect(Rect2(glass_x, rack_rect.position.y + 12, 10, 18), Color(1, 1, 1, 0.55), true)
			draw_rect(Rect2(glass_x + 3, rack_rect.position.y + 30, 4, 10), Color(1, 1, 1, 0.45), true)
		_draw_meter(rack_rect.position + Vector2(10, 48), 76, float(glass_rack_fill) / float(maxi(1, glass_rack_capacity)), Color(0.28, 0.54, 0.71))
		_draw_text("%d / %d" % [glass_rack_fill, glass_rack_capacity], rack_rect.position + Vector2(18, 36), TEXT_COLOR, 13)
	else:
		_draw_text("EMPTY", rack_rect.position + Vector2(18, 40), TEXT_COLOR, 13)


func _draw_kitchen_pit() -> void:
	var dirty_anchor := KITCHEN_RECT.position + Vector2(64, 118)
	var clean_anchor := KITCHEN_RECT.position + Vector2(168, 118)
	_draw_tray_stack_visual(dirty_anchor, dirty_tray_pit_count, DIRTY_TRAY_COLOR, "Dirty")
	_draw_tray_stack_visual(clean_anchor, clean_tray_stock, TRAY_EMPTY_COLOR, "Clean")


func _draw_tray_stack_visual(anchor: Vector2, count: int, tray_color: Color, label: String) -> void:
	if count <= 0:
		var empty_rect := Rect2(anchor - Vector2(34, 16), Vector2(68, 32))
		draw_rect(empty_rect, Color(1, 1, 1, 0.08), true)
		draw_rect(empty_rect, TABLE_EDGE_COLOR, false, 2.0)
	else:
		var visible_count := mini(count, 4)
		for index in range(visible_count):
			var offset := Vector2(index * 5, -index * 4)
			var rect := Rect2(anchor - Vector2(34, 16) + offset, Vector2(68, 32))
			draw_rect(rect, tray_color, true)
			draw_rect(rect, Color.WHITE if label == "Clean" else TABLE_EDGE_COLOR, false, 2.0)
			if label == "Dirty":
				draw_line(rect.position + Vector2(12, 10), rect.position + Vector2(28, 14), Color(0.89, 0.66, 0.28), 3.0)
	_draw_text("%s %d" % [label, count], anchor + Vector2(-28, 34), TEXT_COLOR, 12)


func _draw_waiters() -> void:
	for waiter in waiters:
		draw_circle(waiter["position"] + Vector2(0, 6), 18.0, Color(0, 0, 0, 0.12))
		draw_circle(waiter["position"], 18.0, WAITER_COLOR)
		draw_circle(waiter["position"], 18.0, TABLE_EDGE_COLOR, false, 2.0)
		if waiter["tray"] != null:
			var tray_rect := Rect2(waiter["position"] + Vector2(20, -16), Vector2(34, 24))
			draw_rect(tray_rect, TRAY_COLOR, true)
			draw_rect(tray_rect, Color.WHITE, false, 2.0)
		elif waiter.get("has_clean_tray", false):
			var clean_tray_rect := Rect2(waiter["position"] + Vector2(20, -16), Vector2(34, 24))
			draw_rect(clean_tray_rect, TRAY_EMPTY_COLOR, true)
			draw_rect(clean_tray_rect, TABLE_EDGE_COLOR, false, 2.0)
		if waiter["wait_time"] > 4.0 and _waiter_counts_toward_queue(waiter):
			_draw_text("!", waiter["position"] + Vector2(-4, -24), TEXT_COLOR, 18)


func _draw_player() -> void:
	draw_circle(player_position + Vector2(0, 8), 20.0, Color(0, 0, 0, 0.14))
	draw_circle(player_position, 20.0, PLAYER_COLOR)
	draw_circle(player_position, 20.0, TABLE_EDGE_COLOR, false, 2.0)
	draw_line(player_position, player_position + (player_facing.normalized() * 28.0), Color.WHITE, 3.0)
	_draw_carried_object()


func _draw_meter(position: Vector2, width: float, ratio: float, fill_color: Color) -> void:
	var outer := Rect2(position, Vector2(width, 10))
	draw_rect(outer, Color(0.12, 0.12, 0.12, 0.35), true)
	draw_rect(outer, Color.WHITE, false, 1.0)
	var inner_width: float = clampf(width * ratio, 0.0, width)
	if inner_width > 2.0:
		draw_rect(Rect2(position + Vector2.ONE, Vector2(inner_width - 2.0, 8)), fill_color, true)


func _draw_text(text: String, position: Vector2, color: Color, font_size: int = 14) -> void:
	draw_string(ThemeDB.fallback_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_carried_object() -> void:
	if carried_object == null:
		return

	var hold_offset := Vector2(0, -46)
	if player_facing != Vector2.ZERO:
		hold_offset += player_facing.normalized() * 12.0
	var hold_position := player_position + hold_offset

	match carried_object["type"]:
		"tray":
			var tray_rect := Rect2(hold_position - Vector2(28, 18), Vector2(56, 36))
			draw_rect(tray_rect, TRAY_COLOR, true)
			draw_rect(tray_rect, Color.WHITE, false, 2.0)
			_draw_text("TRAY", tray_rect.position + Vector2(8, 23), TEXT_COLOR, 12)
		"full_crate":
			var full_crate_rect := Rect2(hold_position - Vector2(22, 22), Vector2(44, 44))
			draw_rect(full_crate_rect, CRATE_COLOR, true)
			draw_rect(full_crate_rect, Color.WHITE, false, 2.0)
			_draw_meter(full_crate_rect.position + Vector2(6, 32), 32.0, 1.0, OK_COLOR)
		"empty_crate":
			var empty_crate_rect := Rect2(hold_position - Vector2(22, 22), Vector2(44, 44))
			draw_rect(empty_crate_rect, CRATE_COLOR.lightened(0.2), true)
			draw_rect(empty_crate_rect, Color.WHITE, false, 2.0)
			draw_rect(Rect2(empty_crate_rect.position + Vector2(7, 7), Vector2(30, 18)), Color(1, 1, 1, 0.08), true)
		"full_glass_rack":
			var full_glass_rack_rect := Rect2(hold_position - Vector2(24, 18), Vector2(48, 36))
			draw_rect(full_glass_rack_rect, Color(0.7, 0.86, 0.92), true)
			draw_rect(full_glass_rack_rect, Color.WHITE, false, 2.0)
			_draw_meter(full_glass_rack_rect.position + Vector2(6, 26), 36.0, 1.0, Color(0.28, 0.54, 0.71))
		"empty_glass_rack":
			var empty_glass_rack_rect := Rect2(hold_position - Vector2(24, 18), Vector2(48, 36))
			draw_rect(empty_glass_rack_rect, Color(0.84, 0.93, 0.97), true)
			draw_rect(empty_glass_rack_rect, Color.WHITE, false, 2.0)
		"full_liquid_bucket":
			var full_bucket_rect := Rect2(hold_position - Vector2(18, 22), Vector2(36, 44))
			draw_rect(full_bucket_rect, Color(0.24, 0.42, 0.61), true)
			draw_rect(full_bucket_rect, Color.WHITE, false, 2.0)
			draw_line(full_bucket_rect.position + Vector2(6, 4), full_bucket_rect.position + Vector2(30, 4), Color.WHITE, 2.0)
			_draw_meter(full_bucket_rect.position + Vector2(4, 30), 28.0, 1.0, Color(0.7, 0.88, 0.98))
		"empty_liquid_bucket":
			var empty_bucket_rect := Rect2(hold_position - Vector2(18, 22), Vector2(36, 44))
			draw_rect(empty_bucket_rect, Color(0.63, 0.74, 0.83), true)
			draw_rect(empty_bucket_rect, Color.WHITE, false, 2.0)
			draw_line(empty_bucket_rect.position + Vector2(6, 4), empty_bucket_rect.position + Vector2(30, 4), Color.WHITE, 2.0)
		"garbage_bag":
			draw_circle(hold_position + Vector2(0, 4), 18.0, GARBAGE_COLOR.lightened(0.12))
			draw_circle(hold_position + Vector2(0, 4), 18.0, Color.WHITE, false, 2.0)
			draw_line(hold_position + Vector2(-4, -10), hold_position + Vector2(0, -18), Color.WHITE, 2.0)
			draw_line(hold_position + Vector2(4, -10), hold_position + Vector2(0, -18), Color.WHITE, 2.0)


func _draw_world_prompts() -> void:
	for prompt in _gather_world_prompts():
		var prompt_position: Vector2 = prompt["position"]
		var prompt_text: String = prompt["text"]
		var accent: Color = prompt["accent"]
		_draw_prompt_bubble(prompt_position, prompt_text, accent)


func _gather_world_prompts() -> Array:
	var prompts: Array = []
	if game_state != "playing" or is_paused:
		return prompts

	var nearby_waiter: Variant = _nearby_waiter_with_tray(PROMPT_RANGE * 0.55)
	if carried_object == null and nearby_waiter != null:
		prompts.append(_make_prompt(nearby_waiter["position"] + Vector2(0, -42), "Space Take tray", PROMPT_SOFT_COLOR))

	if carried_object != null:
		match carried_object["type"]:
			"tray":
				if _tray_is_empty(carried_object["tray"]):
					var return_text := "Space Send tray" if _player_near(CLEAN_STACK_POS) else "Return tray here"
					prompts.append(_make_prompt(CLEAN_STACK_POS + Vector2(0, -56), return_text, OK_COLOR))
				else:
					var place_text := "Space Place tray" if _player_near(WORK_SLOT_POS) and work_tray == null else "Bring tray here"
					prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -76), place_text, Color(0.83, 0.76, 0.47)))
				var open_drop_slot: Variant = _nearby_open_drop_slot(PROMPT_RANGE)
				if open_drop_slot != null:
					prompts.append(_make_prompt(open_drop_slot["position"] + Vector2(0, -44), "Space Put tray back", PROMPT_SOFT_COLOR))
			"full_crate":
				var drop_text := "Space Drop crate" if _player_near(KITCHEN_POS) else "Bring crate here"
				prompts.append(_make_prompt(KITCHEN_POS + Vector2(0, -74), drop_text, OK_COLOR))
			"empty_crate":
				var install_text := "Space Install crate" if _player_near(CRATE_SLOT_POS) else "Bring crate back"
				prompts.append(_make_prompt(CRATE_SLOT_POS + Vector2(0, -76), install_text, OK_COLOR))
			"full_glass_rack":
				var glass_drop_text := "Space Drop rack" if _player_near(KITCHEN_POS) else "Bring rack here"
				prompts.append(_make_prompt(KITCHEN_POS + Vector2(0, -104), glass_drop_text, OK_COLOR))
			"empty_glass_rack":
				var glass_install_text := "Space Install rack" if _player_near(GLASS_RACK_POS) else "Bring rack back"
				prompts.append(_make_prompt(GLASS_RACK_POS + Vector2(0, -72), glass_install_text, OK_COLOR))
			"full_liquid_bucket":
				var bucket_dump_text := "Space Dump bucket" if _player_near(SINK_POS) else "Bring bucket here"
				prompts.append(_make_prompt(SINK_POS + Vector2(0, -70), bucket_dump_text, WARNING_COLOR))
			"empty_liquid_bucket":
				var bucket_return_text := "Space Return bucket" if _player_near(LIQUID_BUCKET_POS) else "Bring bucket back"
				prompts.append(_make_prompt(LIQUID_BUCKET_POS + Vector2(0, -72), bucket_return_text, OK_COLOR))
			"garbage_bag":
				var dump_text := "Space Dump bag" if _player_near(DISPOSAL_POS) else "Bring bag here"
				prompts.append(_make_prompt(DISPOSAL_POS + Vector2(0, -72), dump_text, WARNING_COLOR))
		return prompts

	var nearby_drop_slot: Variant = _nearby_filled_drop_slot(PROMPT_RANGE)
	if nearby_drop_slot != null:
		prompts.append(_make_prompt(nearby_drop_slot["position"] + Vector2(0, -44), "Space Pick up tray", PROMPT_SOFT_COLOR))
	if work_tray == null and _closest_filled_drop_slot_index(WORK_SLOT_POS) >= 0 and _player_near(WORK_SLOT_POS, 150.0):
		var hovered_slot_index := _hovered_drop_slot_index(true)
		if hovered_slot_index >= 0:
			prompts.append(_make_prompt(drop_off_slots[hovered_slot_index]["position"] + Vector2(0, -46), "Q Slide this tray", OK_COLOR))
		else:
			prompts.append(_make_prompt(Vector2((DROP_OFF_RECT.end.x + WORK_RECT.position.x) * 0.5, WORK_RECT.position.y + 30), "Hover tray + Q to slide", OK_COLOR))

	if work_tray != null and _player_near(WORK_SLOT_POS, PROMPT_RANGE):
		if work_tray["dirty_plates"] > 0 and _garbage_can_accept_more():
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -86), "E Scrape plate", WARNING_COLOR))
		elif work_tray["dirty_glasses"] > 0 and _liquid_bucket_can_accept_more():
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -86), "E Dump glass", OK_COLOR))
		elif work_tray["dirty_plates"] > 0 and garbage_state == "missing":
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -86), "Garbage full", WARNING_COLOR))
		elif work_tray["dirty_plates"] > 0:
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -86), "Garbage packed", WARNING_COLOR))
		elif work_tray["dirty_glasses"] > 0:
			var bucket_prompt := "Bucket blocked"
			if liquid_bucket_installed:
				bucket_prompt = "Bucket packed"
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -86), bucket_prompt, WARNING_COLOR))

		if work_tray["ready_plates"] > 0 and crate_installed and crate_fill < _overflow_limit(crate_capacity):
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -118), "F Put plate in crate", OK_COLOR))
		elif work_tray["ready_glasses"] > 0 and glass_rack_installed and glass_rack_fill < glass_rack_capacity:
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -118), "F Rack glass", OK_COLOR))
		elif work_tray["ready_plates"] > 0:
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -118), "Crate blocked", WARNING_COLOR))
		elif work_tray["ready_glasses"] > 0:
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -118), "Glass rack blocked", WARNING_COLOR))
		if _tray_is_empty(work_tray):
			prompts.append(_make_prompt(WORK_SLOT_POS + Vector2(0, -86), "Space Pick up tray", PROMPT_SOFT_COLOR))

	if crate_installed and crate_fill >= crate_capacity and _player_near(CRATE_SLOT_POS, PROMPT_RANGE):
		prompts.append(_make_prompt(CRATE_SLOT_POS + Vector2(0, -76), "Space Carry crate", OK_COLOR))
	if not crate_installed and kitchen_empty_crates > 0 and _player_near(KITCHEN_POS, PROMPT_RANGE):
		prompts.append(_make_prompt(KITCHEN_POS + Vector2(0, -74), "Space Take empty crate", OK_COLOR))
	if glasses_enabled and glass_rack_installed and glass_rack_fill >= glass_rack_capacity and _player_near(GLASS_RACK_POS, PROMPT_RANGE):
		prompts.append(_make_prompt(GLASS_RACK_POS + Vector2(0, -72), "Space Carry rack", OK_COLOR))
	if glasses_enabled and not glass_rack_installed and kitchen_empty_glass_racks > 0 and _player_near(KITCHEN_POS, PROMPT_RANGE):
		prompts.append(_make_prompt(KITCHEN_POS + Vector2(0, -104), "Space Take empty rack", OK_COLOR))
	if liquid_bucket_enabled and liquid_bucket_installed and liquid_bucket_fill > 0 and _player_near(LIQUID_BUCKET_POS, PROMPT_RANGE):
		prompts.append(_make_prompt(LIQUID_BUCKET_POS + Vector2(0, -72), "Space Lift bucket", WARNING_COLOR))
	if garbage_state != "missing" and garbage_fill > 0 and _player_near(GARBAGE_POS, PROMPT_RANGE):
		prompts.append(_make_prompt(GARBAGE_POS + Vector2(0, -76), "Space Lift bag", WARNING_COLOR))

	return prompts


func _make_prompt(position: Vector2, text: String, accent: Color) -> Dictionary:
	return {
		"position": position,
		"text": text,
		"accent": accent,
	}


func _draw_prompt_bubble(position: Vector2, text: String, accent: Color) -> void:
	var font_size := 13
	var bubble_width: float = maxf(120.0, (float(text.length()) * 7.2) + 18.0)
	var rect := Rect2(position - Vector2(bubble_width * 0.5, 18), Vector2(bubble_width, 26))
	draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size), Color(0, 0, 0, 0.12), true)
	draw_rect(rect, PROMPT_BG_COLOR, true)
	draw_rect(rect, accent, false, 2.0)
	draw_line(position + Vector2(0, 8), position + Vector2(-6, 2), accent, 2.0)
	draw_line(position + Vector2(0, 8), position + Vector2(6, 2), accent, 2.0)
	_draw_text(text, rect.position + Vector2(10, 18), PROMPT_TEXT_COLOR, font_size)
