extends Node

signal stage_started(waves, wave_times)

# player signals

signal attack_mode_changed(mode)
signal player_died()

signal world_advanced(world: int)

signal enemy_died()
