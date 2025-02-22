class_name SpawnResource extends Resource

@export var enemy: PackedScene

@export_group("Position")
# The lane the enemy will spawn in. [0, 4]
@export_range(0, 4) var lane: int = 2
# The time from the wave starts, to this enemy will spawn.
@export var time_offest: float = 0 
