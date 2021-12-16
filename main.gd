extends FileDialog
const save_path := "user://match info/"
const asdf: String = "asdf"

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

static func has_children(node: Node) -> bool:
	return node.get_child_count() > 0

func _init() -> void:
	var userdir := Directory.new()
	if userdir.open(save_path) != OK:
		userdir.make_dir_recursive(save_path)

func _ready():
	get_tree().connect("screen_resized", self, "deeznuts")
	show()
	prune_irrelevant_nodes(get_child(2))

static func prune_irrelevant_nodes(hbox: HBoxContainer) -> void:
	for i in 3:
		hbox.get_child(i + 2).queue_free()
	hbox.get_child(0).queue_free()
	hbox.set_alignment(BoxContainer.ALIGN_CENTER)

func on_file_selected(path: String):
	var file := File.new()
	file.open(path, File.READ)
	write_files(file.get_as_text(), path.get_basename() + "/")
	call_deferred("show")
