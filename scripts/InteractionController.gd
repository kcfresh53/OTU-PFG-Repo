extends Area3D
class_name  WeaponInteractionController

@onready var collision = $CollisionShape3D

var weapon : Node3D
var player
var canPickup : bool

signal pickup


func _ready() -> void:
	weapon = get_parent()


func _physics_process(_delta: float) -> void:
	if canPickup:
		if player != null:
			_on_pickup(player)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("player entered")
		player = body
		canPickup = true
		print("can pickup: " + str(canPickup))


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("player exited")
		player = null
		canPickup = false
		print("can pickup: " + str(canPickup))


func _on_pickup(body: Node3D) -> void:
	if Input.is_action_just_pressed("interact"):
		print("picked")
		var weaponHolder : Marker3D = body.get_node("%Weapon Holder")
		
		if weaponHolder.get_child_count() > 0:
			var existingWeapon = weaponHolder.get_child(0)
			existingWeapon.drop()
		
		weapon.get_parent().remove_child(weapon)
		weaponHolder.add_child(weapon)
		weapon.position = Vector3(0,0,0)
		weapon.rotation = Vector3(0,0,0)
		weaponHolder._on_weapon_update()
		weapon._init_weapon()
		
		pickup.emit()
		collision.disabled = true
		canPickup = false


func _on_drop() -> void:
	collision.disabled = false

