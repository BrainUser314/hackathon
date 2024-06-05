extends StaticBody3D

var health = 100
var damage = 5
var translation = Vector3(-0.005,0,0)
var gbody
var arm_can_detach = true
var head_can_detach = true
var arm = preload("res://drones_zigzag/drone_zigzagarm.tscn")
var head = preload("res://drones_zigzag/drone_zigzag/drone_zigzaghead.tscn")
var chilled = false
var degree: int = 2
static var point_to_shot : Array[Vector2]
static var number_point_to_shot = -1
@onready var ap = $AnimationPlayer

# Shared variable

var counter = 0
var walk_counter = 0
var go_right = true 
var index:int
var globalTime = 0
var level = 1
var levelDuration = 0.25
var time_series: Array[Vector2]
var points_counter = 0
var is_point_to_shot = false
var x_for_shot = -1
var z_for_shot = -1
func _ready():
	#var time_series: Array = [Vector2(1, 1), Vector2(2, 4), Vector2(3, 9)]
	#var t: int = 2
	#var degree: int = 2  # Degree of the polynomial
	#var predicted_points = predict_next_points(time_series, t, degree)
	#for point in predicted_points:
		#print(point)  # Output: Predicted points for the next t steps
	pass


func _physics_process(delta):
	globalTime += delta
	counter += 1
	if counter == 1:
		translation = Vector3(0,0.07,0)
	if health <= 0:
		queue_free()
	translate(translation)
		 #Print the position (x, y, z) every frame
	if index == 1 and globalTime >= levelDuration*level:
		level += 1
		if level < 60:
			print("level", level)
			print("Position: ", global_transform.origin)
			var current_position = global_transform.origin
			var current_xy = Vector2(current_position.x, current_position.z)
			time_series.append(current_xy)
		if level == 60:
			var predicted_points = predict_next_points(time_series, 12, degree)
			var last_point = predicted_points[11]
			x_for_shot = last_point.x
			z_for_shot = last_point.y
			number_point_to_shot += 1
			point_to_shot.append(last_point)
			for point in predicted_points:
				print(point)
				
				
		if level >= 60 and level < 68:
			print("level", level)
			print("Position: ", global_transform.origin)
			
func walk():
	ap.play("walk")
	if chilled:
		ap.speed_scale = 0.25
	else:
		ap.speed_scale = 1.0

func walkforward():
	walk_counter += 1
	#if walk_counter % 2 == 0:
		#go_right = !go_right
	var move_z = 0.005
	move_z = move_z * 0.99
	if go_right:
		translation = Vector3(-0.05, 0, -move_z)
	else:
		translation = Vector3(-0.05, 0, move_z)
		

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


# Polynomial regression function
func predict_next_points(time_series: Array, t: int, degree: int) -> Array:
	# Extract x and y points from the time series
	var x_points = []
	var y_points = []
	for point in time_series:
		x_points.append(point.x)
		y_points.append(point.y)
	
	# Create a time array
	var time_stamps = []
	for i in range(time_series.size()):
		time_stamps.append(float(i + 1))
	
	# Create polynomial features
	var time_stamps_poly = create_polynomial_features(time_stamps, degree)
	
	# Fit polynomial regression models
	var model_x = fit_linear_model(time_stamps_poly, x_points)
	var model_y = fit_linear_model(time_stamps_poly, y_points)
	
	# Predict the next points
	var predicted_points = []
	for i in range(1, t + 1):
		var next_time_stamp = float(time_stamps.size() + i)
		var next_time_stamp_poly = create_polynomial_features([next_time_stamp], degree)[0]
		var predicted_x = predict(model_x, next_time_stamp_poly)
		var predicted_y = predict(model_y, next_time_stamp_poly)
		predicted_points.append(Vector2(predicted_x, predicted_y))
	
	return predicted_points

# Create polynomial features
func create_polynomial_features(time_stamps: Array, degree: int) -> Array:
	var poly_features = []
	for time in time_stamps:
		var features = []
		for d in range(degree + 1):
			features.append(pow(time, d))
		poly_features.append(features)
	return poly_features

# Fit linear regression model
func fit_linear_model(X: Array, y: Array) -> Dictionary:
	var XtX = []
	var Xty = []
	
	# Initialize matrices
	for i in range(X[0].size()):
		XtX.append([])
		for j in range(X[0].size()):
			XtX[i].append(0.0)
		Xty.append(0.0)
	
	# Calculate XtX and Xty
	for i in range(X.size()):
		for j in range(X[0].size()):
			for k in range(X[0].size()):
				XtX[j][k] += X[i][j] * X[i][k]
			Xty[j] += X[i][j] * y[i]
	
	# Solve for coefficients
	var coeffs = solve_linear_system(XtX, Xty)
	return {"coeffs": coeffs}

# Predict using linear model
func predict(model: Dictionary, features: Array) -> float:
	var prediction = 0.0
	for i in range(features.size()):
		prediction += model["coeffs"][i] * features[i]
	return prediction

# Solve linear system using Gaussian elimination
func solve_linear_system(A: Array, b: Array) -> Array:
	var n = A.size()
	
	for i in range(n):
		# Make the diagonal contain all 1
		var alpha = A[i][i]
		for k in range(n):
			A[i][k] /= alpha
		b[i] /= alpha
		
		# Make the other rows contain 0 in current column
		for j in range(n):
			if i != j:
				alpha = A[j][i]
				for k in range(n):
					A[j][k] -= alpha * A[i][k]
				b[j] -= alpha * b[i]
	
	return b

