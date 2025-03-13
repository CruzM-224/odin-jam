package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

main :: proc() {

	Point :: struct {
		x, y : i32
	}

	tilePos :: struct {
		row, column : int
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

	MapBool :: [rows][columns]bool
	MapInt :: [rows][columns]int

	getTilesDrawnClean :: proc() -> MapBool {
		tilesMap : MapBool
		tilesMap[0]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[1]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[2]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[3]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[4]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[5]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[6]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[7]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[8]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[9]  = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		tilesMap[11] = [columns]bool{false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
		return tilesMap
	}
	
	tilesDrawn : MapBool
	tilesDrawn = getTilesDrawnClean()
	
	objectsMap : MapInt
	objectsMap[0]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[1]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[2]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[3]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[4]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[5]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[6]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[7]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[8]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[9]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	objectsMap[11] = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	
	// Finish 0 - 2, Begin 9 - 11
	getFinishPos :: proc() -> (int, int) {
		finishRowRange : [3]int = {0, 1, 2}
		finishColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		finishRow := int(rand.choice(finishRowRange[:]))
		finishColumn := int(rand.choice(finishColumnRange[:]))

		return finishRow, finishColumn
	}

	finishPos : tilePos
	finishPos.row, finishPos.column = getFinishPos()

	getBeginPos :: proc() -> (int, int) {
		beginRowRange : [2]int = {10, 11}
		beginColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		beginRow := int(rand.choice(beginRowRange[:]))
		beginColumn := int(rand.choice(beginColumnRange[:]))

		return beginRow, beginColumn
	}

	beginPos : tilePos
	beginPos.row, beginPos.column = getBeginPos()

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

		if(rl.IsKeyPressed(rl.KeyboardKey.R)){
			finishPos.row, finishPos.column = getFinishPos()
			beginPos.row, beginPos.column = getBeginPos()
			tilesDrawn = getTilesDrawnClean()
		}
		
		rl.EndDrawing()

		rl.DrawRectangle(i32(finishPos.column) * tiles.width, i32(finishPos.row) * tiles.height, tiles.width, tiles.height, rl.RED)
		rl.DrawRectangle(i32(beginPos.column) * tiles.width, i32(beginPos.row) * tiles.height, tiles.width, tiles.height, rl.GREEN)
	}
}
