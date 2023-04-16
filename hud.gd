extends CanvasLayer

func updateSpeedDial(speed):
	$"Container/speed-dial".setRotation(speed / 3 * PI * 2)
