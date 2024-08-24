extends Node2D

var bumper = preload("res://bumper.tscn")
var marble = preload("res://marble.tscn")
var ballTouch = preload("res://ball_toucher.tscn")

var max = 90
var evenRow = true
var diameter = 64.0
var direction = 1
var radius = diameter / 2.0
var fullRise = sin(PI/3.0) * diameter
var partRise = tan(PI/6.0) * radius

var colors = [
	Color(1, 0, 0),
	Color(0, 1, 0),
	Color(0, 0, 1),
	Color(1, 0, 1),
	Color(0, 1, 1),
	Color(1, 1, 0),
	Color(1, .5, 0),
]

var balls_to_remove = {}
var balls_removing = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var left = $arena/left
	var right = $arena/right
	var bottom = $arena/bottom

	var spawnPos = Vector2(left.position.x + radius, bottom.position.y - radius)

	for i in max:
		var c = randi_range(0, len(colors)-1)
		var m = marble.instantiate()
		m.position = spawnPos
		m.get_node("color").modulate = colors[c]
		m.mass += c * .5
		$arena.add_child(m)
		
		var t_up_pos = Vector2(spawnPos.x + radius, spawnPos.y - partRise)
		var t_dn_pos = Vector2(spawnPos.x + radius, spawnPos.y + partRise)
		if t_up_pos.x + radius < right.position.x:
			var t_up = ballTouch.instantiate()
			var t_dn = ballTouch.instantiate()
			t_up.position = t_up_pos
			t_dn.position = t_dn_pos
			t_dn.orientation = 1
			t_up.connect("queue_remove", ball_remover)
			t_dn.connect("queue_remove", ball_remover)
			$arena.add_child(t_up)
			$arena.add_child(t_dn)
		
		spawnPos.x += direction * diameter
		if spawnPos.x >= right.position.x or \
		   spawnPos.x <= left.position.x:
			if !evenRow:
				var bl = bumper.instantiate()
				var br = bumper.instantiate()
				bl.position.x = left.position.x
				bl.position.y = spawnPos.y
				br.position.x = right.position.x
				br.position.y = spawnPos.y
				$arena.add_child(bl)
				$arena.add_child(br)
			
			direction *= -1
			spawnPos.x += direction * diameter + direction * radius if evenRow else direction * radius
			spawnPos.y -= fullRise;
			evenRow = !evenRow
		

func ball_remover(marbles: Array[Node2D]):
	for ball in marbles:
		if ball.is_queued_for_deletion():
			continue

		if ball not in balls_removing:
			balls_to_remove[ball] = 0

func _process(delta):
	if len(balls_to_remove) > 0:

		for ball in balls_to_remove.keys():
			if ball in balls_removing:
				continue 

			balls_removing[ball] = 0
			balls_to_remove.erase(ball)
			var tweener = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
			tweener.tween_property(ball.get_node("color"), "modulate", Color(1, 1, 1), .3)
			tweener.tween_property(ball, "scale", Vector2(.90, .90), .2)
			tweener.chain().tween_property(ball, "scale", Vector2(1.1, 1.1), .05)
			tweener.connect("finished", func(): 
				ball.queue_free()
				balls_removing.erase(ball)
			)

