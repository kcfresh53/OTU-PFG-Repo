@tool
extends RigidBody3D
class_name WeaponBase


@export var animationPlayer : AnimationPlayer
@export var audioPlayer : AudioStreamPlayer3D
@export var interactionController : WeaponInteractionController
@export var collision : CollisionShape3D

@export_group("Bullet Properties")
@export var bulletSpawnPos : Marker3D
@export var bulletModel : PackedScene
@export var bulletSpeed : float = 40.0
@export_enum("light", "medium", "heavy", "shotgun") var bulletType : int = 0

@export_group("Weapon Properties")
@export var weaponName : String
@export var shoot_sound : AudioStream
@export var reload_sound : AudioStream
@export var empty_sound : AudioStream
@export var magsize : int
@export var isAuto : bool

# conditional export for spread type weapons
@export var isSpread : bool:
	set(value):
		isSpread = value
		notify_property_list_changed()
# conditional variables
var shotNum : int
var spreadRange : float

# handle conditional exporting on engine level
func _get_property_list():
	var property_usage = PROPERTY_USAGE_NO_EDITOR
	
	if isSpread:
		property_usage = PROPERTY_USAGE_DEFAULT
	
	var properties = []
	
	properties.append({
		"name": "Weapon Properties",  # Use a name that starts the group
		"type": TYPE_NIL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"usage": PROPERTY_USAGE_GROUP
	})
	
	properties.append({
		"name": "shotNum",
		"type": TYPE_INT,
		"usage": property_usage,
		"hint": 0,
		"hint_string": "int"
	})
	
	properties.append({
		"name": "spreadRange",
		"type": TYPE_INT,
		"usage": property_usage,
		"hint": 0,
		"hint_string": "float"
	})
	
	return properties

@export_group("GUI")
@export var crosshair : Texture
@export var silhouette : Texture

var ammo : int
var canShoot : bool
var canReload : bool
var isAiming : bool
var release : bool
var weaponController 


func _ready() -> void:
	if not Engine.is_editor_hint():
		# signal connections
		animationPlayer.connect("animation_finished", _on_action_finished)
		interactionController.connect("pickup", picked)
		# variable initializations
		canShoot = true
		canReload = true
		# interation checker
		if get_parent().is_in_group("Player"):
			picked()


func _init_weapon() -> void:
	if not Engine.is_editor_hint():
		weaponController = get_parent()
		weaponController._on_weapon_update()
		picked()
		Reload()


func TryAttack() -> void:
	if not Engine.is_editor_hint():
		if isAuto:
			Shoot()
		# if weapon is not automatic, you can only shoot once
		else:
			if release:
				release = false
				Shoot()
		weaponController._on_weapon_update()


func TryReload() -> void:
	if not Engine.is_editor_hint():
		if canReload:
			canShoot = false
			# play reload animation which calls reload function
			animationPlayer.play("reload")
		weaponController._on_weapon_update()


func Shoot() -> void:
	if not Engine.is_editor_hint():
		if canShoot && ammo > 0:
			#play shooting animation
			animationPlayer.play("shoot")
			print("shot")
			#play audio
			audioPlayer.stream = shoot_sound
			audioPlayer.play()
			
			# straight shot weapons
			if !isSpread:
				#instance a bullet
				var bullet = bulletModel.instantiate()
				#change bullet spawn to bullet spawn position
				bullet.speed = bulletSpeed
				bullet.position = bulletSpawnPos.global_position
				bullet.transform.basis = bulletSpawnPos.global_transform.basis
				get_tree().get_root().add_child(bullet)
			
			# spread based weapons
			else:
				# b represents bullet
				for b in range(shotNum):
					var spread : float = randf_range(-spreadRange, spreadRange)
					
					#instance a bullet
					var bullet = bulletModel.instantiate()
					#change bullet spawn to bullet spawn position
					bullet.speed = bulletSpeed
					bullet.position = bulletSpawnPos.global_position
					# apply rotation
					bullet.transform.basis = bulletSpawnPos.global_transform.basis.rotated(Vector3.DOWN, deg_to_rad(spread))
					bullet.transform.basis = bullet.transform.basis.rotated(Vector3(1, 0, 0), deg_to_rad(spread))
					bullet.transform.basis = bullet.transform.basis.rotated(Vector3(0, 0, 1), deg_to_rad(spread))
					
					get_tree().get_root().add_child(bullet)
			
			#subtract ammo from mag
			if ammo >= 1:
				ammo -= 1
				canShoot = false
		if ammo <= 0:
			TryReload()


func Reload() -> void:
	if not Engine.is_editor_hint():
		print("reloading...")
		# check if is a child of player
		if get_parent() is WeaponHolder:
			# reference to ammo within the player inventory
			var ammoInventoryRef : int = get_parent()._get_ammo(bulletType)
			
			if ammo >= magsize:
				# Magazine is already full or overfilled
				canShoot = true
				return
			
			if ammo < magsize:
				if magsize < ammoInventoryRef:
					# if ammo in mag remains subtract what is needed
					get_parent()._set_ammo(bulletType, ammoInventoryRef - (magsize - ammo))
					ammo = magsize
					canShoot = true
					
					# play audio
					audioPlayer.stream = reload_sound
					audioPlayer.play()
				else:
					var totalAmmo = ammo + ammoInventoryRef
					if totalAmmo <= magsize:
						ammo = totalAmmo
						get_parent()._set_ammo(bulletType, 0)
					else:
						# Handle the case where adding ammoInventoryRef exceeds magsize
						ammo = magsize
						var remainingAmmo = totalAmmo - magsize
						get_parent()._set_ammo(bulletType, remainingAmmo)
					
					if ammo >= 0:
						canShoot = true
						# play audio
						audioPlayer.stream = reload_sound
						audioPlayer.play()
					else:
						canShoot = false
						# play audio
						audioPlayer.stream = empty_sound
						audioPlayer.play()
			
			print("ammo in mag: " + str(ammo))
			print(get_parent()._get_ammo(bulletType))
			weaponController._on_weapon_update()


func _on_action_finished(animName : String) -> void:
	if not Engine.is_editor_hint():
		if animName == "shoot":
			canShoot = true
		if animName == "reload":
			canReload = true


func picked() -> void:
	if not Engine.is_editor_hint():
		collision.disabled = true
		freeze = true


func drop() -> void:
	if not Engine.is_editor_hint():
		var newParent = get_tree().get_root()
		var currentPosition = global_position
		
		get_parent().remove_child(self)
		newParent.add_child(self)
		position = currentPosition
		
		collision.disabled = false
		freeze = false
		interactionController._on_drop()


func aim() -> void:
	pass
