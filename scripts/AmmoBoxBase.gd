extends RigidBody3D
class_name AmmoBoxBase

@export var collider : Area3D
@export var ammoAmount : int
@export_enum("light", "medium", "heavy", "shotgun") var bulletType : int = 0


func _ready() -> void:
	collider.connect("body_entered", _on_body_entered)


func _on_body_entered(body : Node3D):
	if body.is_in_group("Player"):
		print(body.name)
		var weaponHolder : Marker3D = body.get_node("%Weapon Holder")
		weaponHolder._set_ammo(bulletType, weaponHolder._get_ammo(bulletType) + ammoAmount)
		print("Ammo picked up")
		queue_free()
