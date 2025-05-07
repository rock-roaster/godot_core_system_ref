extends RefCounted
class_name MathTools


# 得到整数的位数
static func get_digits(value: int) -> int:
	if value == 0: return 1
	var value_abs: int = absi(value)
	var value_log: float = log(value_abs) / log(10)
	return int(value_log) + 1


# 求两矢量间的夹角
static func get_vector_angle(v1: Vector2, v2: Vector2) -> float:
	return acos(v1.dot(v2))


# 求两矢量间的夹角角度
static func get_vector_angle_degree(v1: Vector2, v2: Vector2) -> float:
	var vector_angle: float = get_vector_angle(v1, v2)
	return rad_to_deg(vector_angle)


# 求两角度间的夹角
static func get_cross_angle(a1: float, a2: float) -> float:
	var vector1: Vector2 = Vector2.from_angle(a1)
	var vector2: Vector2 = Vector2.from_angle(a2)
	return get_vector_angle(vector1, vector2)


# 求两角度间的夹角角度
static func get_cross_angle_degree(a1: float, a2: float) -> float:
	var vector1: Vector2 = Vector2.from_angle(a1)
	var vector2: Vector2 = Vector2.from_angle(a2)
	return get_vector_angle_degree(vector1, vector2)
