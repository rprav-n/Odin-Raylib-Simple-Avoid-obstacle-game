package main

import "core:strings"
import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

NAME :: "Avoid Obstacles"
WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 360
SPEED :: 5
SIZE :: rl.Vector2{50, 50}
SPEEDS :: []int{1, 2, 3, 4, 5, 6}

State :: enum {
	PLAYING,
	GAMEOVER
}

Obstacle :: struct {
	pos_x: f32,
	pos_y: f32,
	speed: int
}

obstacles : [dynamic]Obstacle

main :: proc() {

	state := State.PLAYING

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, NAME);

	playerPos := rl.Vector2{WINDOW_WIDTH/2 - SIZE.x/2, WINDOW_HEIGHT - 100}

	OBSTACLE_SPAWN_TIME : f32 : 2
	currentSpawnTime: f32 = 0.0
	dir := 1

	spawnObstacle()
	score := 0

	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {

		if state == State.PLAYING {
			dt := rl.GetFrameTime()

			// player movement
			if rl.IsKeyPressed(rl.KeyboardKey.LEFT) || rl.IsKeyPressed(rl.KeyboardKey.A) {
				dir = -1
			}
			if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) || rl.IsKeyPressed(rl.KeyboardKey.D) {
				dir = 1
			}

			playerPos.x += cast(f32)(SPEED * dir)

			// player window collision check
			if playerPos.x <= 0 {
				playerPos.x = 0
			}
			if playerPos.x + SIZE.x >= WINDOW_WIDTH {
				playerPos.x = WINDOW_WIDTH - SIZE.x
			}

			currentSpawnTime += dt
			if currentSpawnTime > OBSTACLE_SPAWN_TIME {
				currentSpawnTime = 0.0
				spawnObstacle()
			}

			// update obstacle
			for &obstacle in obstacles {
				obstacle.pos_y += cast(f32)obstacle.speed
			}

			// remove obstacle if it went beyond the screen
			for obstacle, index in obstacles {
				if obstacle.pos_y > WINDOW_HEIGHT {
					ordered_remove(&obstacles, index)
					score += 1
				}
			}

			// player obstacle collision check
			for obstacle in obstacles {
				if obstacle.pos_y + SIZE.y > playerPos.y && obstacle.pos_y < playerPos.y + SIZE.y \
				&& obstacle.pos_x < playerPos.x + SIZE.x && obstacle.pos_x + SIZE.x > playerPos.x
				{
					state = State.GAMEOVER
				}
			}

		} else {
			if rl.IsKeyPressed(rl.KeyboardKey.R) {
				clear(&obstacles)
				score = 0
				state = State.PLAYING
			}
		}

		
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if state == State.PLAYING {
			rl.DrawRectangleV(playerPos, SIZE, rl.RED)
		
			for obstacle in obstacles {
				rl.DrawRectangleV({obstacle.pos_x, obstacle.pos_y}, SIZE, rl.BLUE)
			}
			scoreStr := fmt.tprintf("%i", score)
			rl.DrawText(strings.clone_to_cstring(scoreStr), 10, 10, 20, rl.GREEN)
			// l := len(obstacles)
			// sizeStr := fmt.tprintf("%i", l)
			// rl.DrawText(strings.clone_to_cstring(sizeStr), 10.0, 10.0, 32, rl.RED)
		} else {
			rl.DrawText("Game Over", 100, WINDOW_HEIGHT/2, 32, rl.BLACK)
			rl.DrawText("Press 'R' to restart", 100, WINDOW_HEIGHT/2-100, 32, rl.BLACK)
		}
		

		rl.EndDrawing()
	}

}



spawnObstacle :: proc() {
	pos_x := rand.float32_range(0.0, WINDOW_WIDTH - SIZE.x)
	pos_y: f32 = -100.0
	speed := rand.choice(SPEEDS)
	obstacle := Obstacle{
		pos_x,
		pos_y,
		speed
	}
	append(&obstacles, obstacle)
}