extends Spatial

var lockCamera = false

func respawnPlane():
	$plane.respawn($spawn.global_transform)

func _ready():
	respawnPlane()

func _process(_delta):
	
	# Get plane direction
	var planeForwardNormal = -$plane.transform.basis.z
	var planeDirection = planeForwardNormal - planeForwardNormal.dot(Vector3.UP) * Vector3.UP
	
	# Lock plane's follow cam onto test lock point
	if Input.is_action_just_pressed("lockCamera"):
		lockCamera = !lockCamera
	if lockCamera:
		$plane.lockCamera($"test-camera-lockpoint".global_transform.origin)
	
	# Update dial
	$hud.updateSpeedDial($plane.velocity.length())

func _on_plane_crashed():
	respawnPlane()
