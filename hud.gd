extends CanvasLayer

func updateSpeedDial(speed):
	$"Container/speed-dial".setRotation(speed / 0.2 * PI * 2)
