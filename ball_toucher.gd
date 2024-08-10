extends Area2D

var selection = preload("res://selection_border.tscn")

@export var lobes = 3
@export var excludeParent = false
signal queue_remove(marbles: Array[Node2D])

var orientation = 0
var displayBorder = false
var mouseInside = false
var border
var tweener

func are_bodies_valid(bodies):
	return bodies.all(func(body): return !body.freeze and body.linear_velocity.x < 0.1 and body.linear_velocity.y < 0.1)
	
func shouldShowBorder():
	var bodies = get_overlapping_bodies()

	if excludeParent:
		bodies = bodies.filter(func(body): return body != self.get_parent())
			
	if len(bodies) != lobes:
		return false
		
	return are_bodies_valid(bodies)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if mouseInside:
		print(displayBorder, '  ', border)
		
	if displayBorder and border == null:
		border = selection.instantiate()
		border.lobes = lobes
		border.set_rotation(PI * orientation)
		self.add_child(border)
		
		var bodies = get_overlapping_bodies()
		if excludeParent:
			bodies = bodies.filter(func(body): return body != self.get_parent())

		for body in bodies:
			body.z_index = 1
		border.z_index = 2
	elif not displayBorder and border != null:
		self.remove_child(border)
		border = null
		var bodies = get_overlapping_bodies()
		for body in bodies:
			body.z_index = 0
			
	check_for_matches()

func _physics_process(delta):
	if mouseInside and not displayBorder:
		displayBorder = shouldShowBorder()

func _on_mouse_entered():
	mouseInside = true
	displayBorder = shouldShowBorder()

func _on_mouse_exited():
	mouseInside = false
	displayBorder = false

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and displayBorder and border != null and (tweener == null or !tweener.is_running()):
		var bodies = get_overlapping_bodies()
		if excludeParent:
			bodies = bodies.filter(func(body): return body != self.get_parent())
			
		if not are_bodies_valid(bodies):
			return
		
		var dir = -1 if event.button_index == 1 else 1
		tweener = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
		
		var rot = border.get_rotation()
		tweener.tween_property(border, "rotation", rot + dir*2*PI/lobes, .5)
		
		PhysicsServer2D.set_active(false)
		tweener.connect("finished", func(): PhysicsServer2D.set_active(true))
		
		for body in bodies:
			var ball_pos = body.global_position
			var self_pos = self.global_position
			var offset = ball_pos - self_pos
			var r = sqrt(pow(offset.x,2) + pow(offset.y,2))
			var t = atan(offset.y/offset.x)
			if offset.x < 0: t += PI
			elif offset.y < 0: t = 2*PI + t
			tweener.tween_method(func(angle):
				var x = r * cos(angle) + self_pos.x
				var y = r * sin(angle) + self_pos.y
				body.global_position = Vector2(x, y)
			, t, t + dir*2*PI/lobes, .5)

func check_for_matches():
	var bodies = get_overlapping_bodies()
	
	if len(bodies) != lobes or !are_bodies_valid(bodies):
		return
		
	var color = bodies[0].get_node("color").modulate
	var matches = bodies.all(func(body): return color == body.get_node("color").modulate)
	
	if matches:
		for body in bodies: body.freeze = true
		displayBorder = false
		queue_remove.emit(bodies)
		

