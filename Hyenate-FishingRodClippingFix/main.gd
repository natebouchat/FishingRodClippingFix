extends Node

onready var PlayerAPI := $"/root/BlueberryWolfiAPIs/PlayerAPI"
onready var TackleBox := $"/root/TackleBox"

const MOD_ID = "Hyenate.FishingRodClippingFix"
var config: Dictionary
var default_config: Dictionary = {
	"X_rotation": 0,
	"Y_rotation": 5,
	"Z_rotation": 18}

var player_held_items

func _ready():
	PlayerAPI.connect("_player_added", self, "init_player")
	_init_config()
	TackleBox.connect("mod_config_updated", self, "_on_config_update")

func init_player(player: Actor):
	# Connect Signal for changes in held items
	player_held_items = player.get_node("body/player_body/Armature/Skeleton/BoneAttachment")
	player_held_items.connect("child_entered_tree", self, "rotate_fishing_rod")
	
func _init_config() -> void:
	var saved_config = TackleBox.get_mod_config(MOD_ID)

	for key in default_config.keys():
		if not saved_config[key]: # If the config property isn't saved...
			saved_config[key] = default_config[key] # Set it to the default
	
	config = saved_config
	TackleBox.set_mod_config(MOD_ID, config) # Save it to a config file!

func _on_config_update(mod_id: String, new_config: Dictionary) -> void:
	if mod_id != MOD_ID: # Check if it's our mod being updated
		return
	if config.hash() == new_config.hash(): # Check if the config is different
		return
	
	config = new_config # Set the local config variable to the updated config

func rotate_fishing_rod(node: Node):
	# If node has fishing rod script, node is a fishing rod.
	if "fishing_rod.gd" in node.get_script().get_path():
		node.rotation_degrees = Vector3(config["X_rotation"],
										config["Y_rotation"],
										config["Z_rotation"])
