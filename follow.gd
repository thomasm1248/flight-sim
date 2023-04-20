extends Position3D

var followDistance = 0
var rigidDistance = 0.7
var followTenacity = 8
var uprightTenacity = 5
var cameraHeight = 0.2

var position = Vector3()
var up = Vector3.UP

var trauma = 0
var traumaFadeRate = 1
var time = 0
var noise = OpenSimplexNoise.new()

func addTrauma(newTrauma):
	trauma += newTrauma

func _ready():
	# Initialize noise
	noise.seed = 1 # doesn't really matter
	noise.octaves = 4
	noise.period = 0.05
	noise.persistence

func _physics_process(delta):
	
	var plane = get_parent()
	
	# Follow the plane
	var positionOfPlane = plane.global_transform.origin
	var dirToPlane = positionOfPlane - position
	var currentDist = dirToPlane.length()
	var forwardDist = (currentDist - followDistance) * followTenacity * delta
	if currentDist != 0:
		position = position.linear_interpolate(positionOfPlane, forwardDist / currentDist)
	global_transform.origin = position
	var camDist = (positionOfPlane - position).length() + rigidDistance
	
	# Update the up direction
	up = (up + plane.transform.basis.y * uprightTenacity * delta).normalized()
	
	# Place pivot
	$pivot.global_transform = plane.global_transform
	
	# Rotate pivot
	$pivot.look_at(plane.global_transform.origin * 2 - global_transform.origin, up)
	
	# Position camera on pivot
	$pivot/Camera.transform.origin = Vector3(0, cameraHeight, camDist)
	$pivot/Camera.look_at(plane.global_transform.origin, $pivot.global_transform.basis.y)
	
	# Shake camera
	if trauma > 0:
		var shake = pow(trauma, 2)
		var rotateShake = shake * 0.01
		var translateShake = shake * 0.015
		var cam = $pivot/Camera
		cam.rotate_object_local(cam.transform.basis.x, rotateShake * noise.get_noise_1d(time))
		cam.rotate_object_local(cam.transform.basis.y, rotateShake * noise.get_noise_1d(time + 10))
		cam.rotate_object_local(cam.transform.basis.z, rotateShake * noise.get_noise_1d(time + 20))
		cam.transform.origin += Vector3(
			translateShake * noise.get_noise_1d(time + 30),
			translateShake * noise.get_noise_1d(time + 40),
			translateShake * noise.get_noise_1d(time + 50))
		cam.transform = cam.transform.orthonormalized()
		trauma -= traumaFadeRate * delta
		time += delta
	else:
		trauma = 0
		time = 0
	
