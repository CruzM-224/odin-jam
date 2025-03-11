package main

import rl "vendor:raylib"
import "core:fmt"

main :: proc() {

	Point :: struct {
		x, y : i32
	}

	Line :: struct {
		startPos, endPos : Point
	}

	startPos : Point = {-1, -1}
	endPos : Point

	drawnLines : [dynamic]Line

	timePassed : f32 = 0

    windowWidth : i32 = 800
    windowHeight : i32 = 600
	
	rl.InitWindow(windowWidth, windowHeight, "Game")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		deltaTime := rl.GetFrameTime()
		
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

		if(rl.IsMouseButtonDown(rl.MouseButton.RIGHT)){
			temp := rl.GetMousePosition()
			tempPoint : Point = {x=i32(temp[0]), y=i32(temp[1])}

			if(startPos.x != -1){
				endPos = startPos
			}else{
				endPos = tempPoint
			}

			startPos = tempPoint

			fmt.println(startPos)
			fmt.println(endPos)
			append(&drawnLines, Line{startPos, endPos})
		}else{
			timePassed += deltaTime
			if(timePassed >= 0.1){
				timePassed = 0
				if(len(drawnLines) > 0){
					ordered_remove(&drawnLines, 0)
				}
			}
		}
		
		for value in drawnLines {
			rl.DrawLine(value.startPos.x, value.startPos.y, value.endPos.x, value.endPos.y, rl.BLACK)
		}
		
		rl.EndDrawing()
	}
}
