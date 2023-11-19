extends Node3D

@onready var shotParticle = $shotParticle
var speed : float = 40.0


func _ready() -> void:
	shotParticle.emitting = true


func _process(delta: float) -> void:
	position += transform.basis * Vector3( 0, 0, -speed) * delta


func _on_timer_timeout() -> void:
	#print("despawned")
	queue_free()


func _on_area_3d_body_entered(_body: Node3D) -> void:
	print("collided")
	queue_free()
