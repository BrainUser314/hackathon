extends Area3D

var damage = 100
var translationUp = Vector3(0,0.25,0)
var translationRight = Vector3(0.15,0,0)
var counter = 0
var found_vector = false
static var x = -1 

static var y = -1
static var have_target = false

func _physics_process(delta):
	#counter+=1
	#if counter < 7:
		#translate(translationUp)
	#else:
		#translate(translationRight)
	var current_position = global_transform.origin
	if have_target:
		print("?????")
		print(x)
		print(y)
		print("?????")
		var move_vector = Vector3(x - current_position.x,1.75,y - current_position.z) / 50
		translate(move_vector)
	
func _on_area_entered(area):
	if area.has_method("takedamage"):
		area.takedamage(damage)
	queue_free()
