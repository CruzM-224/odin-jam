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

	Rectangle :: struct {
		width, height : i32
	}

	startPos : Point = {-1, -1}
	endPos : Point

	drawnLines : [dynamic]Line

	timePassed : f32 = 0
	timeToDelete : f32 = 0.01

    windowWidth : i32 : 800
    windowHeight : i32 : 600

	tiles : Rectangle : {50, 50}

	rows, columns : i32 : windowHeight/tiles.height, windowWidth/tiles.width
	row, column : i32

	Map :: [rows][columns]bool

	tilesDrawn : Map
	tilesDrawn[0]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[1]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[2]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[3]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[4]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[5]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[6]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[7]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[8]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[9]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	tilesDrawn[11] = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}

	rl.InitWindow(windowWidth, windowHeight, "Game")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		deltaTime := rl.GetFrameTime()
		
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

		for i : i32 = 0; i < windowHeight; i += tiles.height {
			for j : i32 = 0; j < windowWidth; j += tiles.width {
				rl.DrawRectangleLines(j, i, tiles.width, tiles.height, rl.BLACK)
				if(tilesDrawn[i/tiles.height][j/tiles.width]){
					rl.DrawRectangle(j, i, tiles.width, tiles.height, rl.BLACK)
				}
			}
		}

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
			if(timePassed >= timeToDelete){
				timePassed = 0
				if(len(drawnLines) > 0){
					row, column = drawnLines[0].startPos.y/tiles.height, drawnLines[0].startPos.x/tiles.width
					if(!tilesDrawn[row][column]){
						
						tilesDrawn[row][column] = true
					}
					ordered_remove(&drawnLines, 0)
				}else{
					startPos = {-1, -1}
				}
			}
		}
		
		for value in drawnLines {
			rl.DrawLine(value.startPos.x, value.startPos.y, value.endPos.x, value.endPos.y, rl.BLACK)
		}
		
		rl.EndDrawing()
	}
}
