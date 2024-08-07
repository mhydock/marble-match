extends Line2D

var lobes = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	var slices = lobes * 2
	var anglePerSlice = 360 / slices

	var angleRads = PI/(6.0 if lobes == 3 else 3.0)
	var innerRadius = sqrt(pow(tan(angleRads) * 32, 2) + pow(32,2))
	var outerRadius = 32
	
	for i in slices:
		var degrees = (180 if lobes == 3 else 110) if i%2 == 0 else 60
		var radMult = 2 if lobes == 3 else 1.75
		for j in degrees:
			var ir = innerRadius if i%2 == 0 else innerRadius*radMult
			
			var innerAngle = i*anglePerSlice+(anglePerSlice/2 if lobes%2 != 0 else 0)
			var outerAngle = innerAngle - (degrees/2) + j
			
			if i%2 != 0:
				outerAngle = innerAngle + (degrees/2) - j + 180
				
			var x = cos(deg_to_rad(innerAngle)) * ir + (outerRadius * cos(deg_to_rad(outerAngle)))
			var y = sin(deg_to_rad(innerAngle)) * ir + (outerRadius * sin(deg_to_rad(outerAngle)))
			self.add_point(Vector2(x, y))
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
