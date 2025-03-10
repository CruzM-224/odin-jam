package main

import rl "vendor:raylib"
import "core:fmt"

main :: proc() {
    windowWidth : i32 = 800
    windowHeight : i32 = 600

	rl.InitWindow(windowWidth, windowHeight, "Game")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		deltaTime := rl.GetFrameTime()
		
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)
		
		rl.EndDrawing()
	}
}
