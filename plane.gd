extends KinematicBody

# Basic plane #################################
var gravity = 0.01
var maxHorizontalSpeed = 0.07
var boostFactor = 2
var driftFactor = 0.2
var airResistance = Vector3(20, 80, 10)
###############################################
var velocity = Vector3()
var thrust = pow(maxHorizontalSpeed, 2) * airResistance.z
var boostThrust = thrust * pow(boostFactor, 2)
var lift = gravity / maxHorizontalSpeed
var driftAirResistance = airResistance * driftFactor
var driftThrust = pow(maxHorizontalSpeed, 2) * driftAirResistance.z
var dragDistanceX = 20
var dragDistanceY = 10
var rollForce = 2.5
var pitchForce = 1.8
var yawForce = 0.2

# Control calibration
var rollControl = 0
var pitchControl = 0
var mouseSensitivity = 0.002

signal crashed

func lockCamera(point):
	$follow/pivot.look_at(point, Vector3.UP)

func respawn(spawnTransform):
		# Reset controls
		pitchControl = 0
		rollControl = 0
		# Reset velocity
		velocity = Vector3()
		# Move to spawn point
		global_transform = spawnTransform
		# Reset camera
		$follow.position = spawnTransform.origin + transform.basis.z * 20
		# Reset wing trails
		$"right-wing-trail".reset()
		$"left-wing-trail".reset()

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
	var autoRudder = transform.basis.x.dot(Vector3.UP)
	rotate(transform.basis.y, autoRudder * yawForce * delta)
	transform.basis = transform.basis.orthonormalized()

	# Apply thrust
	if Input.is_action_pressed("boost"):
		velocity += -transform.basis.z * boostThrust * delta
	elif Input.is_action_pressed("drift"):
		velocity += -transform.basis.z * driftThrust * delta
	else:
		velocity += -transform.basis.z * thrust * delta
#	velocity += Vector3.FORWARD * thrust * delta # for thrust tuning

	# Apply lift
	velocity += transform.basis.y * velocity.dot(-transform.basis.z) * lift * delta
	
	# Apply gravity
	velocity += Vector3.DOWN * gravity * delta

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
	
	# Shake camera
	var traumaRate = velocity.length() / maxHorizontalSpeed - 1
	$follow.trauma = traumaRate
	#$follow.addTrauma(traumaRate * delta * 10)
	
	# Crash if there's a collision
	if collision:
		emit_signal("crashed")
