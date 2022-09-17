extends Node

const SNAKE = 0
const APPLE = 1

const LEFT = 3
const RIGHT = 4
const UP = 5
const DOWN = 6


var snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]
var snake_direction = Vector2(1, 0)
var add_apple = false

var apple_pos
	
func _ready():
	apple_pos = place_apple()
	draw_apple()
	draw_snake()
	
func _process(delta):
	check_game_over()
	if apple_pos in snake_body:
		apple_pos = place_apple()	
	
# warning-ignore:unused_argument
func _input(event):
	if 	Input.is_action_just_pressed("ui_up"):
		if not snake_direction ==  Vector2(0, 1):
			snake_direction = Vector2(0, -1)
	elif Input.is_action_just_pressed("ui_down"):
		if not snake_direction ==  Vector2(0, -1):
			snake_direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("ui_left"):
		if not snake_direction ==  Vector2(1, 0):
			snake_direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right"):
		if not snake_direction ==  Vector2(-1, 0):
			snake_direction = Vector2(1, 0)
	
func place_apple():
	randomize()
	var x = randi() % 20
	var y = randi() % 20
	return Vector2(x, y)

func draw_apple():
	$Board.set_cell(apple_pos.x, apple_pos.y, APPLE)

func draw_snake():	
	for block_index in snake_body.size():
		var block = snake_body[block_index]
		
		var tilemap = Vector2(8, 0)
		
		# Head
		if block_index == 0:
			var head_dir = relation2(snake_body[1], snake_body[0])
			if head_dir == RIGHT:
				tilemap = Vector2(2, 0)
			elif head_dir == LEFT:
				tilemap = Vector2(3, 1)
			elif head_dir == UP:
				tilemap = Vector2(2, 1)
			elif head_dir == DOWN:
				tilemap = Vector2(3, 0)
		
		# tail
		elif block_index == snake_body.size() - 1:
			var tail_dir = relation2(snake_body[-2], snake_body[-1])
			if tail_dir == RIGHT:
				tilemap = Vector2(1, 0)
			elif tail_dir == LEFT:
				tilemap = Vector2(0, 0)
			elif tail_dir == UP:
				tilemap = Vector2(0, 1)
			elif tail_dir == DOWN:
				tilemap = Vector2(1, 1)
		
		else:
			var prev_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1]- block
			
			if prev_block.x == next_block.x:
				tilemap = Vector2(4, 1)
			elif prev_block.y == next_block.y:
				tilemap = Vector2(4, 0)
			else:
				# Go Right and top
				if (prev_block.x == -1 and next_block.y == -1) or (next_block.x == -1 and prev_block.y == -1):
					tilemap = Vector2(6, 1)
				
				# Go Top and Left
				elif (prev_block.x == -1 and next_block.y == 1) or (next_block.x == -1 and prev_block.y == 1):
					tilemap = Vector2(6, 0)

				# Go Bottom and Left
				elif (prev_block.x == 1 and next_block.y == -1) or (next_block.x == 1 and prev_block.y == -1):
					tilemap = Vector2(5, 1)

				# Go Top and Right
				elif (prev_block.x == 1 and next_block.y == 1) or (next_block.x == 1 and prev_block.y == 1):
					tilemap = Vector2(5, 0)
			
		
		$Board.set_cell(
			block.x, block.y, SNAKE, false , false, false, 
			tilemap
		)

func relation2(first_block:Vector2, second_block:Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(-1, 0): return LEFT
	elif block_relation == Vector2(1, 0): return RIGHT
	elif block_relation == Vector2(0, -1): return UP
	elif block_relation == Vector2(0, 1): return DOWN

func move_snake():
	delete_tiles(SNAKE)
	var body_copy
	if add_apple:
		body_copy = snake_body.slice(0, snake_body.size() - 1)
		add_apple = false
	else:
		body_copy = snake_body.slice(0, snake_body.size() - 2)
	var new_head = body_copy[0] + snake_direction
	body_copy.insert(0, new_head)
	snake_body = body_copy

func delete_tiles(id:int):
	var cells = $Board.get_used_cells_by_id(id)
	for cell in cells:
		$Board.set_cell(cell.x, cell.y, -1)	

func check_apple_eaten():
	if apple_pos == snake_body[0]:
		apple_pos = place_apple()
		add_apple = true
		$CrunchSound.play()
		update_score()
		

func _on_SnakeTick_timeout():
	move_snake()
	draw_apple()
	draw_snake()
	check_apple_eaten()

func reset():
	snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]
	snake_direction = Vector2(1, 0)

func check_game_over():
	var head = snake_body[0]
	# Snake leaves the screen
	if head.x > 19 or head.x < 0 or head.y < 0 or head.y > 19:
		reset()
	
	# Snakes bites its own tail 
	for block in snake_body.slice(1, snake_body.size() - 1):
		if block == head:
			reset()

func update_score():
	$Score/TextureRect/ScoreText.text = "%s" % (snake_body.size() - 2)
