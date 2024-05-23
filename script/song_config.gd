# song_config.gd
class_name SongConfig extends Window

'''
Configues the song selection for a level
'''

## 1.0.0's list of music names
const music : Array[String] = [
	## Vanilla, 14 tracks
	"Bob-omb Battlefield",
	"Slider",
	"Dire, Dire Docks",
	"Dire, Dire Docks (Underwater)",
	"Lethal Lava Land",
	"Cool, Cool Mountain",
	"Big Boo's Haunt",
	"Hazy Maze Cave",
	"Hazy Maze Cave (Haze)",
	"Koopa's Road",
	"Stage Boss",
	"Koopa's Theme",
	"Ultimate Koopa",
	"Inside the Castle Walls",
	
	## BTCM, also 14 tracks
	"Cosmic Castle",
	"Red-Hot Reservoir",
	"Lonely Floating Farm",
	"Jurassic Savanna",
	"The Phantom Strider",
	"Virtuaplex",
	"Immense Residence",
	"Thwomp Towers",
	"Cursed Boss",
	"Road To The Boss",
	"Urbowser",
	"The Show's Finale",
	"Parasite Moon",
	"AGAMEMNON",
	
	## Imports, 68 tracks
	"Bianco Hills (Super Mario Sunshine)",
	"Sky and Sea (Super Mario Sunshine)",
	"Secret Course (Super Mario Sunshine)",
	"Comet Observatory (Mario Galaxy)",
	"Buoy Base Galaxy (Mario Galaxy)",
	"Battlerock Galaxy (Mario Galaxy)",
	"Ghostly Galaxy (Mario Galaxy)",
	"Purple Comet (Mario Galaxy)",
	"Honeybloom Galaxy (Mario Galaxy 2)",
	"Piranha Creeper Creek (3D World)",
	"Desert (New Super Mario Bros.)",

	"Koopa Troopa Beach (Mario Kart 64)",
	"Frappe Snowland (Mario Kart 64)",
	"Bowser's Castle (Mario Kart 64)",
	"Rainbow Road (Mario Kart 64)",
	"Waluigi Pinball (Mario Kart DS)",
	"Rainbow Road (Mario Kart 8)",

	"Mario's Pad (Super Mario RPG)",
	"Nimbus Land (Super Mario RPG)",
	"Forest Maze (Super Mario RPG)",
	"Sunken Ship (Super Mario RPG)",

	"Dry Dry Desert (Paper Mario 64)",
	"Forever Forest (Paper Mario 64)",
	"Petal Meadows (Paper Mario: TTYD)",
	"Riddle Tower (Paper Mario: TTYD)",
	"Rogueport Sewers (Paper Mario: TTYD)",
	"X-Naut Fortress (Paper Mario: TTYD)",
	"Flipside (Super Paper Mario)",
	"Lineland Road (Super Paper Mario)",
	"Sammer Kingdom (Super Paper Mario)",
	"Floro Caverns (Super Paper Mario)",
	"Overthere Stair (Super Paper Mario)",

	"Yoshi's Tropical Island (Mario Party)",
	"Rainbow Castle (Mario Party)",
	"Behind Yoshi Village (Partners in Time)",
	"Gritzy Desert (Partners in Time)",
	"Bumpsy Plains (Bowser's Inside Story)",
	"Deep Castle (Bowser's Inside Story)",

	"Overworld (Yoshi's Island)",
	"Underground (Yoshi's Island)",
	"Title (Yoshi's Story)",

	"Kokiri Forest (Ocarina of Time)",
	"Lost Woods (Ocarina of Time)",
	"Gerudo Valley (Ocarina of Time)",
	"Stone Tower Temple (Majora's Mask)",
	"Outset Island (Wind Waker)",
	"Lake Hylia (Twilight Princess)",
	"Gerudo Desert (Twilight Princess)",
	"Skyloft (Skyward Sword)",

	"Frantic Factory (Donkey Kong 64)",
	"Hideout Helm (Donkey Kong 64)",
	"Creepy Castle (Donkey Kong 64)",
	"Gloomy Galleon (Donkey Kong 64)",
	"Fungi Forest (Donkey Kong 64)",
	"Crystal Caves (Donkey Kong 64)",
	"Angry Aztec (Donkey Kong 64)",
	"In a Snow-Bound Land (DKC 2)",

	"Bubblegloop Swamp (Banjo-Kazooie)",
	"Freezeezy Peak (Banjo-Kazooie)",
	"Gobi's Valley (Banjo-Kazooie)",

	"Factory Inspection (Kirby 64)",
	"Green Garden (Bomberman 64)",
	"Black Fortress (Bomberman 64)",
	"Windy Hill (Sonic Adventure)",
	"Sky Tower (Pokemon Mystery Dungeon)",
	"Youkai Mountain (Touhou 10)",
	"Forest Temple (Final Fantasy VII)",
	# "Band Land is love, Band Land is life" I say, shovelling dry ass chalk 
	# into my mouth, similar to that of a derranged lunatic
	"Band Land (Rayman)", 
	
	## Retro, 7 tracks
	"Overworld (Super Mario Bros.)",
	"Castle Mix (Super Mario Bros.)",
	"Overworld (Super Mario Bros. 2)",
	"Overworld Mix (Super Mario Bros. 3)",
	"Fortress (Super Mario Bros. 3)",
	"Athletic (Super Mario World)",
	"Castle (Super Mario World)",
]

## Points to define a parent group
const points : Array[int] = [
	0,
	14,
	28,
	96
]

## Number of songs in each category
const song_count : Array[int] = [
	14,
	14,
	68,
	7
]

## Category names
const category : Array[String] = [
	"Super Mario 64 OST",
	"Beyond the Cursed Mirror OST",
	"ROM Hack Music Ports",
	"Retro 2D Mario Music"
]

## Dropdown names
const dropdown_names : Array[String] = [
	"Level Song - %s",
	"Race Song - %s",
	"Boss Song - %s"
]

## Current [MB64Level] resource
var current_res : MB64Level :
	set(value) : current_res = value; prepare_backup(); update_fields()
	get : return current_res
## Backup fields
var backup_fields : Array[int]

func _ready() -> void:
	visibility_changed.connect(update_fields.bind())

## Updates dropdown and tree view of songs
func update_fields() -> void:
	update_tree()
	update_categories()

## Update song list
func update_tree() -> void:
	# Prepare tree
	%list.clear()
	var root : TreeItem
	var category_item : TreeItem
	
	# Create root item
	root = %list.create_item(null)
	root.set_text(0, "Songs")
	
	# Update tree
	for index in range(music.size()):
		for point in range(points.size()):
			if index == points[point]:
				category_item = %list.create_item(root, index) as TreeItem
				category_item.set_text(0, category[point])
				break
		var item = %list.create_item(category_item, index) as TreeItem
		item.set_text(0, music[index])

## Update song categories
func update_categories() -> void:
	# Iterate
	for index in range(dropdown_names.size()):
		%type.set_item_text(index, dropdown_names[index] % music[backup_fields[index]])

## Prepares backup fields
func prepare_backup() -> void:
	backup_fields.clear()
	for track in range(current_res.music.size()):
		backup_fields.append(current_res.music[track])

## Called when user selects song
func song_selected() -> void:
	var item : TreeItem = %list.get_selected()
	if item.get_parent() == %list.get_root():
		return
	var song_idx : int = item.get_index()
	var category_idx : int = item.get_parent().get_index()
	backup_fields[%type.selected] = points[category_idx] + song_idx
	update_categories()
	
## Called when dropdown selection is changed
func dropdown_changed(index : int) -> void:
	var selection = byte_to_index(backup_fields[index])
	var target : TreeItem = %list.get_root().get_child(selection[0]).get_child(selection[1])
	target.select(0)
	%list.scroll_to_item(target, true)

## Called when user requests to apply data change
func apply_pressed() -> void:
	current_res.music = backup_fields
	hide()

## Called when user denies data change
func cancel_pressed() -> void:
	backup_fields.clear()
	hide()

## Converts byte song id to album and song index
func byte_to_index(byte : int) -> Array[int]:
	var index : Array[int] = [0, 0]
	var song : int = byte 
	
	for x in range(song_count.size()):
		if song <= song_count[x]:
			index[0] = x
			index[1] = song
			break
		song -= song_count[x]
	return index
