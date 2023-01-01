extends Node

## Signal emitted when the player places a thing, passing the object and its
## position in map coordinates
signal thing_placed(thing, cellv)

## Signal emitted when the player removes a thing, passing the object and its
## position in map coordinates
signal thing_removed(thing, cellv)

# Signal emitted when the simulation triggers the systems for updates
signal systems_ticked(delta)

#Signal emitted when the player dies so systems can update
#TODO: on_death/respawn_ui and respawn function in player.gd
signal player_died(player)

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

# emitted when player is facing a thing
signal player_facing_thing(thing)

# emitted by things when they are updated for tracking/display
signal info_updated(thing)
