extends "./serialization_strategy.gd"


func serialize(data: Variant) -> PackedByteArray:
	var json_str: String = JSON.stringify(data, "\t", false)
	if json_str.is_empty() and data != null:
		System.logger.error("Failed to serialize data to JSON: %s" % str(data))
	return json_str.to_utf8_buffer()


func deserialize(bytes: PackedByteArray) -> Variant:
	var json_str: String = bytes.get_string_from_utf8()
	if json_str.is_empty() and bytes.size() > 0:
		# Handle cases where non-utf8 bytes might result in empty string
		System.logger.error("Could not decode bytes as UTF8 string for JSON deserialization.")
		return null
	if json_str.is_empty() and bytes.size() == 0:
		# Handle empty input gracefully (e.g., return empty dict or null)
		return null

	var json: JSON = JSON.new()
	var error: Error = json.parse(json_str)
	if error == OK:
		return json.get_data()
	else:
		System.logger.error("JSON parsing error: %s (Line: %d)" % [json.get_error_message(), json.get_error_line()])
		return null
