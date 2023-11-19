extends Control


@export var throwableTexture : TextureRect
@export var throwableTexture2 : TextureRect
@export var weaponTexture : TextureRect
@export var crosshairTexture : TextureRect
@export var magLabel : Label
@export var ammoLabel : Label
@export var weaponNameLabel : Label

@export var player : Player


func _ready() -> void:
		var weaponController = player.get_node("%Weapon Holder")
		weaponController.connect("update_gui", _update_gui)


func _update_gui(crosshair: Texture, weaponIcon: Texture, magSize: int, ammo: int, weaponName: String) -> void:
	magLabel.text = str(magSize)
	ammoLabel.text = str(ammo)
	weaponNameLabel.text = weaponName
	
	if crosshair != null:
		crosshairTexture.texture = crosshair
	if weaponIcon != null:
		weaponTexture.texture = weaponIcon

