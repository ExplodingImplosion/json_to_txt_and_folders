extends FileDialog

const save_path := "user://match info/"

## match DTO
#const match_info_path := save_path + "match info/"
#const matchid_path := save_path + "match id.txt"
#const mapid_path := save_path + "map id.txt"
##const gamelengthms_path
##const gamestartms_path
##const provisioningflowid_path
##const iscompleted_path
##const custom_game_name_path
##const queueid_path
#const gamemode_path := save_path + ".txt"
##const isRanked_path := save_path + ".txt"
##const seasonid_path := save_path + ".txt"
#
#const player_info_path := save_path + "player info/%s%s"
#
## if these dont get used im finna be pissed
#static func get_player_filepath(idx: int) -> String: return player_info_path%[idx, "/"]
#static func puuid(idx: int) -> String: return get_player_filepath(idx)%["puuid.txt"]
#static func gameName(idx: int) -> String: return get_player_filepath(idx)%["gameName.txt"]
#static func tagLine(idx: int) -> String: return get_player_filepath(idx)%["tagLine.txt"]
#static func teamId(idx: int) -> String: return get_player_filepath(idx)%["teamId.txt"]
#static func partyId(idx: int) -> String: return get_player_filepath(idx)%["partyId.txt"]
#static func characterId(idx: int) -> String: return get_player_filepath(idx)%["characterId.txt"]
#static func statsfolder(idx: int) -> String: return get_player_filepath(idx)%["statsfolder/"]
#static func competitiveTier(idx: int) -> String: return get_player_filepath(idx)%["competitiveTier.txt"]
#static func playerCard(idx: int) -> String: return get_player_filepath(idx)%["playerCard.txt"]
#static func playerTitle(idx: int) -> String: return get_player_filepath(idx)%["playerTitle.txt"]

const asdf: String = "asdf"

const test_json := {
	"matchinfo": {
		"matchid": asdf,
		"mapid": asdf,
		"gamelenght": 22,
		"gamestart": 22,
		"provisioningflowid": asdf,
		"iscompleted": true,
		"customgamename": asdf,
		"queueid": asdf,
	},
	"players": [
		{
			puuid = asdf,
			gameName = asdf,
			tagLine = asdf,
			teamID = asdf,
			partyID = asdf,
			characterID = asdf,
			stats = {
				score = 5,
				roundsplayerd = 5,
				kills = 5,
				deaths = 5,
				assists = 5,
				playtimeMS = 5,
				abilcasts = {
					grenadeCasts = 5,
					abil1Casts = 5,
					abil2Casts = 5,
					ultCasts = 5
				}
			},
			comptier = 5,
			playercard = asdf,
			playertitle = asdf,
		},
	],
	"coaches": asdf,
	"teams": asdf,
	"roundResults": asdf,
	
}

static func write_files(json: String, path: String) -> void:
	var result = JSON.parse(json).get_result()
	if result:
		var dict: Dictionary = result
		parse_dictionary(dict, save_path + path)
	else:
		print("not a json file!")

static func parse_dictionary(dict: Dictionary, path: String) -> void:
	for key in dict:
		if dict[key] is Dictionary:
			parse_dictionary(dict[key], path+key+"/")
		elif dict[key] is Array:
			parse_array(dict[key], path+key+"/")
		else:
			Directory.new().make_dir_recursive(path)
			parse_txt(str(dict[key]), path+key+".txt")

static func parse_array(array: Array, path: String) -> void:
	for idx in array.size():
		if array[idx] is Dictionary:
			parse_dictionary(array[idx], "%s%s/"%[path,idx])
		elif array[idx] is Array:
			parse_array(array[idx],"%s%s/"%[path,idx])
		else:
			Directory.new().make_dir_recursive(path)
			parse_txt(str(array[idx]),"%s%s.txt"%[path,idx])

static func new_folder_at_path(path: String, dirname: String) -> String:
	var newdir := Directory.new()
	newdir.open(path)
	newdir.make_dir(dirname)
	return path + dirname

static func parse_txt(value: String, path: String) -> void:
	print(path + " " + value)
	var file := File.new()
	file.open(path, File.WRITE)
	file.store_string(value)
	file.close()

func deeznuts() -> void:
	_set_size(OS.get_window_size())

static func read_child_names(node: Node) -> void:
	for child in node.get_children():
		print(child.name)
		if has_children(child):
			read_child_names(child)

static func has_children(node: Node) -> bool:
	return node.get_child_count() > 0


func _init() -> void:
	var userdir := Directory.new()
	if userdir.open(save_path) != OK:
		userdir.make_dir_recursive(save_path)

func _ready():
	get_tree().connect("screen_resized", self, "deeznuts")
	show()
	if OS.is_debug_build():
		set_access(FileDialog.ACCESS_RESOURCES)
#	read_child_names(self)
#	get_cancel().queue_free()
	prune_irrelevant_nodes(get_first_hbox())
	if OS.is_debug_build():
		write_files(JSON.print(test_json), "test json/")

#func _physics_process(delta: float) -> void:
#	var deez := get_first_hbox().get_child(0).get_signal_connection_list("pressed")
##	get_incoming_connections()
#	if deez.size() > 1:
#		print(deez)

static func prune_irrelevant_nodes(hbox: HBoxContainer) -> void:
	for i in 3:
		hbox.get_child(i + 2).queue_free()
	hbox.get_child(0).queue_free()
	hbox.set_alignment(BoxContainer.ALIGN_CENTER)

func get_first_hbox() -> HBoxContainer:
	return get_child(2) as HBoxContainer

func get_cancel() -> Button:
	return get_first_hbox().get_child(3) as Button

func on_file_selected(path: String):
	var file := File.new()
	file.open(path, File.READ)
	write_files(file.get_as_text(), path.get_basename() + "/")
	call_deferred("show")
