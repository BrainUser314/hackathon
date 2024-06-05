extends StaticBody3D

var health = 100
var can_shoot = true
var x = 3
static var have_point = false
@onready var pea = preload("res://projectiles/simpleAirRocket/simpleAirRocket.tscn")

func _physics_process(delta):
	var collider = $RayCast3D.get_collider()
	if (collider and can_shoot) or have_point:
		$AnimationPlayer2.play("shoot")

func shootpea():
	if can_shoot:
		can_shoot = false
		var pea2 = pea.instantiate()
		pea2.position = $RayCast3D.global_transform.origin
		get_tree().get_root().add_child(pea2)
		$Timer.start()

func takedamage(damage):
	health -= damage
	if health <= 0:
		queue_free()

func _on_timer_timeout():
	can_shoot = true
