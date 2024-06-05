extends Area3D

var damage = 100
var translationUp = Vector3(0,0.25,0)
var translationRight = Vector3(0.15,0,0)
var counter = 0
func _physics_process(delta):
	counter+=1
	if counter < 7:
		translate(translationUp)
	else:
		translate(translationRight)
	
func _on_area_entered(area):
	if area.has_method("takedamage"):
		area.takedamage(damage)
	queue_free()
