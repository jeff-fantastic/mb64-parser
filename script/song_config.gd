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
var backup_fields : PackedByteArray

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
				category_item = %list.create_item(root) as TreeItem
				category_item.set_text(0, category[point])
				break
		var item = %list.create_item(category_item, index) as TreeItem
		item.set_text(0, music[index])

## Update song categories
func update_categories() -> void:
	# Prepare dropdown
	%type.clear()
	
	# Iterate
	for label in dropdown_names:
		%type.add_item(label % music[current_res.music.decode_u8(%type.item_count)])

## Prepares backup fields
func prepare_backup() -> void:
	backup_fields = current_res.music

## Generates tree list of songs
func generate_tree() -> void:
	pass

## Called when dropdown selection is changed
func dropdown_changed() -> void:
	pass

## Called when user requests to apply data change
func apply_pressed() -> void:
	pass

## Called when user denies data change
func cancel_pressed() -> void:
	pass
