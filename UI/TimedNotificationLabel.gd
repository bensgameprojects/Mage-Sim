extends Label

onready var timer = $Timer
var notification_type : int
var params: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_timer():
	return timer

func setup(type: int, param_dict: Dictionary):
	notification_type = type
	params = param_dict

func is_match(type: int, param_dict: Dictionary) -> bool:
	if notification_type == type:
		# now match the appropriate keys.
		for key in params.keys():
			if key != "time_left":
				if param_dict.has(key):
					if params[key] != param_dict[key]:
						return false
				else:
					return false
	return true

func build_notification() -> String:
	var notification_string : String = ""
	match notification_type:
		NotificationTypes.Notifications.CANT_AFFORD_BUILDING:
			if params.has("building_id"):
				var building_info = BuildingList.get_building_by_id(params.get("building_id"))
				notification_string = "Unable to afford " + building_info["name"] + "! Costs " + RecipeList.build_requirements_string(building_info) + "."
		NotificationTypes.Notifications.CANT_AFFORD_SPELL:
			if params.has("spell_id"):
				notification_string = "Unable to afford " + params.get("spell_id") + "! Costs " + RecipeList.build_requirements_string(params.get("spell_id")) + "."
		NotificationTypes.Notifications.ITEM_PICKUP:
			if params.has_all(["item_id", "amount"]):
				notification_string = "Picked up " + str(params.get("amount")) + " " + ItemsList.get_item_name_by_id(params.get("item_id")) + "!"
		NotificationTypes.Notifications.ON_GCD_COOLDOWN:
			if params.has_all(["spell_id", "time_left"]):
				notification_string = "Can't cast " + params.get("spell_id") + "! Spell on cooldown for %.2f more seconds." % params.get("time_left")
		NotificationTypes.Notifications.IS_STUNNED:
			if params.has_all(["spell_id", "time_left"]):
				notification_string = "Unable to cast " + params.get("spell_id") + "! Stunned for %.2f more seconds." % params.get("time_left")
	return notification_string
