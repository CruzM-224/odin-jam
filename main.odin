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
	drawnPixels : [dynamic]Point

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
			append(&drawnPixels, tempPoint)

			if(startPos.x != -1){
				endPos = startPos
			}else{
				endPos = tempPoint
			}

			startPos = tempPoint

			fmt.println(startPos)
			fmt.println(endPos)
			append(&drawnLines, Line{startPos, endPos})
		}
		
		for value in drawnLines {
			rl.DrawLine(value.startPos.x, value.startPos.y, value.endPos.x, value.endPos.y, rl.BLACK)
		}
		
		rl.EndDrawing()
	}
}
