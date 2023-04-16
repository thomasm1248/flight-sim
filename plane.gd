extends KinematicBody

# Basic plane
var velocity = Vector3()
var thrust = 1
var boostThrust = 4
var driftThrust = 0.3
var lift = 0.5
var driftLift = 0.5
var g = 0.5
var airResistance = Vector3(0.5, 7, 1)
var driftAirResistance = airResistance * 0.5
var dragDistanceX = 60
var dragDistanceY = 0.7
var rollForce = 2.5
var pitchForce = 2.5

# Control calibration
var rollControl = 0
var pitchControl = 0
var mouseSensitivity = 0.002

signal crashed

func lockCamera(point):
	$follow/pivot.look_at(point, Vector3.UP)

func respawn(spawnTransform):
		pitchControl = 0
		rollControl = 0
		velocity = Vector3()
		global_transform = spawnTransform
		$follow.position = spawnTransform.origin

func addForce(position, force, delta):
	
	# Add velocity
	velocity += force * delta
	
	# Rotate
	var torque = position.cross(force)
	if torque.length() != 0:
		rotate(torque.normalized(), torque.length() * delta)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rollControl -= event.relative.x * mouseSensitivity
		pitchControl += event.relative.y * mouseSensitivity
		rollControl = clamp(rollControl, -1, 1)
		pitchControl = clamp(pitchControl, -1, 1)

func _physics_process(delta):
	
	# Use spacebar to reset controls
	if Input.is_action_just_pressed("resetControls"):
		pitchControl = 0
		rollControl = 0
	
	# Apply rotation
	rotate(transform.basis.z, rollControl * rollForce * delta)
	rotate(transform.basis.x, pitchControl * pitchForce * delta)

	# Apply thrust
	if Input.is_action_pressed("boost"):
		velocity += -transform.basis.z * boostThrust * delta
	elif Input.is_action_pressed("drift"):
		velocity += -transform.basis.z * driftThrust * delta
	else:
		velocity += -transform.basis.z * thrust * delta
#	velocity += Vector3.FORWARD * thrust * delta # for thrust tuning

	# Apply lift
	if Input.is_action_pressed("drift"):
		velocity += transform.basis.y * velocity.dot(-transform.basis.z) * driftLift * delta
	else:
		velocity += transform.basis.y * velocity.dot(-transform.basis.z) * lift * delta
	
	# Apply gravity
	velocity += Vector3.DOWN * g * delta

	# Apply air-resistance
	var resistance
	if Input.is_action_pressed("drift"):
		resistance = driftAirResistance
	else:
		resistance = airResistance
	var speed = velocity.length()
	var rawAirForce = -velocity.normalized() * speed * speed
	var airForceX = transform.basis.x * resistance.x * rawAirForce.dot(transform.basis.x)
	var airForceY = transform.basis.y * resistance.y * rawAirForce.dot(transform.basis.y)
	var airForceZ = transform.basis.z * resistance.z * rawAirForce.dot(transform.basis.z)
	addForce(transform.basis.z * dragDistanceX, airForceX, delta)
	addForce(transform.basis.z * dragDistanceY, airForceY, delta)
	velocity += airForceZ * delta

	# Move the plane
	var collision = move_and_collide(velocity)
	
	# Crash if there's a collision
	if collision:
		emit_signal("crashed")
