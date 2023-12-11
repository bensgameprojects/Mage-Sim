extends Node

## Signal emitted when the player places a thing, passing the object and its
## position in map coordinates
signal thing_placed(thing, cellv)

## Signal emitted when the player removes a thing, passing the object and its
## position in map coordinates
signal thing_removed(thing, cellv)

# Signal emitted when the simulation triggers the systems for updates
signal systems_ticked(delta)

#Signal emitted when a level change is needed
signal change_level(destination_scene_name)

#Signal emitted when the player dies so systems can update
signal player_died

signal respawn_player

signal display_value(value, damage_type, player_position)

signal death_effect(position)

# Signal emitted by the quickwheels whenever a new ability
# is selected. Will send the action button and the
# corresponding ability name
signal update_action(action, ability)

# Signal to assign a given quickwheel slot to the selected spell
signal assign_quickwheel(slot_name, selected_spell)

# signal to place a blueprint, given the blueprint packed scene
signal place_blueprint(thing_id)

# emitted when cell is hovered over sends the thing in that cell
signal hovered_over_thing(thing)

#building config sends this signal when opened to request the thing that 
# the player is facing (if any)
signal get_player_facing_thing

# emitted when player is facing a thing
signal player_facing_thing(thing)

# emitted by things when they are updated for tracking/display
signal info_updated(thing)

signal notify_player(notification)

#emitted when an item is to be spawned.
# requestor_node is the node who called the emit_signal so it can
# receive the created item's reference if it wants. null otherwise
signal spawn_item(item_id, item_count, position, requestor_node)

signal spawn_item_on_player(item_id, item_count)

signal interact_entered_range(interact_component)

signal interact_exited_range(interact_component)

signal player_pickup_item(item_id, item_count)

#something wants to spawn a spell
signal spawn_spell(spell, initial_position, global_mouse_pos, caster)
