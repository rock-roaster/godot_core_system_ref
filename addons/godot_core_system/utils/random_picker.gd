extends RefCounted
class_name RandomPicker


var _remove_after_pick: bool
var _item_pool: Array[RandomItem]


func _init(remove_after_pick: bool = false) -> void:
	_remove_after_pick = remove_after_pick


func add_item(
	item_data: Variant,
	item_weight: int = 1,
	item_remove: bool = _remove_after_pick,
) -> RandomItem:
	var new_item: RandomItem = RandomItem.new(
		item_data,
		item_weight,
		item_remove,
	)
	_item_pool.append(new_item)
	return new_item


func pick_item() -> RandomItem:
	var pick_pool: Array[RandomItem] = []
	for item in _item_pool:
		for i in item.item_weight:
			pick_pool.append(item)

	var new_item: RandomItem = pick_pool.pick_random() as RandomItem
	if new_item != null && new_item.remove_after_pick:
		_item_pool.erase(new_item)
	return new_item


class RandomItem:
	var item_data: Variant
	var item_weight: int
	var remove_after_pick: bool

	func _init(
		_item_data: Variant,
		_item_weight: int = 1,
		_item_remove: bool = false,
	) -> void:
		item_data = _item_data
		item_weight = clampi(_item_weight, 1, _item_weight)
		remove_after_pick = _item_remove

	func get_data() -> Variant:
		return item_data
