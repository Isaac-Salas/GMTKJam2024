extends RigidBody2D
class_name  Rat_enemy
@export var ratfleetarget : Marker2D
@onready var timer = $Timer
@onready var target_loc = $TargetLoc
@onready var direction
@export var speed = 0
@onready var timer_2 = $Timer2
@onready var player : SlimePlayer
@onready var playerdir
@onready var sprite = $AnimatedSprite2D
@onready var timer_3 = $Timer3
@onready var fleeonce = false
@onready var colision = $CollisionShape2D
@export var startflee = false
@onready var alerted = $Alerted

@onready var left_r = $LeftR
@onready var right_r = $RightR
@onready var detector = $Detector
@onready var spawnedfrom : RatSpawn


const OUTLINE = preload("res://scenes/objects/Shaders/outline.gdshader")




# Called when the node enters the scene tree for the first time.
func _ready():
	direction = global_position - target_loc.global_position
	chillin()
	player = get_tree().get_first_node_in_group("Player")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	player = get_tree().get_first_node_in_group("Player")
	if get_parent().is_in_group("barnacle"):
		var count = 0
		match count:
			0:
				if timer and timer_2 and timer_3:
					timer.stop()
					timer_2.stop()
					timer_3.stop()
				count += 1
			1:
				pass
				
	match startflee:
		true:
			sprite.play("new_animation")
			#print("Fleeing")
			
			var movingto = self.global_position.move_toward(ratfleetarget.global_position, delta*(speed*50))
			var movector = (movingto-self.global_position)*2
			self.rotation_degrees = 0
			#print(abs(movector.x))
			if movector > Vector2(0,0):
				sprite.flip_h = true
			if movector < Vector2(0,0):
				sprite.flip_h = false
			#self.global_position.x = movingto.x
			#set_deferred("lock_rotation", false)
			
			if left_r.is_colliding() or right_r.is_colliding():
				print(right_r.get_collider())
				print("tryclimb")
				sprite.rotation_degrees = -90
				
				apply_central_impulse(Vector2i(0, -50))
			else:
				sprite.rotation_degrees = 0
			
			
			apply_central_impulse(Vector2i(movector.x, 0))
			if self.global_position.x == ratfleetarget.global_position.x or abs(movector.x) < 1:
				set_deferred("lock_rotation", true)
				startflee = false
				
		false:
			alerted.visible = false
			sprite.stop()
			pass
	
	
	direction = global_position - target_loc.global_position
	
	

func chillin():
	timer_3.stop()
	timer_2.stop()
	rotation = 0
	set_deferred("lock_rotation", true)
	timer.start(randf_range(0.1,1))
	target_loc.position.x = randi_range(-20,20)
	apply_central_impulse(direction*speed)
	if direction > Vector2(0,0):
		sprite.flip_h = true
	if direction < Vector2(0,0):
		sprite.flip_h = false

func chasing(player):
	
	timer.stop()
	timer_3.stop()
	set_deferred("lock_rotation", false)
	timer_2.start(0.25)
	playerdir = player.global_position - global_position
	apply_central_impulse(Vector2(playerdir.x*3, playerdir.y))

func fleeing():
	alerted.visible = true
	timer.stop()
	timer_2.stop()
	##print("Ratflee")
	#var fleeingdir = ratfleetarget.global_position - self.global_position
	#apply_central_impulse(Vector2(0,-20))
	apply_torque_impulse(50)
	#timer_3.start(0.3)
	startflee = true

	

func _on_timer_timeout():
	chillin()
	


func _on_player_detect_body_entered(body):
	if body.is_in_group("Player"):
		if player.scare.is_connected(fleeing) == false:
			player.scare.connect(fleeing)
		#timer.stop()
		player = body
		if player.current == "Big":
			fleeing()
			#startflee = true
		else:
			chasing(player)


func _on_timer_2_timeout():
	chasing(player)


func _on_player_detect_body_exited(body):
	if body.is_in_group("Player"):
		#player.scare.disconnect(fleeing)
		timer_2.stop()
		timer_3.stop()
		startflee = false
		fleeonce = false
		chillin()


func _on_timer_3_timeout():
	fleeing()
	


func _on_detector_area_entered(area):
	if area is ObjectDetect:
		print("Highlight!")
		var newmat = ShaderMaterial.new()
		newmat.shader = OUTLINE
		newmat.set_shader_parameter("width", 2)
		newmat.set_shader_parameter("outline_color", Color("ffaa00"))
		#newmat.set_shader_parameter("flickering_speed", 20)
		sprite.material = newmat


func _on_detector_area_exited(area):
	if area is ObjectDetect:
		sprite.material = null
