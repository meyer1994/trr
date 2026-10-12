class_name LootTable
extends Resource

@export var entries: Array[LootEntry] = []
## Minimum and maximum number of items a chest gets.
@export var rolls := Vector2i(2, 4)


func roll(rng: RandomNumberGenerator) -> Array[ItemStack]:
	var weights := PackedFloat32Array()
	for entry in entries:
		weights.append(entry.weight)
	var stacks: Array[ItemStack] = []
	for i in rng.randi_range(rolls.x, rolls.y):
		stacks.append(ItemStack.new(entries[rng.rand_weighted(weights)].item))
	return stacks
