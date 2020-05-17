extends KinematicBody2D

var target: String = ""
export (int, 800, 2000) var missile_range = 1000
export (bool) var homing = true
export (int, 300, 600) var speed = 600
export (float, 2.0, 4.0) var rotation_speed = 3.0
export (Vector2) var target_pos = Vector2(500, 300)

onready var offset: Vector2 = global_position
var distance_done = 0
var prev_pos = null

func _ready():
	set_physics_process(false)
	var target_node = get_node("Sprite").duplicate()
	target_node.rotation = 0
	target_node.set_name("target")
	get_parent().call_deferred("add_child", target_node)
	call_deferred("set_physics_process", true)

func _physics_process(delta):
	if global_position != offset and prev_pos:
		# update distance moved in total from starting position
		distance_done += global_position.distance_to(prev_pos)
	
	# line 32: I want the missile to explode when it is near the target
	# line 33: lifespan of missile reached, it should explode or disappear
	# For implementation, it would be great to separate these 2 conditions
	# to assign different behaviour to each of them
	if (
		global_position.distance_to(target_pos) <= 20 or
		distance_done >= missile_range
	):
		print("target reached or missile lifespan ended")
		# get missile back to it's starting position and calculate next
		# target position
		global_position = offset
		distance_done = 0
		random_target_pos()
	var rot_difference = rad2deg(get_angle_to(target_pos))
	if rot_difference != 0:
		if rot_difference < -1 and rot_difference > -180:
			# turning left
			rotation -= rotation_speed * delta
		elif rot_difference > 1 or rot_difference <= 180:
			# turning right
			rotation += rotation_speed * delta
	# remember current position as previous position for next physics process
	prev_pos = global_position
	# finally set velocity and move the missile
	var velocity = Vector2(speed, 0).rotated(rotation)
	move_and_collide(velocity * delta)

func random_target_pos():
	randomize()
	# this is for testing, because there's no camera, keep the missile within
	# your window size (check your project settings and screen resolution)
	var pos_x = rand_range(200, 1700)
	var pos_y = rand_range(200, 800)
	# set the target position for the missile to reach
	target_pos = Vector2(pos_x, pos_y)
	if get_parent().has_node("target"):
		get_parent().get_node("target").global_position = target_pos
	print("target pos is: ", target_pos)
