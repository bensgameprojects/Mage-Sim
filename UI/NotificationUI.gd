extends MarginContainer

# The amount of time a notification will be displayed for in seconds
const DISPLAY_TIME = 3
# The max number of notifications to display at once
const MAX_LABELS = 5

var notification_labels : Array
onready var notification_vbox = $VBoxContainer
var notification_scene = preload("res://UI/TimedNotificationLabel.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	var error = Events.connect("notify_player", self, "_on_notify_player")
	if error != OK:
		printerr("NotificationUI could not connect to the global Events notify_player signal! Crashing gracefully :)")
		assert(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_notify_player(notification_type: int, params: Dictionary):
	# If there isn't a matching notification already then 
	if not update_matching_notification(notification_type, params):
		# If there are too many labels, remove the oldest before adding the
		# new notification
		if notification_vbox.get_child_count() >= MAX_LABELS:
			remove_oldest_notification()
		add_notification(notification_type, params)

# Finds the first empty label if there is one
func find_empty_label() -> Label:
	for label in notification_labels:
		if label.text.empty():
			return label
	return null

# Tries to find a matching label to the given notification string
# If it finds it, it rmeoves it and adds a new refreshed notification and returns true
# If it doesn't find a match it returns false
func update_matching_notification(notification_type: int, params: Dictionary) -> bool:
	# short these types since duplicates are always separate events.
	if notification_type == NotificationTypes.Notifications.ITEM_DROPPED or notification_type == NotificationTypes.Notifications.ITEM_PICKUP:
		return false
	for notification_label in notification_vbox.get_children():
		if notification_label is Label and notification_label.is_match(notification_type, params):
			remove_notification(notification_label)
			add_notification(notification_type, params)
			return true
	return false

# Adds a timed notification to the notification_vbox
func add_notification(notification_type: int, params: Dictionary):
	# make a new notification, assign the label and start the timer.
	var new_notification = notification_scene.instance()
	new_notification.setup(notification_type, params)
	notification_vbox.add_child(new_notification)
	new_notification.text = new_notification.build_notification()
	new_notification.show()
	var timer = new_notification.get_timer()
	timer.connect("timeout", self, "_on_display_timer_timeout", [new_notification], CONNECT_ONESHOT)
	timer.start(DISPLAY_TIME)

func remove_notification(notification_label: Label):
	# remove the notification from the vbox and delete it
	notification_vbox.remove_child(notification_label)
	notification_label.queue_free()

# Removes the oldest notification which should be the first 
# child of notification_vbox that is a label
func remove_oldest_notification():
	for notification_label in notification_vbox.get_children():
		if notification_label is Label:
			remove_notification(notification_label)
			return

func _on_display_timer_timeout(notification_label: Label):
	remove_notification(notification_label)


