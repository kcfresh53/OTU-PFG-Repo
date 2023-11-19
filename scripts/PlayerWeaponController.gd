extends Marker3D
class_name WeaponHolder


var hasWeapon : bool = false

# ammo types cuz inventory hard...
var lightAmmo : int = 100
var mediumAmmo : int = 100
var heavyAmmo : int = 100
var shotgunAmmo : int = 100

signal update_gui(crosshair: Texture, weaponIcon: Texture, magSize: int, ammo: int, weaponName: String)


func _ready() -> void:
	if get_child_count() != 0:
		hasWeapon = true
		var weapon : WeaponBase = get_child(0)
		weapon._init_weapon()


func _physics_process(_delta: float) -> void:
	if hasWeapon:
		var weapon : WeaponBase = get_child(0)
		if Input.is_action_pressed("attack"):
			weapon.TryAttack()
		if Input.is_action_just_released("attack"):
			weapon.release = true
		
		if Input.is_action_just_pressed("reload"):
			weapon.TryReload()


func _get_ammo(type : int) -> int:
	if type == 0:
		return lightAmmo
	elif type == 1:
		return mediumAmmo
	elif type == 2:
		return heavyAmmo
	elif type == 3:
		return shotgunAmmo
	return 0


func _set_ammo(type : int, value : int) -> void:
	if type == 0:
		lightAmmo = value
	elif type == 1:
		mediumAmmo = value
	elif type == 2:
		heavyAmmo = value
	elif type == 3:
		shotgunAmmo = value
	_on_weapon_update()


# handles weapon changes and gui communication
func _on_weapon_update():
	if get_child_count() != 0:
		hasWeapon = true
		var weapon : WeaponBase = get_child(0)
		
		var crosshair = weapon.crosshair
		var weaponIcon = weapon.silhouette
		var weaponMag = weapon.ammo
		var weaponAmmo = _get_ammo(weapon.bulletType)
		var weaponName = weapon.weaponName
		
		update_gui.emit(crosshair, weaponIcon, weaponMag, weaponAmmo, weaponName)
