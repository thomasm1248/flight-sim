extends ImmediateGeometry

# This doesn't work, and it's probably not what I need

var maxNumberOfPoints = 50

var points = []

func _process(delta):
	
	# Add a new point, and trim off oldest point
	points.append(global_transform.origin)
	if len(points) > maxNumberOfPoints:
		points.remove(0)
	
	# Draw points
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in points:
		add_vertex(p)
	end()
