extends StaticBody3D

var health = 100
var damage = 5
var translation = Vector3(-0.005,0,0)
var gbody
var arm_can_detach = true
var head_can_detach = true
var arm = preload("res://drones/dronearm.tscn")
var head = preload("res://drones/drone/dronehead.tscn")
var chilled = false

@onready var ap = $AnimationPlayer

var counter = 0
func _physics_process(delta):
	counter += 1
	if counter == 1:
		translation = Vector3(0,0.07,0)
	if health <= 0:
		queue_free()
	translate(translation)
		# Print the position (x, y, z) every frame
	#print("Position: ", global_transform.origin)
	print("drone")

func walk():
	ap.play("walk")
	if chilled:
		ap.speed_scale = 0.25
	else:
		ap.speed_scale = 1.0

func walkforward():
	translation = Vector3(-0.09, 0, 0)

func stopwalk():
	translation = Vector3(0, 0, 0)

func _on_hitbox_body_entered(body):
	if body.is_in_group("plant"):
		gbody = body
		if gbody:
			ap.play("eat")
	else:
		walk()
		gbody = null

func _on_hitbox_body_exited(body):
	ap.play("walk")
	if chilled:
		ap.speed_scale = 0.5
	else:
		ap.speed_scale = 1.0
	gbody = null

func eat():
	if gbody != null:
		gbody.takedamage(damage)
	else:
		walk()

func armdetach():
	pass

func headdeteach():
	pass
