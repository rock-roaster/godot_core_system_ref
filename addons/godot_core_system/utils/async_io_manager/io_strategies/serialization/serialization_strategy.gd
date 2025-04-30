extends RefCounted

## Abstract method to serialize data into bytes.
func serialize(data: Variant) -> PackedByteArray:
	System.logger.error("SerializationStrategy.serialize() must be implemented by subclasses.")
	return PackedByteArray()

## Abstract method to deserialize bytes into data.
func deserialize(bytes: PackedByteArray) -> Variant:
	System.logger.error("SerializationStrategy.deserialize() must be implemented by subclasses.")
	return null
