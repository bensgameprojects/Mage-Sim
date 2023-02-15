extends Node

# has types of notifications for the notificationUI to build strings with.
enum Notifications {
	ITEM_PICKUP, ITEM_DROPPED, CANT_AFFORD_SPELL, CANT_AFFORD_BUILDING, ON_GCD_COOLDOWN,
	ON_SPELL_COOLDOWN, IS_STUNNED,
}

# returns the keys that the params dictionary must have to be valid for the given notification type
func get_param_keys(notification_type: int) -> Array:
	match notification_type:
		Notifications.ITEM_PICKUP, Notifications.ITEM_DROPPED:
			return ["item_id", "amount"]
		Notifications.CANT_AFFORD_SPELL:
			return ["spell_id"]
		Notifications.CANT_AFFORD_BUILDING:
			return ["building_id"]
		Notifications.IS_STUNNED, Notifications.ON_GCD_COOLDOWN, Notifications.ON_SPELL_COOLDOWN:
			return ["spell_id", "time_left"]
		_:
			return []
