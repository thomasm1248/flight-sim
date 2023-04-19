extends Position3D

var followDistance = 0
var rigidDistance = 0.7
var followTenacity = 8
var uprightTenacity = 5
var cameraHeight = 0.2

var position = Vector3()
var up = Vector3.UP

func _physics_process(delta):
	
	var plane = get_parent()
	
	# Follow the plane
	var positionOfPlane = plane.global_transform.origin
	var dirToPlane = positionOfPlane - position
	var currentDist = dirToPlane.length()
	var forwardDist = (currentDist - followDistance) * followTenacity * delta
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
	
